(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../../HATS/project.hats"

%{#
#ifndef _SPSC_INTERNAL_ATOMIC_SATS
#define _SPSC_INTERNAL_ATOMIC_SATS

#ifdef _SPSC_STDATOMIC

#include <stdatomic.h>
#define spsc_atomic_read(p) atomic_load((atstype_size*)p)
#define spsc_atomic_write(p,v) atomic_store((atstype_size*)p, v)

#elif defined( _SPSC_ATOMIC_BUILTIN )

#define spsc_atomic_read(p) __atomic_load_n((atstype_size*)p, __ATOMIC_RELAXED )
#define spsc_atomic_write(p,v) __atomic_store_n((atstype_size*)p, v, __ATOMIC_RELAXED )

#elif defined( _SPSC_SYNC_BUILTIN )

#define spsc_atomic_read(p) __sync_fetch_and_add((atstype_size*)p, 0)

#define spsc_atomic_write(p,v) \
{ \
  do { \
  } while(  __sync_bool_compare_and_swap( (atstype_size*)p, spsc_atomic_read( (atstype_size*)p ), v ) == 0 );\
} 


#endif

#endif
%}

fn atomic_read{n:nat}( &size_t n ) : size_t n = "mac#%" 

fn atomic_write{n,m:nat}( &size_t n >> size_t m, size_t m ) : void = "mac#%" 

