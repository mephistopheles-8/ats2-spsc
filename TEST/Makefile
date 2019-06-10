

TEMPHOMEQ="$(TEMPTORY)"

RMF=rm -f

TEMPCC=$(TEMPHOMEQ)/bin/tempacc

TEMPFLAGS=-DATS_MEMALLOC_LIBC
CFLAGS=-O2 -D_SPSC_STDATOMIC
LFLAGS=-lpthread

all:: test01
test01: test01.dats ; $(TEMPCC) $(TEMPFLAGS) $(CFLAGS) -o $@ $< $(LFLAGS) 
cleanall:: ; $(RMF) test01

all:: test02
test02: test02.dats ; $(TEMPCC) $(TEMPFLAGS) $(CFLAGS) -o $@ $< $(LFLAGS) 
cleanall:: ; $(RMF) test02

cleanall:: ; $(RMF) *_*ats.c

clean:: cleanall
