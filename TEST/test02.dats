%{^
#include <pthread.h>
%}

#include "share/atspre_staload.hats"
#include "./../mylibies.hats"

staload "libats/libc/SATS/unistd.sats"

staload "libats/SATS/athread.sats"
staload _ = "libats/DATS/athread.dats"
staload _ = "libats/DATS/athread_posix.dats"

implement
gclear_ref<List0_vt(int)>(xs) = 
  list_vt_free<int>(xs)

implement main0 () = 
  println!("Hello [test02]") 
  where {


    (** To send the list back-and-forth between the two worker
        threads... **)

    val @(ra1, wa1) = conn_pair_create<List0_vt(int)>( i2sz(2) )
    val @(ra2, wa2) = conn_pair_create<List0_vt(int)>( i2sz(2) )

    (** To send the final list to the main thread **)

    val @(ra3, wa3) = conn_pair_create<List0_vt(int)>( i2sz(2) )

    (** To send note of completion to the main thread from 
        each worker thread **)

    val @(rb1, wb1) = conn_pair_create<bool>( i2sz(2) )
    val @(rb2, wb2) = conn_pair_create<bool>( i2sz(2) )

    (** Add 10 items to the list sequentially in each worker thread **)

    fun loop (
      ra1 : !rconn(List0_vt(int))
    , wa2 : !wconn(List0_vt(int))
    , n : int
    ) : void = 
      if n > 0 
      then 
        let
          var x : List0_vt(int)?
         in if rconn_read<List0_vt(int)>( ra1, x ) 
            then 
              let
                 prval () = opt_unsome( x )
                 val () = x := list_vt_cons(n,x)
                 val () = 
                      assertloc(
                        wconn_fire<List0_vt(int)>( wa2, x )
                      )
                 prval () = opt_unnone( x )
    
              in loop( ra1, wa2, n - 1) 
              end
            else loop( ra1, wa2, n )
              where {
                prval () = opt_unnone( x )
              }
        end
      else ()


    (** Wait for a worker to send the final list, then send that 
        list to the main thread **)

    fun wait_and_send_to_main( 
       ra1 : !rconn( List0_vt(int) )
     , wa3: !wconn( List0_vt(int) )
    ) : void = 
      let
        var xs : List0_vt(int)?
      in if rconn_read<List0_vt(int)>( ra1, xs )
         then 
            let
              prval () = opt_unsome( xs )
              val () 
                = assertloc(
                    wconn_fire<List0_vt(int)>( wa3, xs )
                )
              prval () = opt_unnone( xs )
            in
            end
         else wait_and_send_to_main( ra1, wa3 ) 
            where {
              prval () = opt_unnone( xs ) 
            } 
      end


    val _ 
      = athread_create_cloptr_exn( 
        llam () => 
          let
              (** Start the loop **)

              var x : List0_vt(int) = list_vt_nil()
              val () = assertloc( 
                  wconn_fire<List0_vt(int)>(wa2, x)
                )
              prval () = opt_unnone( x )
           in
              loop( ra1, wa2, 10 );
              rconn_free<List0_vt(int)>(ra1);
              wconn_free<List0_vt(int)>(wa2);
              assertloc( wconn_fire0<bool>( wb1, true ) );
              wconn_free<bool>(wb1);
           end 
       )

    val _ 
      = athread_create_cloptr_exn( 
          llam () => 
            let
             in 
                loop( ra2, wa1, 10 );

                wait_and_send_to_main( ra2, wa3 );
                wconn_free<List0_vt(int)>(wa3);

                rconn_free<List0_vt(int)>(ra2);
                wconn_free<List0_vt(int)>(wa1);
                assertloc( wconn_fire0<bool>( wb2, true ) );
                wconn_free<bool>(wb2);
            end 
        )

    (** Each time a worker sends a note of completion,
        increment the counter by one **)
    fn rcheck{n:nat}(
            rb1 : !rconn( bool )
          , x : &int n >> int m  )
      : #[m:nat | m == n || m == n + 1] void =
        let
          var b1 : bool? 
         in if rconn_read<bool>( rb1, b1 ) 
            then let
                prval () = opt_unsome( b1  )
                prval () = topize( b1 ) 
                val () = x := x + 1
              in end
             else let
                prval () = opt_unnone( b1 ) 
              in end
         end 

    var x : [n:nat] int n = 0

    (** There are two workers...busy-wait until they have sent confirmation **)

    val () = while( x < 2  ) (
         rcheck( rb1, x );     
         rcheck( rb2, x );     
      )

    var xs : List0_vt(int)
    
    val () = assertloc( rconn_read<List0_vt(int)>( ra3, xs ) )
    prval () = opt_unsome( xs )

    (** Print the resulting list.
        Should be 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10 
    **)

    val () = print_list_vt<int>( xs )
    val () = print_newline()

    val () = list_vt_free<int>( xs )

    (** Clear remaining connections **)

    val () = rconn_free<List0_vt(int)>(ra3);
    val () = rconn_free<bool>(rb1)
    val () = rconn_free<bool>(rb2)

  }
