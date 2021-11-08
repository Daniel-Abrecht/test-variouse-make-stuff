ifndef ARCH
ARCH="$(shell $(CC) -dumpmachine | grep -o '^[^-]*')"
endif

ifeq ($(ARCH),)
$(warning "Couldn't figure out target architecture. Consider setting ARCH.")
endif

HEADERS    := $(shell find include -type f -name "*.h" -not -name ".*")
SOURCES    := $(shell find src -type f -not -name ".*" -not -path "*@*" -not -iname "bm.*") \
              $(shell find src -type f -not -name ".*" -path "*@$(ARCH)*" -not -iname "bm.*")
SOURCES_BM := $(shell find src -type f -not -name ".*" -not -path "*@*" -iname "bm.*.benchmark.c") \
              $(shell find src -type f -not -name ".*" -path "*@$(ARCH)*" -iname "bm.*.benchmark.c")
TARGETS    := $(patsubst src/main/%.c,bin/%,$(wildcard src/main/*.c))
OBJECTS    := $(patsubst %,build/o/%.o,$(SOURCES))
BENCHMARKS := $(patsubst %,build/benchmark/%.o,$(SOURCES_BM))

CFLAGS  += -O2

ifdef asan
CFLAGS  += -fsanitize=address
LDFLAGS += -fsanitize=address
endif

CFLAGS   += --std=c11
CFLAGS   += -fPIE

CFLAGS  += -Iinclude
CFLAGS  += -Wall -Wextra -pedantic -Werror
#CFLAGS  += -D_FILE_OFFSET_BITS=64 -D_DEFAULT_SOURCE
CFLAGS  += -ffunction-sections -fdata-sections
#CFLAGS  += -fstack-protector-all

ASFLAGS =

LDFLAGS +=  -Wl,--gc-sections

LDLIBS += -lm

all: $(TARGETS)

.SECONDARY:

bin/%: build/o/src/main/%.c.o build/all.a build/benchmarked.a
	mkdir -p $(dir $@)
	$(CC) -o $@ $(LDFLAGS) -Wl,--whole-archive $^ -Wl,--no-whole-archive $(LOADLIBES) $(LDLIBS)

build/benchmark/%.c.o: build/benchmark/%
	best="$$(head -n 1 "$<" | sed "s/[^ ]* //")"; \
	ln -rsf "$$best" "$@"

build/benchmark/%: build/o/%.c.o build/all.a
	mkdir -p $(dir $@)
	set -ex; \
	bmo="$(patsubst %,build/o/%.o,$(shell find src/ -iname "$$(basename "$@" .benchmark).*.*" -not -iname "bm.*.benchmark.c"))"; \
	[ -n "$$bmo" ]; \
	$(MAKE) $$bmo; \
	for bm in $$bmo; \
	do \
	  bmbin="$(dir $@)/$$(basename "$$bm" .c.o)"; \
	  $(CC) -o "$$bmbin" $(LDFLAGS) -Wl,--whole-archive "$$bm" $^ -Wl,--no-whole-archive $(LOADLIBES) $(LDLIBS); \
	  echo "$$("$$bmbin") $$bm"; \
	done | sort -h >"$@"

build/o/%.c.o: %.c $(HEADERS) makefile
	mkdir -p $(dir $@)
	$(CC) -c -o $@ $(CFLAGS) $<

build/o/%.s.o: %.s $(HEADERS) makefile
	mkdir -p $(dir $@)
	if ! $(AS) $(ASFLAGS) -o $@ $(ASFLAGS) $<; \
	  then $(CC) -c -o $@ -x c /dev/null; \
	fi

build/all.a: $(filter-out build/o/src/main/%,$(OBJECTS))
	rm -f $@
	$(AR) qs $@ $^

build/benchmarked.a: $(filter-out build/o/src/main/%,$(BENCHMARKS))
	rm -f $@
	$(AR) qs $@ $^

clean:
	rm -rf build bin
