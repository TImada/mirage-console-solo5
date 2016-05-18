.PHONY: all clean install build
all: build doc

J=2

ENABLE_MIRAGE_XEN ?= $(shell if ocamlfind query mirage-xen xenstore >/dev/null 2>&1; then echo --enable-miragexen; else echo --disable-miragexen; fi)
ENABLE_XEN ?= $(shell if ocamlfind query xen-gnt.unix xenstore_transport >/dev/null 2>&1; then echo --enable-xen; else echo --disable-xen; fi)
ENABLE_XENCTRL ?= $(shell if ocamlfind query xen-evtchn.unix.activations xen-evtchn.unix xen-gnt.unix >/dev/null 2>&1; then echo --enable-xenctrl; else echo --disable-xenctrl; fi)
ENABLE_UNIX ?= --enable-unix
ENABLE_SOLO5 ?= --enable-solo5
PREFIX ?= /usr/local/bin

export OCAMLRUNPARAM=b

setup.bin: setup.ml
	@ocamlopt.opt -o $@ $< || ocamlopt -o $@ $< || ocamlc -o $@ $<
	@rm -f setup.cmx setup.cmi setup.o setup.cmo

setup.data: setup.bin
	./setup.bin -configure $(ENABLE_XENCTRL) $(ENABLE_MIRAGE_XEN) $(ENABLE_XEN) $(ENABLE_UNIX) $(ENABLE_SOLO5) --enable-tests --prefix $(PREFIX)

build: setup.data setup.bin
	@./setup.bin -build -j $(J)

doc: setup.data setup.bin
	@./setup.bin -doc -j $(J)

install: setup.bin
	@./setup.bin -install

uninstall:
	@./setup.bin -uninstall

test: setup.bin build
	./setup.bin -test

reinstall: setup.bin
	@./setup.bin -reinstall

clean:
	@ocamlbuild -clean
	@rm -f setup.data setup.log setup.bin
