#ifndef NRNDLLIMP_H
#define NRNDLLIMP_H

#include "neuron_api_headers.h"

#ifdef _WIN32
#define MANGLED __declspec(dllimport)
#define NON_MANGLED extern "C" __declspec(dllimport)
#elif __APPLE__ || __linux__
#define MANGLED extern
#define NON_MANGLED extern "C"
#else
#   error "Unknown compiler / OS"
#endif

// Import C++ name mangled functions.
MANGLED vv_function delete_section;
MANGLED dsecptr_function section_length;
MANGLED initer_function ivocmain_session;
MANGLED vsecptri_function mech_insert1;
MANGLED voptrsptritemptrptri_function new_sections;
MANGLED nptrsecptrd_function node_exact;
MANGLED vv_function nrnmpi_stubs;
MANGLED ppoptr_function ob2pntproc_0;
MANGLED cptrsecptr_function secname;
MANGLED vsecptr_function section_unref;
MANGLED vv_function simpleconnectsection;
MANGLED ivptr_function vector_capacity;
MANGLED dptrvptr_function vector_vec;

// C++ name mangled nrn_* functions.
MANGLED dptrsecptrsptrd_function nrn_rangepointer;
MANGLED vsecptri_function nrn_change_nseg;
MANGLED vsecptrd_function nrn_length_change;
MANGLED vv_function nrn_popsec;
MANGLED vsecptr_function nrn_pushsec;
MANGLED secptrv_function nrn_sec_pop;

// C++ name mangled hoc_* functions.
MANGLED dvptrint_function hoc_call_func;
MANGLED voptrsptri_function hoc_call_ob_proc;
MANGLED dsio_function hoc_call_objfunc;
MANGLED vsptr_function hoc_install_object_data_index;
MANGLED scptridslptrptr_function hoc_install;
MANGLED vitemptr_function hoc_l_delete;
MANGLED scptr_function hoc_lookup;
MANGLED optrsptri_function hoc_newobj1;
MANGLED voptr_function hoc_obj_ref;
MANGLED voptr_function hoc_obj_unref;
MANGLED optrptrv_function hoc_objpop;
MANGLED icptr_function hoc_oc;
MANGLED voptr_function hoc_push_object;
MANGLED vdptr_function hoc_pushpx;
MANGLED vsptr_function hoc_pushs;
MANGLED vcptrptr_function hoc_pushstr;
MANGLED vd_function hoc_pushx;
MANGLED dptrv_function hoc_pxpop;
MANGLED vv_function hoc_ret;
MANGLED cptrptrv_function hoc_strpop;
MANGLED cptri_function hoc_gargstr;
MANGLED scptrslptr_function hoc_table_lookup;
MANGLED voptrptr_function hoc_tobj_unref;
MANGLED dv_function hoc_xpop;

// C++ name mangled oc_* functions.
MANGLED hoc_oop_ss oc_save_hoc_oop;
MANGLED hoc_oop_ss oc_restore_hoc_oop;
MANGLED cabcode_ss oc_save_cabcode;
MANGLED cabcode_ss oc_restore_cabcode;

// Import non-name mangled functions and parameters.
NON_MANGLED int diam_changed;
NON_MANGLED int secondorder;
NON_MANGLED Symlist* hoc_built_in_symlist;
NON_MANGLED Objectdata* hoc_objectdata;
NON_MANGLED Objectdata* hoc_top_level_data;
NON_MANGLED Symlist* hoc_top_level_symlist;
NON_MANGLED int nrn_is_python_extension;
NON_MANGLED int nrn_main_launch;
NON_MANGLED int nrn_nobanner_;
NON_MANGLED int nrn_try_catch_nest_depth;
NON_MANGLED vf2icif_function nrnpy_set_pr_etal;
NON_MANGLED hoc_Item* section_list;

#ifdef _WIN32
// Import functions for which name mangling goes awry.
NON_MANGLED code_ss _Z12oc_save_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_save_code = _Z12oc_save_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED code_ss _Z15oc_restore_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_restore_code = _Z15oc_restore_codePP4InstS1_RyPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED input_info_ss _Z18oc_save_input_infoPPKcPiS2_PP6_iobuf;
const auto oc_save_input_info = _Z18oc_save_input_infoPPKcPiS2_PP6_iobuf;
NON_MANGLED input_info_rs _Z21oc_restore_input_infoPKciiP6_iobuf;
const auto oc_restore_input_info = _Z21oc_restore_input_infoPKciiP6_iobuf;
#elif __APPLE__
extern "C" void modl_reg(){};
// Import functions for which name mangling goes awry.
NON_MANGLED code_ss _Z12oc_save_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_save_code = _Z12oc_save_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED code_ss _Z15oc_restore_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_restore_code = _Z15oc_restore_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED input_info_ss _Z18oc_save_input_infoPPKcPiS2_PP7__sFILE;
const auto oc_save_input_info = _Z18oc_save_input_infoPPKcPiS2_PP7__sFILE;
NON_MANGLED input_info_rs _Z21oc_restore_input_infoPKciiP7__sFILE;
const auto oc_restore_input_info = _Z21oc_restore_input_infoPKciiP7__sFILE;
#elif __linux__
extern "C" void modl_reg(){};
// Import functions for which name mangling goes awry.
NON_MANGLED code_ss _Z12oc_save_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_save_code = _Z12oc_save_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED code_ss _Z15oc_restore_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
const auto oc_restore_code = _Z15oc_restore_codePP4InstS1_RmPPN3nrn2oc5frameEPiS8_S1_S7_S2_PP7SymlistS1_S8_;
NON_MANGLED input_info_ss _Z18oc_save_input_infoPPKcPiS2_PP8_IO_FILE;
const auto oc_save_input_info = _Z18oc_save_input_infoPPKcPiS2_PP8_IO_FILE;
NON_MANGLED input_info_rs _Z21oc_restore_input_infoPKciiP8_IO_FILE;
const auto oc_restore_input_info = _Z21oc_restore_input_infoPKciiP8_IO_FILE;
#endif

#endif
