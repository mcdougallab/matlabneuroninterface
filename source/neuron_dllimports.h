#ifndef NRNDLLIMP_H
#define NRNDLLIMP_H

#include "neuron_api_headers.h"

// Import C++ name mangled functions.
__declspec(dllimport) vv_function delete_section;
__declspec(dllimport) initer_function ivocmain_session;
__declspec(dllimport) vsecptri_function mech_insert1;
__declspec(dllimport) voptrsptritemptrptri_function new_sections;
__declspec(dllimport) nptrsecptrd_function node_exact;
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
__declspec(dllimport) dvptrint_function hoc_call_func;
__declspec(dllimport) voptrsptri_function hoc_call_ob_proc;
__declspec(dllimport) dsio_function hoc_call_objfunc;
__declspec(dllimport) vsptr_function hoc_install_object_data_index;
__declspec(dllimport) vitemptr_function hoc_l_delete;
__declspec(dllimport) scptr_function hoc_lookup;
__declspec(dllimport) optrsptri_function hoc_newobj1;
__declspec(dllimport) voptr_function hoc_obj_ref;
__declspec(dllimport) voptr_function hoc_obj_unref;
__declspec(dllimport) optrptrv_function hoc_objpop;
__declspec(dllimport) icptr_function hoc_oc;
__declspec(dllimport) voptr_function hoc_push_object;
__declspec(dllimport) vdptr_function hoc_pushpx;
__declspec(dllimport) vsptr_function hoc_pushs;
__declspec(dllimport) vcptrptr_function hoc_pushstr;
__declspec(dllimport) vd_function hoc_pushx;
__declspec(dllimport) dptrv_function hoc_pxpop;
__declspec(dllimport) vv_function hoc_ret;
__declspec(dllimport) cptrptrv_function hoc_strpop;
__declspec(dllimport) scptrslptr_function hoc_table_lookup;
__declspec(dllimport) voptrptr_function hoc_tobj_unref;
__declspec(dllimport) dv_function hoc_xpop;

// C++ name mangled oc_* functions.
__declspec(dllimport) hoc_oop_ss oc_save_hoc_oop;
__declspec(dllimport) hoc_oop_ss oc_restore_hoc_oop;
__declspec(dllimport) cabcode_ss oc_save_cabcode;
__declspec(dllimport) cabcode_ss oc_restore_cabcode;

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) int diam_changed;
extern "C" __declspec(dllimport) int secondorder;
extern "C" __declspec(dllimport) Symlist* hoc_built_in_symlist;
extern "C" __declspec(dllimport) Objectdata* hoc_objectdata;
extern "C" __declspec(dllimport) Objectdata* hoc_top_level_data;
extern "C" __declspec(dllimport) Symlist* hoc_top_level_symlist;
extern "C" __declspec(dllimport) int nrn_is_python_extension;
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;
extern "C" __declspec(dllimport) int nrn_try_catch_nest_depth;
extern "C" __declspec(dllimport) vf2icif_function nrnpy_set_pr_etal;
extern "C" __declspec(dllimport) hoc_Item* section_list;

// Import functions for which name mangling goes awry.
extern "C" __declspec(dllimport) code_ss _Z12oc_save_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_save_code = _Z12oc_save_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
extern "C" __declspec(dllimport) code_ss _Z15oc_restore_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_restore_code = _Z15oc_restore_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
extern "C" __declspec(dllimport) input_info_ss _Z18oc_save_input_infoPPKcPiS2_PP6_iobuf;
const auto oc_save_input_info = _Z18oc_save_input_infoPPKcPiS2_PP6_iobuf;
extern "C" __declspec(dllimport) input_info_rs _Z21oc_restore_input_infoPKciiP6_iobuf;
const auto oc_restore_input_info = _Z21oc_restore_input_infoPKciiP6_iobuf;


#endif