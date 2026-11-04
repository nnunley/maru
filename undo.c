/* undo.c -- the undo log behind worlds: while one is active, each write through a primitive records what it overwrites,
 * so the world can be dropped by replaying the log backwards.  Included by each evaluator, which defines UNDO_CONS.
 * Raw memory (set-byte-at and the like) and the evaluator's own tables are outside it: reads never pay anything,
 * writes pay one test when no world is active, and C always sees the current value.
 *
 * As in Warth's worlds, a world keeps one record per slot, however often it's written: rollback needs only the value from
 * before the first write.  A commit hands the parent the records it doesn't already have, and drops the rest.
 */
enum { UNDO_HEAD, UNDO_TAIL, UNDO_ARRAY, UNDO_ARRAY_SIZE, UNDO_OOP, UNDO_CHAR, UNDO_STRING_SIZE, UNDO_VARIABLE };

static oop  undoLog=    nil;
static long undoDepth=  0;
static long undoPaused= 0;

/* which slots each open world has a record for: a set of (object, kind, index, world).  A world's number is never reused,
 * so an entry for a world no longer open is simply dead: it's ignored, and rehashing drops it.  An entry for an open
 * world is backed by a log entry, which keeps its object alive, so a dead object's address can't match one.
 */
struct undoSlot { oop object;  long index;  long world;  int kind;  int depth; };

static struct undoSlot *undoSlots=     0;
static size_t           undoSlotsSize= 0;
static size_t           undoSlotsUsed= 0;
static long            *undoWorlds=    0;		/* the number of the open world at each depth */
static long             undoWorldsMax= 0;
static long             undoNextWorld= 1;

static int undoSlotOpen(struct undoSlot *s)
{
    return s->depth <= undoDepth && undoWorlds[s->depth] == s->world;
}

static struct undoSlot *undoSlotFind(oop object, int kind, long index, long world, struct undoSlot **free)
{
    size_t mask= undoSlotsSize - 1;
    size_t at= (((size_t)object >> 3) * 31 + (size_t)kind * 7 + (size_t)index * 131 + (size_t)world * 2654435761UL) & mask;
    *free= 0;
    for (;;  at= (at + 1) & mask) {
	struct undoSlot *s= &undoSlots[at];
	if (!s->world) { if (!*free) *free= s;  return 0; }
	if (s->world == world && s->object == object && s->kind == kind && s->index == index) return s;
	if (!*free && !undoSlotOpen(s)) *free= s;
    }
}

static void undoSlotsGrow(void)
{
    struct undoSlot *old= undoSlots;
    size_t oldSize= undoSlotsSize, i, open= 0;
    for (i= 0;  i < oldSize;  ++i) if (old[i].world && undoSlotOpen(&old[i])) ++open;
    size_t size= oldSize ? oldSize : 1024;
    while (open * 4 >= size) size *= 2;
    undoSlots= calloc(size, sizeof(struct undoSlot));
    if (!undoSlots) fatal("out of memory for the undo log");
    undoSlotsSize= size;
    undoSlotsUsed= 0;
    for (i= 0;  i < oldSize;  ++i)
	if (old[i].world && undoSlotOpen(&old[i])) {
	    struct undoSlot *free;
	    undoSlotFind(old[i].object, old[i].kind, old[i].index, old[i].world, &free);
	    *free= old[i];
	    ++undoSlotsUsed;
	}
    free(old);
}

/* notes that the world at depth has a record of this slot; true if it's the first */
static int undoSlotAdd(oop object, int kind, long index, long depth)
{
    struct undoSlot *free;
    long world= undoWorlds[depth];
    if ((undoSlotsUsed + 1) * 4 >= undoSlotsSize * 3) undoSlotsGrow();
    if (undoSlotFind(object, kind, index, world, &free)) return 0;
    if (!free->world) ++undoSlotsUsed;
    free->object= object;  free->kind= kind;  free->index= index;  free->world= world;  free->depth= depth;
    return 1;
}

#define undoLogging()	(undoDepth && !undoPaused)

static void undoRecord(oop object, long kind, long index, oop old)
{
    GC_PROTECT(object);
    GC_PROTECT(old);
    oop entry= newLong(index);		GC_PROTECT(entry);
    oop how= newLong(kind);		GC_PROTECT(how);	/* cons allocates, and doesn't protect what it's given */
    entry= UNDO_CONS(entry, old);
    entry= UNDO_CONS(how, entry);
    entry= UNDO_CONS(object, entry);
    undoLog= UNDO_CONS(entry, undoLog);
    GC_UNPROTECT(how);
    GC_UNPROTECT(entry);
    GC_UNPROTECT(old);
    GC_UNPROTECT(object);
}

