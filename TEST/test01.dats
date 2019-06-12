(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "share/atspre_staload.hats"
#include "./../mylibies.hats"

implement main0 () 
  = println!("Hello [test01]")
  where {


    val q  = spsc_create<int>( i2sz( 5 ) )
    val () = spsc_onread( q, lam() => println!("Read") )
    val () = spsc_onwrite( q, lam() => println!("Write") )

    val @(rconn, wconn) = spsc_split( q )

    val _ = assertloc( wconn_fire0<int>( wconn, 0 )  )
    val _ = assertloc( wconn_fire0<int>( wconn, 1 )  )

    val () = wconn_onwrite( wconn, lam() => println!("Write 2") )
 
    val _ = assertloc( wconn_fire0<int>( wconn, 2 )  )
    val _ = assertloc( wconn_fire0<int>( wconn, 3 )  )

    var x : int
    val _ = assertloc( rconn_read<int>( rconn, x )  )
    prval () = opt_unsome( x )
    val () = assertloc( x = 0 )
    prval () = topize( x )
    
    val _ = assertloc( rconn_read<int>( rconn, x )  )
    prval () = opt_unsome( x )
    val () = assertloc( x = 1 )
    prval () = topize( x )
    
    val () = rconn_onread( rconn, lam() => println!("Read 2") ) 

    val _ = assertloc( rconn_read<int>( rconn, x )  )
    prval () = opt_unsome( x )
    val () = assertloc( x = 2 )
    prval () = topize( x )
    
    val _ = assertloc( rconn_read<int>( rconn, x )  )
    prval () = opt_unsome( x )
    val () = assertloc( x = 3 )
    prval () = topize( x )
    
    val _ = assertloc( ~rconn_read<int>( rconn, x )  )
    prval () = opt_unnone( x )
    prval () = topize( x )

    val () = rconn_free<int>( rconn )
    val () = wconn_free<int>( wconn )
  }


