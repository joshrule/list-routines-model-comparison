#!/bin/bash

OUTDIR=$1
CONCEPT=$2
RUNS=$3
PARAMS=$4
DATA=$5
MANIFEST=$6
PREFIX=${OUTDIR}/${CONCEPT}
BEST=${PREFIX}_best.csv
PREDICTIONS=${PREFIX}_predictions.csv
ALL=${PREFIX}_all.csv
LOG=${PREFIX}_log.log

# DEBUGGING
# echo "RUST_BACKTRACE=full cargo run --manifest-path $MANIFEST --release --bin simulation -- $PARAMS $RUNS $DATA $BEST $PREDICTIONS $ALL /dev/null &> $LOG"
RUST_BACKTRACE=full cargo run --manifest-path $MANIFEST --release --bin simulation -- $PARAMS $RUNS $DATA $BEST $PREDICTIONS $ALL /dev/null &> $LOG
