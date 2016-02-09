#!/bin/bash

SCRIPT=`realpath $0`
ROOT_PATH=`dirname $SCRIPT`
NOW=`date +%Y%m%d%H%M%S`

TMP_FILES=$ROOT_PATH/tmp
PEAK_DETECT=$ROOT_PATH/peak_detect.py

rm $TMP_FILES/*
arecord -q -d 2 $TMP_FILES/sample.wav
$(aplay -q $TMP_FILES/sample.wav)&

python -u $PEAK_DETECT > $TMP_FILES/output
cat $TMP_FILES/output | tail -1