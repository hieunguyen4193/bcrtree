#!/bin/bash -ue
cat m11_IGHV1-50*01_IGHJ3*01_39_2.aln.fasta | sed "s/>.*|Abundance:\([0-9]\+\)/>\1/" > m11_IGHV1-50*01_IGHJ3*01_39_2.aln.fasta.modified.fa
python deduplicated.py         --input m11_IGHV1-50*01_IGHJ3*01_39_2.aln.fasta.modified.fa         --root GL         --frame 0         --id_abundances         --output_name m11_IGHV1-50*01_IGHJ3*01_39_2.aln         --output .
