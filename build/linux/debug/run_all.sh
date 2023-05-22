#!/bin/bash

TARGETS=("vina_A" "vina_B" "vina_C" "vina_D")

CONF_FILE="conf.txt"
CORES=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
OUT_FILE="results.txt"

VEHAVE_PARAMS="VEHAVE_DEBUG_LEVEL=0 VEHAVE_VECTOR_LENGTH=16384"
VEHAVE="vehave"
RISCV="riscv64"
X86_64="x86_64"

if [[ ${CPU} == ${X86_64} ]]; then
  for TARGET in ${TARGETS[@]}; do
    for CORE in ${CORES[@]}; 	do
      echo ${CPU}
      echo ${TARGET} --config ${CONF_FILE} --out x86_runs.txt --cpu ${CORE} --out_time ${OUT_FILE}
      ${TARGET} --config ${CONF_FILE} --out x86_runs.txt --cpu ${CORE} --out_time ${OUT_FILE}
    done
  done
elif [[ ${CPU} == ${RISCV} ]]; then
  for TARGET in ${TARGETS[@]}; do
    for CORE in ${CORES[@]}; do
      echo ${CPU}
      if [[ ${TARGET} == TARGET[0] ]]; then
        echo ${TARGET} --config ${CONF_FILE}  --out riscv_runs.txt--cpu ${CORE} --out_time ${OUT_FILE}
        ${TARGET} --config ${CONF_FILE} --out riscv_runs.txt --cpu ${CORE} --out_time ${OUT_FILE}
      else
        echo ${VEHAVE_PARAMS} ${VEHAVE} ${TARGET} --config ${CONF_FILE}  --out riscv_runs.txt--cpu ${CORE} --out_time ${OUT_FILE}
        ${VEHAVE_PARAMS} ${VEHAVE} ${TARGET} --config ${CONF_FILE} --out riscv_runs.txt --cpu ${CORE} --out_time ${OUT_FILE}
      fi
  	done
  done
fi