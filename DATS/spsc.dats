(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "share/HATS/temptory_staload_bucs320.hats"
#include "./../HATS/project.hats"

#staload "./../SATS/INTERNAL/ringbuf.sats"
#staload "./../SATS/INTERNAL/spsc.sats"
#staload "./../SATS/spsc.sats"

//absimpl spsc(e1,n) = [l:addr] aptr( SPSC(e1,n), l )

impltmp {e}
spsc_create{n}( sz ) =
  let
    val rb = ringbuf_create<e>( sz )
    val conn =(@{
        ringbuf = rb
      , status = OK()
     }) : SPSC(e,n)

  in $UN.castvwtp0{spsc(e,n)} (  ref_make_elt<SPSC(e,n)>( conn ) )
  end

impltmp {}
spsc_onread{e1}{n}( spsc, pred ) 
  = let
      val r1 = $UN.castvwtp1{[l:addr] ptr l}( spsc )
      val (prf , pf | p ) = $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

      val () = ringbuf_onread( !p.ringbuf, pred )  

      prval () = pf( prf )
     in
    end

impltmp {}
spsc_onwrite{e1}{n}( spsc, pred ) 
  = let
      val r1 = $UN.castvwtp1{[l:addr] ptr l}( spsc )
      val (prf , pf | p ) = $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

      val () = ringbuf_onwrite( !p.ringbuf, pred )  

      prval () = pf( prf )
     in
    end


impltmp {}
spsc_split{e}( ap ) =
  @( rconn , wconn )
  where { 
    val rconn = $UN.castvwtp1{rconn(e)}( ap ) 
    val wconn =  $UN.castvwtp0{wconn(e)}( ap )
  }

impltmp {e} 
conn_pair_create{n}( sz ) =
  let
    val spsc = spsc_create<e>( sz ) 
  in spsc_split( spsc )
  end

impltmp {e1}
wconn_fire( wconn, e ) =
  let
    val r1 = $UN.castvwtp1{[l:addr] ptr l}( wconn )
    val (prf , pf | p ) = $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

   fun SPSC_enqueue{n:pos}( c: &SPSC(e1,n) >> _ , e: &e1 >> opt(e1,~b) ) 
    : #[b:bool] bool b
    = ringbuf_enqueue<e1>( c.ringbuf, e ) 

    val b = SPSC_enqueue( !p, e )
  
    prval () = pf( prf ) 
  in b
  end

impltmp {e1}
wconn_fire0( wconn, e ) =
  let
    val r1 = $UN.castvwtp1{[l:addr] ptr l}( wconn )
    val (prf , pf | p ) = $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

   fun SPSC_enqueue{n:pos}( c: &SPSC(e1,n) >> _ , e: e1 ) 
    : bool
    = b
      where {
        var e0 : e1 = e
        val b = 
          ringbuf_enqueue<e1>( c.ringbuf, e0 )
        prval () = opt_clear( e0 ) 
      }
    val b = SPSC_enqueue( !p, e )
  
    prval () = pf( prf ) 
  in b
  end


impltmp {e1} 
rconn_read( rconn, e ) =
  let
    val r1 = $UN.castvwtp1{[l:addr] ptr l}( rconn )
    val (prf , pf | p ) = 
      $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

   fun SPSC_dequeue{n:pos}( c: &SPSC(e1,n) >> _ , e: &e1? >> opt(e1,b) ) 
    : #[b:bool] bool b
    = ringbuf_dequeue<e1>( c.ringbuf, e ) 

    val b = SPSC_dequeue( !p, e )
  
    prval () = pf( prf ) 
  in b
  end 

impltmp {e1}
wconn_free( rc ) =
  let
    val r1 = $UN.castvwtp1{[l:addr] ptr l}( rc )
    val (prf , pf | p ) = 
      $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

    fn SPSC_status{n:pos}( c : &SPSC(e1,n) ) : spsc_status 
      = case+ c.status of
        | OK() => ( c.status := NoWriter(); OK())
        | s =>> s 
   
    val status = SPSC_status( !p ) 
    prval () = pf( prf )
  in case+ status of
      | OK() =>   $UN.castvwtp0{void}(rc)
      | NoReader() =>
         let
            val ap = $UN.castvwtp0{
              [l:agz][n:pos] aptr(SPSC(e1,n), l)
            }( rc )
            val conn = aptr_getfree_elt<[n:pos] SPSC(e1,n)>( ap )
            val () = ringbuf_free<e1>( conn.ringbuf )
          in
         end 
      | _ => (
          $UN.castvwtp0{void}(rc);
          exit_errmsg( 1, "[actors: wconn_free] double-free detected" )
        ) // error?
       
  end

impltmp {e1}
rconn_free( rc ) =
  let
    val r1 = $UN.castvwtp1{[l:addr] ptr l}( rc )
    val (prf , pf | p ) = 
      $UN.ptr1_vtake{[n:pos] SPSC(e1,n)}( r1 )

    fn SPSC_status{n:pos}( c : &SPSC(e1,n) ) : spsc_status 
      = case+ c.status of
        | OK() => ( c.status := NoReader(); OK())
        | s =>> s 
   
    val status = SPSC_status( !p ) 
    prval () = pf( prf )
  in case+ status of
      | OK() =>   $UN.castvwtp0{void}(rc)
      | NoWriter() =>
         let
            val ap = $UN.castvwtp0{
              [l:agz][n:pos] aptr(SPSC(e1,n), l)
            }( rc )
            val conn = aptr_getfree_elt<[n:pos] SPSC(e1,n)>( ap )
            val () = ringbuf_free<e1>( conn.ringbuf )
          in
         end 
      | _ => ( 
           $UN.castvwtp0{void}(rc);
          exit_errmsg( 1, "[actors: rconn_free] double-free detected" )
        ) // error?
       
  end
