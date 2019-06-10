(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "share/HATS/temptory_staload_bucs320.hats"

#include "./../HATS/project.hats"

#staload "./../SATS/INTERNAL/ringbuf.sats"
#staload "./../SATS/INTERNAL/atomic.sats"

impltmp {a}
ringbuf_create{n}( sz ) =
  let
    var rb : ringbuf(a,n)
    val () = (
      rb.array := $UN.castvwtp0{cptr(a)}( 
        arrayptr_make_none<a>(sz)
      );
      rb.head := i2sz(0);
      rb.tail := i2sz(0);
      rb.size := sz;
      rb.onread := none_vt();
      rb.onwrite := none_vt();
    )
  in rb
  end


#macdef cloptr_free( f ) =
 cloptr_free($UN.castvwtp0{cloptr(void)}(,(f))) 

fun {} ringbuf_call_onread{a:vtflt}{n:nat}( rb: &ringbuf(a,n) ) 
  : void = 
    case+ rb.onread of
    | some_vt( p ) => p()
    | none_vt() => ()

fun {} ringbuf_call_onwrite{a:vtflt}{n:nat}( rb: &ringbuf(a,n) ) 
  : void = 
    case+ rb.onwrite of
    | some_vt( p ) => p()
    | none_vt() => ()

impltmp (a:tflt)
ringbuf_free$clear<a>( x ) = () where { prval () = topize( x ) }

impltmp (a:vtflt)
ringbuf_free$clear<a>( x ) = gclear_ref<a>(x) 

impltmp {a}
ringbuf_free{n}( rb ) =
  let
    var rb : ringbuf(a,n) = rb
    (** Clear all events **)
    fun loop{n:pos}( rb: &ringbuf( a, n ) )
      : void =
      let
        var x : a?
      in if ringbuf_dequeue<a>(rb, x) 
         then
          let 
            prval () = opt_unsome( x )
            val () = ringbuf_free$clear( x )
           in loop( rb )
          end
         else 
          let
            prval () = opt_unnone(x) 
           in ()
          end
      end
    val () = loop( rb )
    val () 
      = case+ rb.onread of
         | ~some_vt( f )  => cloptr_free(f)
         | ~none_vt(  )  => ()
    
    val () 
      = case+ rb.onwrite of
         | ~some_vt( f )  => cloptr_free(f)
         | ~none_vt(  )  => ()
    
  in $extfcall( void, "atspre_mfree_gc", rb.array ) 
  end

// it's safe to read rb.head; the enqueueing thread
// is the only writer. It's not safe to *write*
// to rb.head, because it could be read by multiple 
// threads 

impltmp {a}
ringbuf_enqueue( rb, x ) =
  let
    val h = (rb.head + 1) mod rb.size
  in if h = atomic_read(rb.tail)  // the queue is full 
     then false where {
        prval () = opt_some( x )
      }
     else (
      atomic_write(rb.head,  h);
      ringbuf_call_onwrite( rb );
      true;
    ) where {
      
      val _ = 
        $UN.cptr0_set<a>( rb.array + rb.head, x );
      prval () = opt_none( x )
    } 
  end

// for tflt

impltmp {a}
ringbuf_enqueue0( rb, x ) =
  let
    val h = (rb.head + 1) mod rb.size
  in if h = atomic_read(rb.tail)  // the queue is full 
     then false 
     else (
      atomic_write(rb.head,  h);
      ringbuf_call_onwrite( rb );
      true;
    ) where {
      val _ = 
        $UN.cptr0_set<a>( rb.array + rb.head, x );
    } 
  end

// it's safe to read rb.tail; the dequeing thread
// is the only writer. It's not safe to *write*
// to rb.tail, because it could be read by multiple 
// threads 

impltmp {a}
ringbuf_dequeue( rb, x ) =
  if rb.tail = atomic_read(rb.head) // The queue is empty
  then 
    let
      prval () = opt_none( x )
     in false
    end 
  else 
    let
      val () = x :=  
        $UN.cptr0_get<a>( rb.array + rb.tail )
      val () = atomic_write(rb.tail,  (rb.tail + 1) mod rb.size )
      val ()  = ringbuf_call_onread(rb)
      prval () = opt_some( x )
    in true
    end

impltmp {}
ringbuf_onread( rb, pred )  =
  case+ rb.onread of
  | ~some_vt( p ) => 
      let
        val () = cloptr_free( p )
       in rb.onread := some_vt( pred )
      end
  | ~none_vt( ) => rb.onread := some_vt( pred ) 


impltmp {}
ringbuf_onwrite( rb, pred )  =
  case+ rb.onwrite of
  | ~some_vt( p ) => 
      let
        val () = cloptr_free( p )
       in rb.onwrite := some_vt( pred )
      end
  | ~none_vt( ) => rb.onwrite := some_vt( pred ) 




