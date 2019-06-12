(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../../HATS/project.hats"

vtypedef ringbuf(a:vt@ype+,n:int) 
  = @{
     array = ptr
   , head  = sizeLt(n)
   , tail  = sizeLt(n)
   , size  = size_t n
   , onread  =  () -<cloptr1> void  
   , onwrite =  () -<cloptr1> void  
  }

fun {a:vt@ype+}
  ringbuf_free$clear( &a >> a? ) : void

fun {a:vt@ype+} 
  ringbuf_free{n:pos}( rb: ringbuf(a,n) ) 
  : void

fun {a:vt@ype+} 
  ringbuf_create{n:pos}( sz: size_t n ) 
  : ringbuf(a,n)

fun {a:vt@ype+} 
  ringbuf_enqueue{n:pos}( rb: &ringbuf(a,n), x: &a >> opt(a,~b) )
  : #[b:bool] bool b

fun {a:t@ype+} 
  ringbuf_enqueue0{n:pos}( rb: &ringbuf(a,n), x: a )
  : bool

fun {a:vt@ype+} 
  ringbuf_dequeue{n:pos}( rb: &ringbuf(a,n), x: &a? >> opt(a,b) )
  : #[b:bool] bool b

fun {} 
  ringbuf_onread{n:pos}{a:vt@ype+}( rb: &ringbuf(a,n), pred : () -<cloptr1> void )
  : void 

fun {} 
  ringbuf_onwrite{n:pos}{a:vt@ype+}( rb: &ringbuf(a,n), pred : () -<cloptr1> void  )
  : void


