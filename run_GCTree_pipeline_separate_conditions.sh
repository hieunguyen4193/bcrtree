outdir="/home/hieunguyen/CRC1382/outdir/molmed_server/gctree";
output_version="20240723";
project_src="/home/hieunguyen/CRC1382/src_2023/bcrtree";

output=${outdir}/${output_version};
mkdir -p ${output};

samplesheet="/home/hieunguyen/CRC1382/src_2023/bcrtree/SampleSheets/m14_all_YFP_SampleSheet.csv"

deduplicate_src=${project_src}/deduplicated.py;
modify_tree_colors=${project_src}/modify_tree_colors.py;
color_path=${project_src}/hex_color.csv;

work=${outdir}/gctree_pipeline_work;

rm -rf $work

nextflow run GCtree_pipeline_input_SampleSheet.nf \
--samplesheet ${samplesheet} \
--output ${output}/${samplesheet%.csv*} \
--deduplicate_src ${deduplicate_src} \
--modify_tree_colors ${modify_tree_colors} \
--color_path ${color_path} -resume -w ${work}
