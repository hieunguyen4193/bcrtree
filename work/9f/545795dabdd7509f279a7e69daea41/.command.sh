#!/bin/bash -ue
dnapars < m11_IGHV1-50*01_IGHJ3*01_39_2.aln_dnapars.cfg > m11_IGHV1-50*01_IGHJ3*01_39_2.aln_dnapars.log

export QT_QPA_PLATFORM=offscreen
export XDG_RUNTIME_DIR=/tmp/runtime-runner
export MPLBACKEND=agg

gctree infer --verbose --root GL --frame 1 --idlabel outfile m11_IGHV1-50*01_IGHJ3*01_39_2.aln.abundance.csv
