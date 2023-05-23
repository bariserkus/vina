#Options common to both x86 & risc-v platforms
C_PLATFORM= -DNDEBUG -pthread
BASE=/usr
BOOST_VERSION=
BOOST_LIB_VERSION=
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags | sed 's/dirty/mod/g')
ifeq (,$(GIT_VERSION))
  GIT_VERSION := v1.2.3
endif

LIBS = -l boost_system${BOOST_LIB_VERSION} -l boost_thread${threadmt}${BOOST_LIB_VERSION} -l boost_serialization${BOOST_LIB_VERSION} -l boost_filesystem${BOOST_LIB_VERSION} -l boost_program_options${BOOST_LIB_VERSION}

#Options specific to x86 and risc-v platforms
CPU:=$(shell uname -p)
$(info CPU is $(CPU))
ifeq ($(CPU),x86_64)
  BOOST_INCLUDE=$(BASE)/include
  INCFLAGS = -I $(BOOST_INCLUDE)
  LDFLAGS= -L$(BASE)/lib -L.

  #First Built:
  GPP_A=g++
  C_OPTIONS_A= -g -std=c++14
  C_OPTIONS_A+=-DVERSION=\"$(GIT_VERSION)\"
  C_OPTIONS_A+=-DMAKETYPE=\"$(CPU)_A\"
  C_OPTIONS_A+=-DFLTYPE=double
  CC_A = ${GPP_A} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_A} $(INCFLAGS)
  ########

else
  BOOST_INCLUDE=/home/aali2/include
  INCFLAGS = -I $(BOOST_INCLUDE)
  LDFLAGS= -L$(BASE)/lib -L. -L/home/aali2/lib

  #First Built:
  GPP_A=clang++
  C_OPTIONS_A= -g -std=c++14 -march=rv64g -mepi -mcpu=avispado -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize
  C_OPTIONS_A+=-DVERSION=\"$(GIT_VERSION)\"
  C_OPTIONS_A+=-DMAKETYPE=\"$(CPU)_A\"
  C_OPTIONS_A+=-DFLTYPE=double
  CC_A = ${GPP_A} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_A} $(INCFLAGS)
  #######
endif

LIBOBJ_A = A_ad4cache.o A_cache.o A_non_cache.o A_conf_independent.o A_coords.o A_grid.o A_szv_grid.o A_model.o A_monte_carlo.o A_mutate.o A_parallel_mc.o A_parse_pdbqt.o A_quasi_newton.o A_quaternion.o A_random.o A_utils.o A_vina.o
MAINOBJ_A = A_main.o

all: vina_A_single

#First Built
A_%.o : ../../../src/lib/%.cpp
	$(CC_A) -o $@ -c $<

A_%.o : ../../../src/main/main.cpp
	$(CC_A) -I ../../../src/lib -o $@ -c $<

vina_A_single: $(MAINOBJ_A) $(LIBOBJ_A)
	$(CC_A) $(LDFLAGS) -o $@ $^ $(LIBS)
###########

clean:
	rm -f *.o
	rm -f vina_A_single
