(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../HATS/project.hats"

absvtbox rconn( e1: vtflt ) = ptr 
absvtbox wconn( e1: vtflt ) = ptr

vtypedef rconn0 = [e:vtflt] rconn(e)
vtypedef wconn0 = [e:vtflt] wconn(e)

absvtbox spsc( e1:vtflt, n:int ) = ptr 

fun {e:vtflt}
   spsc_create{n:pos}( sz: size n )
  : spsc( e, n )

fun {} spsc_onread{e:vtflt}{n:nat}( !spsc(e,n), () -<cloptr1> void ) 
  : void 

fun {} spsc_onwrite{e:vtflt}{n:nat}( !spsc(e,n), () -<cloptr1> void ) 
  : void 

fun {} spsc_split{e:vtflt}{n:nat}( spsc(e,n) ) : @( rconn(e), wconn(e) )

// get rid of the tuple return ; they are the same value
fun {e1:vtflt} 
 conn_pair_create{n:pos}(
     sz: size n
) :  @(rconn(e1), wconn(e1))

fun {e1:vtflt}
  wconn_fire( !wconn( e1 ), &e1 >> opt(e1,~b) ) : #[b:bool] bool b

fun {e1:tflt}
  wconn_fire0( !wconn( e1 ), e1 ) : bool

fun {e1:vtflt}
  rconn_read( !rconn( e1 ), e : &e1? >> opt(e1,b) ) : #[b:bool] bool b

fun {e1:vtflt}
  rconn_free( rconn( e1 ) )
  : void

fun {e1:vtflt}
  wconn_free( wconn( e1 ) )
  : void


