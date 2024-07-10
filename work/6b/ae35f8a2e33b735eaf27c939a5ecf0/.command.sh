#!/bin/bash -ue
python modify_tree_colors.py     --input_fasta m11_IGHV1-50*01_IGHJ3*01_39_2.aln.fasta     --input_idmap m11_IGHV1-50*01_IGHJ3*01_39_2.aln.id_map_seq.csv     --gctree_inference_file gctree.out.inference.1.p     --color_path hex_color.csv     --output .     --svg_name m11_IGHV1-50*01_IGHJ3*01_39_2.aln.color
