#First we deduplicate the sequences and convert to phylip alignment format,
# and also determine sequence abundances. The deduplicate command writes
# the phylip alignment of unique sequences to stdout (which we redirect to
# a file here). The argument --root indicates the root id.
# The flag --id_abundances can be used to indicate that integer sequence ids
# should be interepreted as abundances. The argument --abundance_file
# indicates that sequence abundance information should be written to the
# specified csv file. The argument --idmapfile allows us to specify
# a filename for the output file containing a mapping of new, unique sequence
# IDs to original sequence IDs from the fasta file.

input_fasta=$1;
outputdir=$2;
echo $outputdir
mkdir -p ${outputdir};

filename=$(echo $input_fasta | xargs -n 1 basename);
filename=${filename%.aln.fasta*}
mkdir -p ${outputdir}/${filename}

cat ${input_fasta} | sed 's/>.*|Abundance:\([0-9]\+\)/>\1/' > f.fasta

input_fasta="/home/hieu/src/BCRTree_release/gctree/f.fasta";

echo -e "Running deduplicate ..."
deduplicate $input_fasta --root GL \
--id_abundances \
--abundance_file ${outputdir}/${filename}/${filename}.abundance.csv \
--idmapfile ${outputdir}/${filename}/${filename}_idmap.txt --frame 1 \
> ${outputdir}/${filename}/${filename}.deduplicated.phylip

echo -e "Running mkconfig..."
mkconfig --quick ${outputdir}/${filename}/${filename}.deduplicated.phylip dnapars \
> ${outputdir}/${filename}/${filename}_dnapars.cfg

echo -e "Running dnapars..."
dnapars < ${outputdir}/${filename}/${filename}_dnapars.cfg > ${outputdir}/${filename}/${filename}_dnapars.log

export QT_QPA_PLATFORM=offscreen
export XDG_RUNTIME_DIR=/tmp/runtime-runner
export MPLBACKEND=agg

echo -e "Inferring gctree ..."
gctree infer --verbose --root GL --frame 1 --idlabel outfile ${outputdir}/${filename}/${filename}.abundance.csv
