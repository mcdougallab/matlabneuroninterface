#ifndef NRNDLLIMP_H
#define NRNDLLIMP_H

#include "neuron_api_headers.h"

// Import C++ name mangled functions.
__declspec(dllimport) vv_function delete_section;
__declspec(dllimport) optrsptri_function hoc_newobj1;
__declspec(dllimport) initer_function ivocmain_session;
__declspec(dllimport) vsecptri_function mech_insert1;
__declspec(dllimport) voptrsptritemptrptri_function new_sections;
__declspec(dllimport) dptrsecptrsptrd_function nrn_rangepointer;
__declspec(dllimport) vsecptri_function nrn_change_nseg;
__declspec(dllimport) vsecptrd_function nrn_length_change;
__declspec(dllimport) vv_function nrnmpi_stubs;
__declspec(dllimport) secptrv_function nrn_sec_pop;
__declspec(dllimport) cptrsecptr_function secname;
__declspec(dllimport) vsecptr_function section_unref;
__declspec(dllimport) vv_function simpleconnectsection;

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) int diam_changed;
extern "C" __declspec(dllimport) Symlist* hoc_built_in_symlist;
extern "C" __declspec(dllimport) dvptrint_function hoc_call_func;
extern "C" __declspec(dllimport) voptrsptri_function hoc_call_ob_proc;
extern "C" __declspec(dllimport) dsio_function hoc_call_objfunc;
extern "C" __declspec(dllimport) vsptr_function hoc_install_object_data_index;
extern "C" __declspec(dllimport) scptr_function hoc_lookup;
extern "C" __declspec(dllimport) voptr_function hoc_obj_ref;
extern "C" __declspec(dllimport) voptr_function hoc_obj_unref;
extern "C" __declspec(dllimport) Objectdata* hoc_objectdata;
extern "C" __declspec(dllimport) optrptrv_function hoc_objpop;
extern "C" __declspec(dllimport) icptr_function hoc_oc;
extern "C" __declspec(dllimport) voptrptr_function hoc_pushobj;
extern "C" __declspec(dllimport) vdptr_function hoc_pushpx;
extern "C" __declspec(dllimport) vcptrptr_function hoc_pushstr;
extern "C" __declspec(dllimport) vd_function hoc_pushx;
extern "C" __declspec(dllimport) vsptr_function hoc_pushs;
extern "C" __declspec(dllimport) dptrv_function hoc_pxpop;
extern "C" __declspec(dllimport) vv_function hoc_ret;
extern "C" __declspec(dllimport) cptrptrv_function hoc_strpop;
extern "C" __declspec(dllimport) scptrslptr_function hoc_table_lookup;
extern "C" __declspec(dllimport) voptrptr_function hoc_tobj_unref;
extern "C" __declspec(dllimport) Objectdata* hoc_top_level_data;
extern "C" __declspec(dllimport) Symlist* hoc_top_level_symlist;
extern "C" __declspec(dllimport) dv_function hoc_xpop;
extern "C" __declspec(dllimport) int nrn_is_python_extension;
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;
extern "C" __declspec(dllimport) nptrsecptrd_function node_exact;
extern "C" __declspec(dllimport) vv_function nrn_popsec;
extern "C" __declspec(dllimport) vsecptr_function nrn_pushsec;
extern "C" __declspec(dllimport) vf2icif_function nrnpy_set_pr_etal;
extern "C" __declspec(dllimport) ppoptr_function ob2pntproc_0;
extern "C" __declspec(dllimport) ivptr_function vector_capacity;
extern "C" __declspec(dllimport) dptrvptr_function vector_vec;

#endif