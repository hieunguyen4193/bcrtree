nextflow.enable.dsl=1

// path to fetch fasta file as inputs
params.input=""

// path to save output all output files
params.output=""

// path to the python source use in deduplicating the sequences.
deduplicate_src=file(params.deduplicate_src)
modify_tree_colors=file(params.modify_tree_colors)
color_path=file(params.color_path)
params.file_pattern=""

// Create a channel that emits files from the specified input directory
Channel
    .fromPath("${params.input}/${params.file_pattern}")
    .map { file ->
        def sample_id = file.baseName.replace(".aln.fasta", "") // Assuming "aln" is part of the base name to remove
        return [sample_id, file] // Return a tuple of sampleID and the file object
    }
    .set { fastaFilesChannel }

process deduplicate { 
    cache "deep"; tag "$sample_id"
    publishDir "$params.output/01_deduplicate", mode: 'copy'
    errorStrategy 'terminate'
    maxRetries 1
    maxForks 20

    input:
        tuple sample_id, file(fasta) from fastaFilesChannel
        file(deduplicate_src)
    output: 
        tuple sample_id, file("*") into mkconfig_ch
        tuple sample_id, file(fasta) into orig_fasta_ch
        tuple sample_id, "${sample_id}.abundance.csv" into abundance_ch
        tuple sample_id, "${sample_id}.id_map.csv" into idmap_ch
        tuple sample_id, "${sample_id}.id_map_seq.csv" into idmap_seq_ch

    shell:
    '''
    cat !{fasta} | sed "s/>.*|Abundance:\\([0-9]\\+\\)/>\\1/" > !{fasta}.modified.fa
    python !{deduplicate_src} \
        --input !{fasta}.modified.fa \
        --root GL \
        --frame 0 \
        --id_abundances \
        --output_name !{sample_id} \
        --output . 
    '''
}

process mkconfig {
    cache "deep"; tag "$sample_id"
    publishDir "$params.output/02_mkconfig", mode: 'copy'
    errorStrategy 'terminate'
    maxRetries 1
    maxForks 5

    input:
        tuple sample_id, file("*") from mkconfig_ch
    output: 
        tuple sample_id, file("*") into dnapars_ch
    script:
    """
    mkconfig --quick ${sample_id}.phylip dnapars > ${sample_id}_dnapars.cfg
    """
}

process dnapars_and_inferring_gc_trees {
    cache "deep"; tag "$sample_id"
    publishDir "$params.output/03_dnapars", mode: 'copy'
    errorStrategy 'terminate'
    maxRetries 1
    maxForks 5
    
    input:
        tuple sample_id, file("*") from dnapars_ch
        tuple sample_id, "${sample_id}.abundance.csv" from abundance_ch
    output:
        tuple sample_id, file("*") into modify_gctree_colors_ch

    script:
    """
    dnapars < ${sample_id}_dnapars.cfg > ${sample_id}_dnapars.log

    export QT_QPA_PLATFORM=offscreen
    export XDG_RUNTIME_DIR=/tmp/runtime-runner
    export MPLBACKEND=agg

    gctree infer --verbose --root GL --frame 1 --idlabel outfile ${sample_id}.abundance.csv
    """
}

process modify_gctree_colors {
    cache "deep"; tag "$sample_id"
    publishDir "$params.output/03_dnapars", mode: 'copy'
    errorStrategy 'terminate'
    maxRetries 1
    maxForks 5
    
    input:
        tuple sample_id, file("*") from modify_gctree_colors_ch
        tuple sample_id, file(fasta) from orig_fasta_ch
        tuple sample_id, "${sample_id}.id_map.csv" from idmap_ch
        tuple sample_id, "${sample_id}.id_map_seq.csv" from idmap_seq_ch
        file(modify_tree_colors)
        file(color_path)
    output:
        tuple sample_id, file("*") into final_ch
    script:
    """
    python ${modify_tree_colors} \
    --input_fasta ${fasta} \
    --input_idmap ${sample_id}.id_map_seq.csv \
    --gctree_inference_file gctree.out.inference.1.p \
    --color_path ${color_path} \
    --output . \
    --svg_name ${sample_id}.color
    """
}