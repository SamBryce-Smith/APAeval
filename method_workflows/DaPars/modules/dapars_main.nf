// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process DAPARS_MAIN {
        tag "$id"
        publishDir "${params.outdir}/dapars/dapars_main/${run_mode}/${id}", mode: params.publish_dir_mode
        container "docker.io/apaeval/dapars:latest"

        input:
        // the annotated 3'UTR and the bedgraph files are staged here because the config
        // file refers to them by name
        tuple val(run_mode), val(id), path(config_file), path(annotated_3utr), path(bedgraph_files)

        output:
        tuple val(run_mode), val(id), path(dapars_output_file), emit: ch_dapars_output
        path "dapars_output*", emit: ch_dapars_all

        script:
        dapars_output_file = "dapars_output_All_Prediction_Results.txt"
        """
        python /dapars/src/DaPars_main.py $config_file
        """
 }



