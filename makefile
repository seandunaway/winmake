scmake = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

llvm ?= https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.0-rc2/LLVM-19.1.0-rc2-macOS-ARM64.tar.xz
xwin ?= https://github.com/Jake-Shadle/xwin/releases/download/0.6.5/xwin-0.6.5-aarch64-apple-darwin.tar.gz

CXX = $(scmake)llvm/bin/clang
CXXFLAGS += -target $(arch)-pc-windows-msvc -O3 -fuse-ld=lld
CXXFLAGS += -Weverything -Wno-unused-parameter
CXXFLAGS += $(addprefix -isystem, $(header))
LDFLAGS += $(addprefix -L, $(addsuffix /$(arch), $(library)))
LDLIBS += -lkernel32 -luser32 -lgdi32

header += $(scmake)xwin/splat/crt/include
header += $(shell find $(scmake)xwin/splat/sdk/include -maxdepth 1 -type d)
library += $(scmake)xwin/splat/crt/lib
library += $(shell find $(scmake)xwin/splat/sdk/lib -maxdepth 1 -type d)

src = $(wildcard *.c)
aarch64 = $(src:.c=_a64.exe)
x86_64 = $(src:.c=_x64.exe)

default: dependency aarch64 x86_64

aarch64: arch = aarch64
aarch64: $(aarch64)
%_a64.exe: %.c
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

x86_64: arch = x86_64
x86_64: $(x86_64)
%_x64.exe: %.c
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f $(aarch64) $(aarch64:.exe=.pdb) $(x86_64) $(x86_64:.exe=.pdb)

dependency: $(scmake)llvm $(scmake)xwin

$(scmake)llvm:
	curl -Ls $(llvm) > $@.tar.xz
	mkdir $@
	tar -xf $@.tar.xz -C $@ --strip-components=1
	rm $@.tar.xz

$(scmake)xwin:
	curl -Ls $(xwin) > $@.tar.gz
	mkdir $@
	tar -zxf $@.tar.gz -C $@ --strip-components=1
	rm $@.tar.gz
	$@/xwin --accept-license --arch aarch64,x86_64 --cache-dir $@ --sdk-version 10.0.22621 splat --disable-symlinks --include-debug-libs --include-debug-symbols

purge:
	rm -rf $(scmake)llvm $(scmake)xwin $(scmake)llvm.tar.xz $(scmake)xwin.tar.gz

.PHONY: default aarch64 x86_64 clean dependency purge
