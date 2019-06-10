(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../../HATS/project.hats"


typedef sizeLt(n:int) = [m:nat | m < n ] size m

vtypedef ringbuf(a:vtflt,n:int) 
  = @{
     array = cptr(a)
   , head  = sizeLt(n)
   , tail  = sizeLt(n)
   , size  = size n
   , onread  = optn0_vt( () -<cloptr1> void ) 
   , onwrite = optn0_vt( () -<cloptr1> void ) 
  }

fun {a:vtflt}
  ringbuf_free$clear( &a >> a? ) : void

fun {a:vtflt} 
  ringbuf_free{n:pos}( rb: ringbuf(a,n) ) 
  : void

fun {a:vtflt} 
  ringbuf_create{n:pos}( sz: size n ) 
  : ringbuf(a,n)

fun {a:vtflt} 
  ringbuf_enqueue{n:pos}( rb: &ringbuf(a,n), x: &a >> opt(a,~b) )
  : #[b:bool] bool b

fun {a:tflt} 
  ringbuf_enqueue0{n:pos}( rb: &ringbuf(a,n), x: a )
  : bool

fun {a:vtflt} 
  ringbuf_dequeue{n:pos}( rb: &ringbuf(a,n), x: &a? >> opt(a,b) )
  : #[b:bool] bool b

fun {} 
  ringbuf_onread{n:pos}{a:vtflt}( rb: &ringbuf(a,n), pred : () -<cloptr1> void )
  : void 

fun {} 
  ringbuf_onwrite{n:pos}{a:vtflt}( rb: &ringbuf(a,n), pred : () -<cloptr1> void  )
  : void


