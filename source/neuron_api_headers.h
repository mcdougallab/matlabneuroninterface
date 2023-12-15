// excerpted from https://github.com/neuronsimulator/nrn/blob/master/src/oc/hocdec.h
#ifndef NRNAPI_H
#define NRNAPI_H

#define DIAMLIST 1
#define CACHEVEC 1
#define EXTRAEQN 0
#define DEBUGSOLVE 0

// default nseg from https://github.com/neuronsimulator/nrn/blob/master/src/nrnoc/membdef.h
#define DEF_nseg 1    /* default number of segments per section*/


// excerpted from https://github.com/neuronsimulator/nrn/blob/master/src/oc/hocdec.h

struct Symbol;
struct Arrayinfo;
struct Proc;
struct Symlist;
union Datum;
struct cTemplate;
union Objectdata;
struct Object;
struct Section;

struct hoc_Item {
    union {
        hoc_Item* itm;
        hoc_Item* lst;
        char* str;
        Symbol* sym;
        Section* sec;
        Object* obj;
        void* vd;
    } element; /* pointer to the actual item */
    hoc_Item* next;
    hoc_Item* prev;
    short itemtype;
};
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

union Datum { /* interpreter stack type */
    double val;
    Symbol* sym;
    int i;
    double* pval; /* first used with Eion in NEURON */
    Object** pobj;
    Object* obj; /* sections keep this to construct a name */
    char** pstr;
    hoc_Item* itm;
    hoc_List* lst;
    void* _pvoid; /* not used on stack, see nrnoc/point.cpp */
};

class ShapePlotInterface {
  public:
    virtual void scale(float min, float max) = 0;
    virtual const char* varname() const = 0;
    virtual void* varobj() const = 0;
    virtual void varobj(void* obj) = 0;
    virtual void variable(Symbol*) = 0;
    virtual float low() = 0;
    virtual float high() = 0;
    virtual Object* neuron_section_list() = 0;
    virtual bool has_iv_view() = 0;
};

/**********************************************************
 * The below is excerpted from:
 * https://github.com/neuronsimulator/nrn/blob/master/src/nrnoc/section.h
 *********************************************************/

struct Prop;
struct Section;
struct Node;

#if DIAMLIST
typedef struct Pt3d {
    float x, y, z, d; /* 3d point, microns */
    double arc;
} Pt3d;
#endif

typedef struct Section {
    int refcount;              /* may be in more than one list */
    short nnode;               /* Number of nodes for ith section */
    struct Section* parentsec; /* parent section of node 0 */
    struct Section* child;     /* root of the list of children
                       connected to this parent kept in
                       order of increasing x */
    struct Section* sibling;   /* used as list of sections that have same parent */


    /* the parentnode is only valid when tree_changed = 0 */
    struct Node* parentnode; /* parent node */
    struct Node** pnode;     /* Pointer to  pointer vector of node structures */
    int order;               /* index of this in secorder vector */
    short recalc_area_;      /* NODEAREA, NODERINV, diam, L need recalculation */
    short volatile_mark;     /* for searching */
    void* volatile_ptr;      /* e.g. ShapeSection* */
#if DIAMLIST
    short npt3d;                     /* number of 3-d points */
    short pt3d_bsize;                /* amount of allocated space for 3-d points */
    struct Pt3d* pt3d;               /* list of 3d points with diameter */
    struct Pt3d* logical_connection; /* nil for legacy, otherwise specifies logical connection
                                        position (for translation) */
#endif
    struct Prop* prop; /* eg. length, etc. */
} Section;

typedef struct Node {
#if CACHEVEC == 0
    double _v;    /* membrane potential */
    double _area; /* area in um^2 but see treesetup.cpp */
    double _a;    /* effect of node in parent equation */
    double _b;    /* effect of parent in node equation */
#else             /* CACHEVEC */
    double* _v;     /* membrane potential */
    double _area;   /* area in um^2 but see treesetup.cpp */
    double _rinv;   /* conductance uS from node to parent */
    double _v_temp; /* vile necessity til actual_v allocated */
#endif            /* CACHEVEC */
    double* _d;   /* diagonal element in node equation */
    double* _rhs; /* right hand side in node equation */
    double* _a_matelm;
    double* _b_matelm;
    int eqn_index_;                 /* sparse13 matrix row/col index */
                                    /* if no extnodes then = v_node_index +1*/
                                    /* each extnode adds nlayer more equations after this */
    struct Prop* prop;              /* Points to beginning of property list */
    Section* child;                 /* section connected to this node */
                                    /* 0 means no other section connected */
    Section* sec;                   /* section this node is in */
                                    /* #if PARANEURON */
    struct Node* _classical_parent; /* needed for multisplit */
    void* _nt;               // actually a struct NrnThread*
/* #endif */
#if EXTRACELLULAR
    void* extnode;                  // was struct Extnode*
#endif

#if EXTRAEQN
    void* eqnblock; /* hook to other equations which
           need to be solved at the same time as the membrane
           potential. eg. fast changeing ionic concentrations -- was struct Eqnblock* */
#endif                         /*MOREEQN*/

#if DEBUGSOLVE
    double savd;
    double savrhs;
#endif                   /*DEBUGSOLVE*/
    int v_node_index;    /* only used to calculate parent_node_indices*/
    int sec_node_index_; /* to calculate segment index from *Node */
} Node;


