// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// interp.cpp
void fun();
extern "C" SEXP _geocoder_fun() {
  BEGIN_CPP11
    fun();
    return R_NilValue;
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_geocoder_fun", (DL_FUNC) &_geocoder_fun, 0},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_geocoder(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
