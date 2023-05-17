#Options common to both x86 & risc-v platforms
C_PLATFORM= -static -DNDEBUG -pthread
BASE=/usr
BOOST_VERSION=
BOOST_LIB_VERSION=

#Options specific to x86 and risc-v platforms
CPU:=$(shell uname -p)
$(info CPU is $(CPU))
ifeq ($(CPU),x86_64)
  BOOST_INCLUDE=$(BASE)/include
  GPP=g++
  C_OPTIONS= -g -std=c++14 -O3
  LDFLAGS = -L$(BASE)/lib -L.
else
  BOOST_INCLUDE=/home/aali2/include
  GPP=g++
  #GPP=clang++
  C_OPTIONS= -g -std=c++14 -O3
  #C_OPTIONS= -g -std=c++14 -O3 -march=rv64g -mepi -O3 -fno-vectorize -mcpu=avispado -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize
  LDFLAGS = -L$(BASE)/lib -L. -L/home/aali2/lib
endif

LIBOBJ = ad4cache.o cache.o non_cache.o conf_independent.o coords.o grid.o szv_grid.o model.o monte_carlo.o mutate.o parallel_mc.o parse_pdbqt.o quasi_newton.o quaternion.o random.o utils.o vina.o
MAINOBJ = main.o

INCFLAGS = -I $(BOOST_INCLUDE)

GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags | sed 's/dirty/mod/g')
ifeq (,$(GIT_VERSION))
  GIT_VERSION := v1.2.3
endif

C_OPTIONS+=-DVERSION=\"$(GIT_VERSION)\"

CC = ${GPP} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS} $(INCFLAGS)

ifeq ($(BOOST_STATIC), y)
  LIBS = ${BASE}/lib/libboost_system${BOOST_LIB_VERSION}.a ${BASE}/lib/libboost_thread${threadmt}${BOOST_LIB_VERSION}.a ${BASE}/lib/libboost_serialization${BOOST_LIB_VERSION}.a ${BASE}/lib/libboost_filesystem${BOOST_LIB_VERSION}.a ${BASE}/lib/libboost_program_options${BOOST_LIB_VERSION}.a ${BASE}/lib/libboost_timer${BOOST_LIB_VERSION}.a
else
  LIBS = -l boost_system${BOOST_LIB_VERSION} -l boost_thread${threadmt}${BOOST_LIB_VERSION} -l boost_serialization${BOOST_LIB_VERSION} -l boost_filesystem${BOOST_LIB_VERSION} -l boost_program_options${BOOST_LIB_VERSION}  -lboost_timer  #-l pthread
endif

.SUFFIXES: .cpp .o

%.o : ../../../src/lib/%.cpp
	$(CC) $(CFLAGS) -o $@ -c $<

%.o : ../../../src/design/%.cpp
	$(CC) $(CFLAGS) -I ../../../src/lib -o $@ -c $<

%.o : ../../../src/main/%.cpp
	$(CC) $(CFLAGS) -I ../../../src/lib -o $@ -c $<

all: vina

include dependencies

vina: $(MAINOBJ) $(LIBOBJ)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f *.o

depend:
	ln -sf `${GPP} -print-file-name=libstdc++.a`
	rm -f dependencies_tmp dependencies_tmp.bak
	touch dependencies_tmp
	makedepend -f dependencies_tmp -Y -I ../../../src/lib ../../../src/lib/*.cpp ../../../src/tests/*.cpp ../../../src/design/*.cpp ../../../src/main/*.cpp ../../../src/split/*.cpp  ../../../src/tune/*.cpp
	sed -e "s/^\.\.\/\.\.\/\.\.\/src\/[a-z]*\//.\//" dependencies_tmp > dependencies
	rm -f dependencies_tmp dependencies_tmp.bak