typedef struct Prop {
    struct Prop* next; /* linked list of properties */
    short _type;       /* type of membrane, e.g. passive, HH, etc. */
    short unused1;     /* gcc and borland need pairs of shorts to align the same.*/
    int param_size;    /* for notifying hoc_free_val_array */
    double* param;     /* vector of doubles for this property */
    Datum* dparam;     /* usually vector of pointers to doubles
                  of other properties but maybe other things as well
                  for example one cable section property is a
                  symbol */
    long _alloc_seq;   /* for cache efficiency */
    Object* ob;        /* nil if normal property, otherwise the object containing the data*/
} Prop;

typedef struct Point_process {
    Section* sec; /* section and node location for the point mechanism*/
    Node* node;
    Prop* prop;    /* pointer to the actual property linked to the
                  node property list */
    Object* ob;    /* object that owns this process */
    void* presyn_; /* non-threshold presynapse for NetCon */
    void* nvi_;    /* NrnVarIntegrator (for local step method) */
    void* _vnt;    /* NrnThread* (for NET_RECEIVE and multicore) */
} Point_process;

// constants from src/nrnoc/membfunc.h
#define CABLESECTION 1
#define MORPHOLOGY   2
#define CAP          3

typedef void (initer_function)(int, const char**, const char**, int);
typedef void (vd_function)(double);
typedef void (vdptr_function)(double*);
typedef void (vv_function)(void);
typedef int (icptr_function)(const char*);
typedef void* (vcptr_function)(const char*);
typedef Symbol* (scptr_function)(const char*);
typedef double (dvptrint_function) (void*, int);
typedef Symbol* (scptroptr_function) (char*, Object*);
typedef double (dsio_function) (Symbol*, int, Object*);
typedef Symbol* (scptrslptr_function) (const char*, Symlist*);
typedef Symbol* (scptridslptrptr_function) (const char*, int, double, Symlist**);
typedef Object* (optrsptri_function) (Symbol*, int);
typedef Object* (optri_function) (int);
typedef void (voptr_function) (Object*);
typedef void (voptrptr_function) (Object**);
typedef void (vf2icif_function)(int (*)(int, char*), int(*)());
typedef int (ivptr_function)(void*);
typedef double* (dptrvptr_function)(void*);
typedef double (dv_function)(void);
typedef void (voptrsptri_function)(Object*, Symbol*, int);
typedef void (vcptrptr_function)(char**);
typedef void (vsptr_function)(Symbol*);
typedef void (voptrsptritemptrptri_function)(Object*, Symbol*, hoc_Item**, int);
typedef char* (cptrsecptr_function)(Section*);
typedef double* (dptrsecptrsptrd_function)(Section*, Symbol*, double);
typedef void (vsecptri_function)(Section*, int);
typedef void (vsecptr_function)(Section*);
typedef Section* (secptrv_function)(void);
typedef char** (cptrptrv_function)(void);
typedef char* (cptri_function)(int);
typedef Object** (optrptrv_function)(void);
typedef Point_process* (ppoptr_function)(Object*);
typedef void (vsecptrd_function)(Section*, double);
typedef Node* (nptrsecptrd_function)(Section*, double);
typedef double* (dptrv_function)(void);
typedef double (dsecptr_function)(Section*);
typedef void (vitemptr_function)(hoc_Item*);

typedef void (hoc_oop_ss)(Object**, Objectdata**, int*, Symlist**);
typedef void (code_ss)(Inst**, Inst**, std::size_t&, void**, int*, int*, Inst**, void**, std::size_t&, Symlist**, Inst**, int*);
typedef void (input_info_ss)(const char**, int*, int*, void**);
typedef void (input_info_rs)(const char*, int, int, void*);
typedef void (cabcode_ss)(int*, int*);

#endif
