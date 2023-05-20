#!/bin/bash

TARGETS=("vina_A")

CONF_FILE="conf.txt"
CORES=("4")
OUT_FILE="cpu4.txt"

CPU=$(uname -p)
echo ${CPU}

for TARGET in ${TARGETS[@]};
do
	for CORE in ${CORES[@]};
	do
	  if [[ ${CPU} -eq x86_64 ]]; then
		  echo ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
		  ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
		elif [[ $CPU -eq riscv64 ]]; then
		  echo vehave ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
		  vehave ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
	  fi
	done
done