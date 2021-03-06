# spsc: lock-free queues for ATS2

__This is only lightly tested: use at your own risk.__

This is a simple model for lock-free, finite-size, single-producer / single-consumer queues for ATS2.

SPSC queues have several nice properties; only a small portion of memory is actually shared
and contention for those resources is limited to at most 2 threads.

Please see the `TEST` directory for usage examples.

## The Interface

First, the connections are created.  They are actually duplicate pointers
to the same data structure; the lock-free queue. 

```ats2
    #define BUFSZ 256

    val (rconn, wconn) = conn_pair_create<evt_type>( i2sz(BUFSZ) )

```

The connection is modelled with linear types.  Assuming the use of *linear closures* 
for work on threads (eg, what the libats `athread` API uses), we have two options:

i. Use both connections on the same thread.
ii. Use the read-connection on one thread and the write-connection on another.

These are both valid cases. 

Because the linear closure will *consume* the variable, the type-system guarantees that 
we cannot share the same connection on two threads at the same time. This way, we can 
make various safe assumptions about ownership in the implementation.

The connections are used like so:
 
Firing an event:

```ats2

    val _ = if wconn_fire0<evt_type>( wconn, myevt )
            then ((** Succeeded **))
            else ((** Failed **))

``` 

Reading an event:

```ats2
    var ev : evt_type
 
    val b = rconn_read<evt_type>( rconn, ev )
    val _ = if b
           then { (** Succeeded **) prval () = opt_unsome( ev ) .... }
           else { (** Failed **) prval () = opt_unnone( ev ) .... }
``` 

Right now both operations will return a bool; it is up to the user how to handle failed messages.

The original queue will be freed once both connections are freed.

## Compiling

C11 has not been adopted by everyone, so you may want to use compiler-specific builtins.
I would not advise using `__sync_*` builtins unless you really need to.

It is necessary to specify at least one of the following flags during compilation:

1. `-D_SPSC_STDATOMIC` : Use C11 `stdatomic.h`
2. `-D_SPSC_ATOMIC_BUILTIN` : Use GCC/Clang `__atomic_*` builtins
3. `-D_SPSC_SYNC_BUILTIN` : Use GCC `__sync_*` builtins.  (These bindings might need some work). 

License: MIT

