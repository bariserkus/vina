#!/bin/bash

TARGETS=("vina_A")

CONF_FILE="conf.txt"
CORES=("4")
OUT_FILE="cpu4.txt"

for TARGET in ${TARGETS[@]};
do
	for CORE in ${CORES[@]};
	do
		echo ${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
		${TARGET} --config ${CONF_FILE} --cpu ${CORE} --out_time ${OUT_FILE}
	done
done


