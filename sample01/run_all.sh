#!/bin/bash

TARGETS=("vina_A" "vina_B" "vina_C" "vina_D")

CONF_FILE="conf.txt"
CORES=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
OUT_FILE="results.txt"

for TARGET in ${TARGETS[@]};
do
	for CORE in ${CORES[@]};
	do
		echo ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
		${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
	done
done

