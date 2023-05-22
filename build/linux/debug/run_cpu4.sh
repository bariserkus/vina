#!/bin/bash

TARGET="vina_A"
CONF_FILE="conf.txt"
CORE="4"
OUT_FILE="cpu4.txt"

VEHAVE="vehave"
RISCV="riscv64"
X86_64="x86_64"

CPU=$(uname -p)

if [[ ${CPU} == ${X86_64} ]]; then
   echo ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
   ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
elif [[ ${CPU} == ${RISCV} ]]; then
   echo ${CPU}
   echo ${VEHAVE} ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
   ${VEHAVE} ${TARGET} --config ${CONF_FILE} --out riscv_runs.txt --cpu ${CORE} --out_time ${OUT_FILE}
fi