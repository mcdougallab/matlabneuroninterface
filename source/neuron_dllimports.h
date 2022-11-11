#ifndef NRNDLLIMP_H
#define NRNDLLIMP_H

#include "neuron_api_headers.h"

// Import C++ name mangled functions.
__declspec(dllimport) vv_function delete_section;
__declspec(dllimport) initer_function ivocmain_session;
__declspec(dllimport) vsecptri_function mech_insert1;
__declspec(dllimport) voptrsptritemptrptri_function new_sections;
__declspec(dllimport) vv_function nrnmpi_stubs;
__declspec(dllimport) ppoptr_function ob2pntproc_0;
__declspec(dllimport) cptrsecptr_function secname;
__declspec(dllimport) vsecptr_function section_unref;
__declspec(dllimport) vv_function simpleconnectsection;
__declspec(dllimport) ivptr_function vector_capacity;
__declspec(dllimport) dptrvptr_function vector_vec;

// C++ name mangled nrn_* functions.
__declspec(dllimport) dptrsecptrsptrd_function nrn_rangepointer;
__declspec(dllimport) vsecptri_function nrn_change_nseg;
__declspec(dllimport) vsecptrd_function nrn_length_change;
__declspec(dllimport) vv_function nrn_popsec;
__declspec(dllimport) vsecptr_function nrn_pushsec;
__declspec(dllimport) secptrv_function nrn_sec_pop;

// C++ name mangled hoc_* functions.
__declspec(dllimport) Symlist* hoc_built_in_symlist;
__declspec(dllimport) dvptrint_function hoc_call_func;
__declspec(dllimport) voptrsptri_function hoc_call_ob_proc;
__declspec(dllimport) dsio_function hoc_call_objfunc;
__declspec(dllimport) vsptr_function hoc_install_object_data_index;
__declspec(dllimport) scptr_function hoc_lookup;
__declspec(dllimport) optrsptri_function hoc_newobj1;
__declspec(dllimport) voptr_function hoc_obj_ref;
__declspec(dllimport) voptr_function hoc_obj_unref;
__declspec(dllimport) Objectdata* hoc_objectdata;
__declspec(dllimport) optrptrv_function hoc_objpop;
__declspec(dllimport) icptr_function hoc_oc;
__declspec(dllimport) voptrptr_function hoc_pushobj;
__declspec(dllimport) vdptr_function hoc_pushpx;
__declspec(dllimport) vcptrptr_function hoc_pushstr;
__declspec(dllimport) vd_function hoc_pushx;
__declspec(dllimport) vv_function hoc_ret;
__declspec(dllimport) cptrptrv_function hoc_strpop;
__declspec(dllimport) scptrslptr_function hoc_table_lookup;
__declspec(dllimport) voptrptr_function hoc_tobj_unref;
__declspec(dllimport) Objectdata* hoc_top_level_data;
__declspec(dllimport) Symlist* hoc_top_level_symlist;
__declspec(dllimport) dv_function hoc_xpop;

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) int diam_changed;
extern "C" __declspec(dllimport) int nrn_is_python_extension;
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;
extern "C" __declspec(dllimport) vf2icif_function nrnpy_set_pr_etal;
extern "C" __declspec(dllimport) nptrsecptrd_function node_exact;

#endif