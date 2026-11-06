/* undo.c -- what the undo log needs from an evaluator: a record's parts, making one, and putting a value back.  The log's
 * logic (worlds, which slots each has recorded, commit, rollback) is undo.irl, compiled to undo-irl.c and included here.
 * Included by each evaluator, which defines UNDO_CONS.  Raw memory (set-byte-at and the like) and the evaluator's own
 * tables are outside it (on eval, whose encoder makes a variable before anything runs, a name defined in a failed world
 * stays, valued as before): reads never pay anything, writes pay one test when no world is active, and C always sees the
 * current value.
 */
#include <stdint.h>

enum { UNDO_HEAD, UNDO_TAIL, UNDO_ARRAY, UNDO_ARRAY_SIZE, UNDO_OOP, UNDO_CHAR, UNDO_STRING_SIZE, UNDO_VARIABLE, UNDO_BINDING };

static void    *undo_calloc(int64_t n, int64_t size)	{ return calloc(n, size); }
static void    *undo_realloc(void *p, int64_t size)	{ return realloc(p, size); }
static void     undo_free(void *p)			{ free(p); }
static void     undo_fatal(char *reason)		{ fatal(reason); }
static void    *undo_head(void *l)			{ oop o= l;  return getHead(o); }
static void    *undo_tail(void *l)			{ oop o= l;  return getTail(o); }
static void     undo_set_tail(void *l, void *t)		{ oop o= l;  setTail(o, (oop)t); }
static int64_t  undo_kind(void *entry)			{ oop o= entry;  return getLong(getHead(getTail(o))); }
static int64_t  undo_index(void *entry)			{ oop o= entry;  return getLong(getHead(getTail(getTail(o)))); }
static void     undo_replay(void *entry);

#include "undo-irl.c"

#define undoLog		(*(oop *)&v_undo__log)
#define undoLogging()	(v_undo__depth && !v_undo__paused)

/* a record, (object kind index . old), onto the log */
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

/* OLD is only made if this is the slot's first write in the world */
#define undoNote(OBJECT, KIND, INDEX, OLD)						\
    do { if (undoLogging() && undo_first(OBJECT, KIND, INDEX)) undoRecord(OBJECT, KIND, INDEX, OLD); } while (0)

#ifdef UNDO_VARIABLE_WRITE
static void undoVariableWrite(oop var)
{
    GC_PROTECT(var);
    undoNote(var, UNDO_VARIABLE, 0, get(var, Variable,value));
    GC_UNPROTECT(var);
}
#endif

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

static void undo_replay(void *record)
{
    oop  entry=  (oop)record;
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
#ifdef UNDO_FORGET_GLOBALS
	case UNDO_BINDING:	setTail(object, old);  UNDO_FORGET_GLOBALS();	break;	/* the name goes, from the cache too */
#endif
#ifdef UNDO_VARIABLE_WRITE
	case UNDO_VARIABLE:	UNDO_VARIABLE_WRITE(object, old);		break;
#endif
    }
}

/* for the laws: how many entries the log holds */
long maru_undo_log_size(void)	{ return undo_log_size(); }

static subr(undo_begin)		{ return (oop)undo_begin(); }
static subr(undo_commit)	{ undo_commit(getHead(args));  return nil; }
static subr(undo_rollback)	{ undo_rollback(getHead(args));  return nil; }
static subr(undo_pause)		{ undo_pause();  return nil; }
static subr(undo_resume)	{ undo_resume();  return nil; }

static void undoOutOfMemory(void)
{
    fatal("out of memory");
}
