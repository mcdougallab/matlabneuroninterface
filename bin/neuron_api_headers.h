// excerpted from https://github.com/neuronsimulator/nrn/blob/master/src/oc/hocdec.h
#ifndef NRNAPI_H
#define NRNAPI_H

struct Symbol;
struct Arrayinfo;
struct Proc;
struct Symlist;
union Datum;
struct cTemplate;
union Objectdata;
struct Object;
struct hoc_Item;

using hoc_List = hoc_Item;

typedef int (*Pfri)(void);
typedef void (*Pfrv)(void);
typedef double (*Pfrd)(void);
typedef struct Object** (*Pfro)(void);
typedef const char** (*Pfrs)(void);

typedef int (*Pfri_vp)(void*);
typedef void (*Pfrv_vp)(void*);
typedef double (*Pfrd_vp)(void*);
typedef struct Object** (*Pfro_vp)(void*);
typedef const char** (*Pfrs_vp)(void*);

union Inst { /* machine instruction list type */
    Pfrv pf;
    Pfrd pfd;
    Pfro pfo;
    Pfrs pfs;
    Pfrv_vp pfv_vp;
    Pfrd_vp pfd_vp;
    Pfro_vp pfo_vp;
    Pfrs_vp pfs_vp;
    Inst* in;
    Symbol* sym;
    void* ptr;
    int i;
};

struct HocSymExtension {
    float* parmlimits; /* some variables have suggested bounds */
    char* units;
    float tolerance; /* some states have cvode absolute tolerance */
};

struct Symbol { /* symbol table entry */
    char* name;
    short type;
    short subtype;            /* Flag for user integers */
    short cpublic;            /* flag set public variable. this was called `public` before C++ */
    short defined_on_the_fly; /* moved here because otherwize gcc and borland do not align the same
                                 way */
    union {
        int oboff;                             /* offset into object data pointer space */
        double* pval;                          /* User defined doubles - also for alias to scalar */
        Object* object_;                       /* alias to an object */
        char* cstr;                            /* constant string */
        double* pnum;                          /* Numbers */
        int* pvalint;                          /* User defined integers */
        float* pvalfloat;                      /* User defined floats */
        int u_auto;                            /* stack offset # for AUTO variable */
        double (*ptr)(double); /* if BLTIN */  // TODO: double as parameter?
        Proc* u_proc;
        struct {
            short type; /* Membrane type to find Prop */
            int index;  /* prop->param[index] */
        } rng;
        Symbol** ppsym; /* Pointer to symbol pointer array */
        cTemplate* ctemplate;
        Symbol* sym; /* for external */
    } u;
    unsigned s_varn;        /* dependent variable number - 0 means indep */
    Arrayinfo* arayinfo;    /* ARRAY information if null then scalar */
    HocSymExtension* extra; /* additions to symbol allow compatibility
                    with old nmodl dll's */
    Symbol* next;           /* to link to another */
};

struct cTemplate {
    Symbol* sym;
    Symlist* symtable;
    int dataspace_size;
    int is_point_;   /* actually the pointtype > 0 if a point process */
    Symbol* init;    /* null if there is no initialization function */
    Symbol* unref;   /* null if there is no function to call when refcount is decremented */
    int index;       /* next  unique integer used for name for section */
    int count;       /* how many of this kind of object */
    hoc_List* olist; /* list of all instances */
    int id;
    void* observers; /* hook to c++ ClassObservable */
    void* (*constructor)(struct Object*);
    void (*destructor)(void*);
    void (*steer)(void*); /* normally nil */
    int (*checkpoint)(void**);
};

union Objectdata {
    double* pval;       /* pointer to array of doubles, usually just 1 */
    char** ppstr;       /* pointer to pointer to string ,allows vectors someday*/
    Object** pobj;      /* pointer to array of object pointers, usually just 1*/
    hoc_Item** psecitm; /* array of pointers to section items, usually just 1 */
    hoc_List** plist;   /* array of pointers to linked lists */
    Arrayinfo* arayinfo;
    void* _pvoid; /* Point_process */
};

struct Object {
    int refcount; /* how many object variables point to this */
    int index;    /* unique integer used for names of sections */
    union {
        Objectdata* dataspace; /* Points to beginning of object's data */
        void* this_pointer;    /* the c++ object */
    } u;
    cTemplate* ctemplate;
    void* aliases; /* more convenient names for e.g. Vector or List elements dynamically created by
                      this object*/
    hoc_Item* itm_me;        /* this object in the template list */
    hoc_Item* secelm_;       /* last of a set of contiguous section_list items used by forall */
    void* observers;         /* hook to c++ ObjObservable */
    short recurse;           /* to stop infinite recursions */
    short unref_recurse_cnt; /* free only after last return from unref callback */
};

struct Arrayinfo {    /* subscript info for arrays */
    unsigned* a_varn; /* dependent variable number for array elms */
    int nsub;         /* number of subscripts */
    int refcount;     /* because one object always uses symbol's */
    int sub[1];       /* subscript range */
};

struct Proc {
    Inst defn;          /* FUNCTION, PROCEDURE, FUN_BLTIN */
    unsigned long size; /* length of instruction list */
    Symlist* list;      /* For constants and strings */
                        /* not used by FUN_BLTIN */
    int nauto;          /* total # local variables */
    int nobjauto;       /* the last of these are pointers to objects */
};

struct Symlist {
    Symbol* first;
    Symbol* last;
};

#endif