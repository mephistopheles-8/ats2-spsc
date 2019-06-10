(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../../HATS/project.hats"

#staload "./ringbuf.sats"

datatype spsc_status = 
  | OK
  | NoReader
  | NoWriter

vtypedef SPSC( e:vtflt, n:int) =
  @{
    ringbuf = ringbuf(e,n)
  , status = spsc_status
  }

