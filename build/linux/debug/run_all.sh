#!/bin/bash

CPU=$(uname -p)

X86_TARGETS=("vina_A" "vina_B" "vina_C" "vina_D")
RISCV_TARGETS=("vina_A" "vina_B" "vina_C" "vina_D")

CONF_FILE="conf.txt"
X86_CORES=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
RISCV_CORES=("1" "2" "3" "4")

X86_TIME_OUT_FILE="x86_runs.txt"
RISCV_TIME_OUT_FILE="riscv_runs.txt"

RISCV="riscv64"
X86_64="x86_64"

#Vehave Parameters
VDL="0"
VVL="16384"

if [[ ${CPU} == ${X86_64} ]]; then
  for TARGET in ${X86_TARGETS[@]}; do
    for CORE in ${X86_CORES[@]}; do
      echo ${CPU}
      X86_VINA_OUT_FILE="X86_${TARGET}_${CORE}.txt"
      echo ${TARGET} --config ${CONF_FILE} --out ${X86_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
#           ${TARGET} --config ${CONF_FILE} --out ${X86_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
    done
  done
elif [[ ${CPU} == ${RISCV} ]]; then
  for TARGET in ${RISCV_TARGETS[@]}; do
    for CORE in ${RISCV_CORES[@]}; do
      echo ${CPU}
      RISCV_VINA_OUT_FILE="riscv_${TARGET}_${CORE}.txt"
      if [[ ${TARGET} == ${RISCV_TARGETS[0]} ]]; then 
        echo ${TARGET} --config ${CONF_FILE} --out ${RISCV_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
#             ${TARGET} --config ${CONF_FILE} --out ${RISCV_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
      else
        VFILE="vehave_${TARGET}_${CORE}.trace"
        echo VEHAVE_DEBUG_LEVEL=${VDL} VEHAVE_VECTOR_LENGTH=${VVL} VEHAVE_TRACE_FILE=${VFILE} vehave ${TARGET} --config ${CONF_FILE} --out ${RISCV_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
#             VEHAVE_DEBUG_LEVEL=${VDL} VEHAVE_VECTOR_LENGTH=${VVL} VEHAVE_TRACE_FILE=${VFILE} vehave ${TARGET} --config ${CONF_FILE} --out ${RISCV_VINA_OUT_FILE} --cpu ${CORE} --out_time ${X86_TIME_OUT_FILE}
      fi
    done
  done
fi
