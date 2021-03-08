#ifndef WCWIDTH_COMPAT_H_INCLUDED
#define WCWIDTH_COMPAT_H_INCLUDED

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int32_t wcwidth(uint32_t ucs);

#ifdef __cplusplus
}
#endif
#endif
