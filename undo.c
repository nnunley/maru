/* undo.c -- the undo log behind worlds: while one is active, each write through a primitive records what it overwrites,
 * so the world can be dropped by replaying the log backwards.  Included by each evaluator, which defines UNDO_CONS.
 * Raw memory (set-byte-at and the like) and the evaluator's own tables are outside it: reads never pay anything,
 * writes pay one test when no world is active, and C always sees the current value.
 */
enum { UNDO_HEAD, UNDO_TAIL, UNDO_ARRAY, UNDO_ARRAY_SIZE, UNDO_OOP, UNDO_CHAR, UNDO_STRING_SIZE, UNDO_VARIABLE };

static oop  undoLog=   nil;
static long undoDepth= 0;

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

#define undoNote(OBJECT, KIND, INDEX, OLD)	do { if (undoDepth) undoRecord(OBJECT, KIND, INDEX, OLD); } while (0)

static void undoArrayWrite(oop array, int index)
{
    if (undoDepth && is(Array, array)) {
	oop old= (index < arrayLength(array)) ? arrayAt(array, index) : nil;
	if (index >= arrayLength(array)) undoRecord(array, UNDO_ARRAY_SIZE, 0, get(array, Array,size));
	else				 undoRecord(array, UNDO_ARRAY, index, old);
    }
}

static void undoStringWrite(oop string, int index)
{
    if (undoDepth) {
	if (index >= stringLength(string)) undoRecord(string, UNDO_STRING_SIZE, 0, get(string, String,size));
	else				   undoRecord(string, UNDO_CHAR, index, newLong(get(string, String,bits)[index]));
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
	case UNDO_ARRAY_SIZE:	set(object, Array,size, old);			break;
	case UNDO_OOP:		oopAtPut(object, index, old);			break;
	case UNDO_CHAR:		get(object, String,bits)[index]= getLong(old);	break;
	case UNDO_STRING_SIZE:	set(object, String,size, old);			break;
#ifdef UNDO_VARIABLE_WRITE
	case UNDO_VARIABLE:	UNDO_VARIABLE_WRITE(object, old);		break;
#endif
    }
}

/* a world is the log as it stood when it began */
static subr(undo_begin)
{
    ++undoDepth;
    return undoLog;
}

/* its writes stay; an enclosing world can still drop them, so they stay logged until the outermost commits */
static subr(undo_commit)
{
    if (0 == --undoDepth) undoLog= nil;
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
    return nil;
}

/* a fresh object has nothing to undo, and whatever a failing world makes to report it must outlast the world */
static subr(undo_pause)
{
    oop depth= newLong(undoDepth);
    undoDepth= 0;
    return depth;
}

static subr(undo_resume)
{
    undoDepth= getLong(getHead(args));
    return nil;
}

static void undoOutOfMemory(void)
{
    fatal("out of memory");
}
