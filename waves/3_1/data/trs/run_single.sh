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

[ $# -ne 6 ] && { echo "Usage: $0 <outdir> <concept> <num_runs> <param_file> <data_file> <manifest_file>"; exit 1; }

# PARALLEL DEBUGGING
# echo "RUST_BACKTRACE=full cargo run --manifest-path $MANIFEST --release --bin simulation -- $PARAMS $RUNS $DATA $BEST $PREDICTIONS $ALL /dev/null &> $LOG"

# MEMORY DEBUGGING
# RUST_BACKTRACE=full nice -n 0 valgrind --tool=massif /home/rule/library/list-routine-learning-rs/target/release/simulation $PARAMS $RUNS $DATA $BEST $PREDICTIONS $ALL /dev/null &> $LOG

# ACTUAL
RUST_BACKTRACE=full cargo run --manifest-path $MANIFEST --release --bin simulation -- $PARAMS $RUNS $DATA $BEST $PREDICTIONS $ALL /dev/null &> $LOG
