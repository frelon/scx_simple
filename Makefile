BPFTOOL     ?= /usr/sbin/bpftool
LIBBPF      ?= /usr/lib64/libbpf.so.1
CC_ARGS     ?= -g -O2 -Wall -Wno-compare-distinct-pointer-types -I /usr/include/scx
BPF_CC_ARGS ?= -g -O2 -Wall -Wno-compare-distinct-pointer-types -D__TARGET_ARCH_x86_64 -mcpu=v3 -I ./
CC           = clang

.PHONY: all
all: scx_simple 

scx_simple: scx_simple.bpf.skel.h
	$(CC) $(CC_ARGS) -o scx_simple scx_simple.c $(LIBBPF)

scx_simple.bpf.skel.h: scx_simple.bpf.o
	./bpftool_build_skel $(BPFTOOL) scx_simple.bpf.o scx_simple.bpf.skel.h scx_simple.bpf.subskel.h

scx_simple.bpf.o: vmlinux.h
	$(CC) $(BPF_CC_ARGS) -target bpf -c scx_simple.bpf.c -o scx_simple.bpf.o

vmlinux.h:
	$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

.PHONY: clean
clean:
	rm -f scx_simple
	rm -f scx_simple.bpf.skel.h
	rm -f scx_simple.bpf.subskel.h
	rm -f scx_simple.bpf.l1o
	rm -f scx_simple.bpf.l2o
	rm -f scx_simple.bpf.l3o
	rm -f scx_simple.bpf.o
