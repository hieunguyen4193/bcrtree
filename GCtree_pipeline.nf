nextflow.enable.dsl=1

process DeduplicateAndPrepare {
    tag "${fasta.baseName}"

    input:
    path fasta
    path outputdir

    output:
    path "${outputdir}/${fasta.baseName}/*.phylip" into phylip_files
    path "${outputdir}/${fasta.baseName}/*_dnapars.cfg" into config_files

    script:
    """
    mkdir -p \${outputdir}/\${fasta.baseName}

    cat \${fasta} | sed 's/>.*|Abundance:\\([0-9]\\+\\)/>\\1/' > \${outputdir}/\${fasta.baseName}/\${fasta.baseName}.modified.fa

    input_fasta=\${outputdir}/\${fasta.baseName}/\${fasta.baseName}.modified.fa;

    echo -e "Running deduplicate ..."
    python /home/hieu/src/BCRTree_release/gctree/deduplicated.py \\
    --input \${input_fasta} \\
    --root GL \\
    --frame 0 \\
    --id_abundances \\
    --output_name \${fasta.baseName} \\
    --output \${outputdir}/\${fasta.baseName}

    echo -e "Running mkconfig..."
    mkconfig --quick \${outputdir}/\${fasta.baseName}/\${fasta.baseName}.phylip dnapars \\
    > \${outputdir}/\${fasta.baseName}/\${fasta.baseName}_dnapars.cfg
    """
}