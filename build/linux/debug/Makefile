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
  GPP_As=icpx
  C_OPTIONS_As= -g -std=c++14 -O3
  C_OPTIONS_As+=-DVERSION=\"$(GIT_VERSION)\"
  C_OPTIONS_As+=-DMAKETYPE=\"$(CPU)_As\"
  C_OPTIONS_As+=-DFLTYPE=double
  CC_As = ${GPP_As} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_As} $(INCFLAGS)
  ########

  #Second Built:
  GPP_Bs=icpx
  C_OPTIONS_Bs= -g -std=c++14 -O3 -xHost
  C_OPTIONS_Bs+=-DVERSION=\"$(GIT_VERSION)\"
  C_OPTIONS_Bs+=-DMAKETYPE=\"$(CPU)_Bs\"
  C_OPTIONS_Bs+=-DFLTYPE=double
  CC_Bs = ${GPP_Bs} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_Bs} $(INCFLAGS)
  ########

else
  BOOST_INCLUDE=/home/aali2/include
  INCFLAGS = -I $(BOOST_INCLUDE)
  LDFLAGS= -L$(BASE)/lib -L. -L/home/aali2/lib

  #First Built:
  GPP_As=clang++
  C_OPTIONS_As= -g -std=c++14 -O3 -fno-vectorize -march=rv64g -mepi -mcpu=avispado -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize
  C_OPTIONS_As+=-DVERSION=\"$(GIT_VERSION)\"
  C_OPTIONS_As+=-DMAKETYPE=\"$(CPU)_As\"
  C_OPTIONS_As+=-DFLTYPE=double
  CC_As = ${GPP_As} ${C_PLATFORM} -ansi -Wno-long-long ${C_OPTIONS_As} $(INCFLAGS)
  #######
endif

LIBOBJ_As= As_ad4cache.o As_cache.o As_non_cache.o As_conf_independent.o As_coords.o As_grid.o As_szv_grid.o As_model.o As_monte_carlo.o As_mutate.o As_parallel_mc.o As_parse_pdbqt.o As_quasi_newton.o As_quaternion.o As_random.o As_utils.o As_vina.o
MAINOBJ_As = As_main.o

LIBOBJ_Bs= Bs_ad4cache.o Bs_cache.o Bs_non_cache.o Bs_conf_independent.o Bs_coords.o Bs_grid.o Bs_szv_grid.o Bs_model.o Bs_monte_carlo.o Bs_mutate.o Bs_parallel_mc.o Bs_parse_pdbqt.o Bs_quasi_newton.o Bs_quaternion.o Bs_random.o Bs_utils.o Bs_vina.o
MAINOBJ_Bs = Bs_main.o


all: vina_As vina_Bs

#First Built
As_%.o : ../../../src/lib/%.cpp
	$(CC_As) -o $@ -c $<

As_%.o : ../../../src/main/main.cpp
	$(CC_As) -I ../../../src/lib -o $@ -c $<

vina_As: $(MAINOBJ_As) $(LIBOBJ_As)
	$(CC_As) $(LDFLAGS) -o $@ $^ $(LIBS)
###########

#Second Built
Bs_%.o : ../../../src/lib/%.cpp
	$(CC_As) -o $@ -c $<

Bs_%.o : ../../../src/main/main.cpp
	$(CC_As) -I ../../../src/lib -o $@ -c $<

vina_Bs: $(MAINOBJ_Bs) $(LIBOBJ_Bs)
	$(CC_Bs) $(LDFLAGS) -o $@ $^ $(LIBS)
###########


clean:
	rm -f As_*.o Bs_*.o
	rm -f vina_As vina_Bs