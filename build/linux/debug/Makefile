#Options common to both x86 & risc-v platforms
C_PLATFORM= -static -DNDEBUG -pthread
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

  #First Built:
  INCFLAGS = -I $(BOOST_INCLUDE)
  GPP_A=g++
  C_OPTIONS_A= -g -std=c++14 -O3
  C_OPTIONS_A+=-DVERSION=\"$(GIT_VERSION)\"
  CC_A = ${GPP_A} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_A} $(INCFLAGS)
  ########

  #Second Built:
  INCFLAGS = -I $(BOOST_INCLUDE)
  GPP_B=icpx
  C_OPTIONS_B= -g -std=c++14 -O3
  C_OPTIONS_B+=-DVERSION=\"$(GIT_VERSION)\"
  CC_B = ${GPP_B} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_B} $(INCFLAGS)
  ########

  LDFLAGS= -L$(BASE)/lib -L.
else
  BOOST_INCLUDE=/home/aali2/include

  #First Built:
  GPP=g++
  #GPP=clang++
  C_OPTIONS= -g -std=c++14 -O3
  #C_OPTIONS= -g -std=c++14 -O3 -march=rv64g -mepi -O3 -fno-vectorize -mcpu=avispado -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize
  INCFLAGS = -I $(BOOST_INCLUDE)
  C_OPTIONS+=-DVERSION=\"$(GIT_VERSION)\"
  CC = ${GPP} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS} $(INCFLAGS)
  LDFLAGS= -L$(BASE)/lib -L. -L/home/aali2/lib
endif

LIBOBJ_A = A_ad4cache.o A_cache.o A_non_cache.o A_conf_independent.o A_coords.o A_grid.o A_szv_grid.o A_model.o A_monte_carlo.o A_mutate.o A_parallel_mc.o A_parse_pdbqt.o A_quasi_newton.o A_quaternion.o A_random.o A_utils.o A_vina.o
MAINOBJ_A = A_main.o

LIBOBJ_B = B_ad4cache.o B_cache.o B_non_cache.o B_conf_independent.o B_coords.o B_grid.o B_szv_grid.o B_model.o B_monte_carlo.o B_mutate.o B_parallel_mc.o B_parse_pdbqt.o B_quasi_newton.o B_quaternion.o B_random.o B_utils.o B_vina.o
MAINOBJ_B = B_main.o

all: vina_A vina_B

A_%.o : ../../../src/lib/%.cpp
	$(CC_A) -o $@ -c $<
#	$(CC_B) -o $@ -c $<

A_%.o : ../../../src/main/main.cpp
	$(CC_A) -I ../../../src/lib -o $@ -c $<
#	$(CC_B) -I ../../../src/lib -o $@ -c $<

B_%.o : ../../../src/lib/%.cpp
#	$(CC_A) -o $@ -c $<
	$(CC_B) -o $@ -c $<

B_%.o : ../../../src/main/main.cpp
#	$(CC_A) -I ../../../src/lib -o $@ -c $<
	$(CC_B) -I ../../../src/lib -o $@ -c $<

vina_A: $(MAINOBJ_A) $(LIBOBJ_A)
	$(CC_A) $(LDFLAGS) -o $@ $^ $(LIBS)

vina_B: $(MAINOBJ_B) $(LIBOBJ_B)
	$(CC_B) $(LDFLAGS) -o $@ $^ $(LIBS)


clean:
	rm -f *.o