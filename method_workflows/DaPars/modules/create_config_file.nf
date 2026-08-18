// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def modules = params.modules.clone()
// get the configs for this process
def options = modules['create_config_file']

process CREATE_CONFIG_FILE {
        tag "$id"
        publishDir "${params.outdir}/dapars/config_files/${run_mode}", mode: params.publish_dir_mode, pattern: "*config"
        container "docker.io/apaeval/dapars:latest"

        input:
        tuple val(run_mode), val(id), val(group1), val(group2), path(bedgraph_files), path(annotated_3utr)

        output:
        // the staged input files are passed on so that DAPARS_MAIN can resolve the
        // file names written into the config file in its own working directory
        tuple val(run_mode), val(id), path(config_output), path(annotated_3utr, includeInputs: true), path("*.bedgraph", includeInputs: true), emit: ch_dapars_input

        script:
        output_dir = "."
        num_least_in_group1 = options.num_least_in_group1
        num_least_in_group2 = options.num_least_in_group2
        coverage_cutoff = options.coverage_cutoff
        fdr_cutoff = options.fdr_cutoff
        pdui_cutoff = options.pdui_cutoff
        fold_change_cutoff = options.fold_change_cutoff
        if ( run_mode == "identification" || run_mode == "relative_usage_quantification" ) {
            config_output = id + "_config"
        }
        else {
            config_output = "config"
        }

        """
        create_config_file.py \
        $annotated_3utr \
        $group1 \
        $group2 \
        $output_dir \
        $num_least_in_group1 \
        $num_least_in_group2 \
        $coverage_cutoff \
        $fdr_cutoff \
        $pdui_cutoff \
        $fold_change_cutoff \
        $config_output
        """
 }
