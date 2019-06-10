(** 
 ** Project : spsc
 ** Author  : Mark Bellaire
 ** Year    : 2019
 ** License : MIT
*)

#include "./../HATS/project.hats"

absvtype rconn( e1: vt@ype+ ) = ptr 
absvtype wconn( e1: vt@ype+ ) = ptr

vtypedef rconn0 = [e:vt@ype+] rconn(e)
vtypedef wconn0 = [e:vt@ype+] wconn(e)

absvtype spsc( e1:vt@ype+, n:int ) = ptr 

fun {e:vt@ype+}
   spsc_create{n:pos}( sz: size_t n )
  : spsc( e, n )

fun {} spsc_onread{e:vt@ype+}{n:nat}( !spsc(e,n), () -<cloptr1> void ) 
  : void 

fun {} spsc_onwrite{e:vt@ype+}{n:nat}( !spsc(e,n), () -<cloptr1> void ) 
  : void 

fun {} spsc_split{e:vt@ype+}{n:nat}( spsc(e,n) ) : @( rconn(e), wconn(e) )

// get rid of the tuple return ; they are the same value
fun {e1:vt@ype+} 
 conn_pair_create{n:pos}(
     sz: size_t n
) :  @(rconn(e1), wconn(e1))

fun {e1:vt@ype+}
  wconn_fire( !wconn( e1 ), &e1 >> opt(e1,~b) ) : #[b:bool] bool b

fun {e1:t@ype+}
  wconn_fire0( !wconn( e1 ), e1 ) : bool

fun {e1:vt@ype+}
  rconn_read( !rconn( e1 ), e : &e1? >> opt(e1,b) ) : #[b:bool] bool b

fun {e1:vt@ype+}
  rconn_free( rconn( e1 ) )
  : void

fun {e1:vt@ype+}
  wconn_free( wconn( e1 ) )
  : void


