LDFLAGS=`pkg-config --cflags --libs libpipewire-0.3`
CFLAGS=-march=native -g -c -Wall -O3

.PHONY :  spec clean all build init example

all : 	build spec

spec  : build
	rm -rf .test
	mkdir -p .test
	crystal spec --error-trace

build : init
	cc $(CFLAGS) -c -o build/shim.o src/c/shim.c -lm $(LDFLAGS)

clean :
	rm build/*

init :
	mkdir -p build