#define undoNote(OBJECT, KIND, INDEX, OLD)						\
    do { if (undoLogging() && undoSlotAdd(OBJECT, KIND, INDEX, undoDepth)) undoRecord(OBJECT, KIND, INDEX, OLD); } while (0)

static void undoArrayWrite(oop array, int index)
{
    if (undoLogging() && is(Array, array)) {
	if (index >= arrayLength(array)) undoNote(array, UNDO_ARRAY_SIZE, 0, get(array, Array,size));
	else				 undoNote(array, UNDO_ARRAY, index, arrayAt(array, index));
    }
}

static void undoStringWrite(oop string, int index)
{
    if (undoLogging()) {
	if (index >= stringLength(string)) undoNote(string, UNDO_STRING_SIZE, 0, get(string, String,size));
	else				   undoNote(string, UNDO_CHAR, index, newLong(get(string, String,bits)[index]));
    }
}

static void undoReplay(oop entry)
{
    oop  object= getHead(entry);	entry= getTail(entry);
    long kind=   getLong(getHead(entry));	entry= getTail(entry);
    long index=  getLong(getHead(entry));
    oop  old=    getTail(entry);
    switch (kind) {
	case UNDO_HEAD:		setHead(object, old);				break;
	case UNDO_TAIL:		setTail(object, old);				break;
	case UNDO_ARRAY:	arrayAtPut(object, index, old);			break;
	case UNDO_ARRAY_SIZE: {		/* what was written past the old end mustn't reappear if the array grows again */
	    long i, size= arrayLength(object);
	    for (i= getLong(old);  i < size;  ++i) arrayAtPut(object, i, nil);
	    set(object, Array,size, old);
	    break;
	}
	case UNDO_OOP:		oopAtPut(object, index, old);			break;
	case UNDO_CHAR:		get(object, String,bits)[index]= getLong(old);	break;
	case UNDO_STRING_SIZE: {	/* likewise */
	    long i, size= stringLength(object);
	    for (i= getLong(old);  i < size;  ++i) get(object, String,bits)[i]= 0;
	    set(object, String,size, old);
	    break;
	}
#ifdef UNDO_VARIABLE_WRITE
	case UNDO_VARIABLE:	UNDO_VARIABLE_WRITE(object, old);		break;
#endif
    }
}

/* for the laws: how many entries the log holds */
long maru_undo_log_size(void)
{
    long n= 0;
    oop l= undoLog;
    while (nil != l) { ++n;  l= getTail(l); }
    return n;
}

/* a world is the log as it stood when it began */
static subr(undo_begin)
{
    if (++undoDepth >= undoWorldsMax) {
	undoWorldsMax= undoWorldsMax ? undoWorldsMax * 2 : 64;
	undoWorlds= realloc(undoWorlds, sizeof(long) * undoWorldsMax);
	if (!undoWorlds) fatal("out of memory for the undo log");
    }
    undoWorlds[undoDepth]= undoNextWorld++;
    return undoLog;
}

/* a world's writes stay.  An enclosing world can still drop them, so it takes the records it doesn't already have */
static subr(undo_commit)
{
    oop mark= getHead(args);
    if (1 == undoDepth) undoLog= nil;
    else {
	oop l= undoLog, previous= nil;
	while (l != mark && nil != l) {
	    oop entry= getHead(l), rest= getTail(entry);
	    long kind= getLong(getHead(rest));
	    long index= getLong(getHead(getTail(rest)));
	    if (undoSlotAdd(getHead(entry), kind, index, undoDepth - 1)) previous= l;
	    else if (nil == previous) undoLog= getTail(l);
	    else setTail(previous, getTail(l));
	    l= getTail(l);
	}
    }
    --undoDepth;
    return nil;
}

static subr(undo_rollback)
{
    oop mark= getHead(args);
    while (undoLog != mark && nil != undoLog) {
	undoReplay(getHead(undoLog));
	undoLog= getTail(undoLog);
    }
    --undoDepth;
    undoPaused= 0;
    return nil;
}

/* a fresh object has nothing to undo, and whatever a failing world makes to report it must outlast the world */
static subr(undo_pause)
{
    ++undoPaused;
    return nil;
}

static subr(undo_resume)
{
    --undoPaused;
    return nil;
}

static void undoOutOfMemory(void)
{
    fatal("out of memory");
}
