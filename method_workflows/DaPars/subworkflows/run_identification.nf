/*
 * Run DaPars for identification challenge
 */

include { CREATE_CONFIG_FILE            } from '../modules/create_config_file' addParams( options: [:] )
include { DAPARS_MAIN                   } from '../modules/dapars_main' addParams( options: [:] )
include { POSTPROCESSING_IDENTIFICATION } from '../modules/postprocessing_identification' addParams( options: [:] )

workflow RUN_IDENTIFICATION {
    take:
    ch_convert_to_bedgraph_out
    ch_extracted_3utr_output

    main:
    /*
     *   Prepare input channles
     *   Every sample is run on its own, with its bedgraph file used as both groups
     */
    ch_convert_to_bedgraph_out
        .combine( ch_extracted_3utr_output )
        .map { idx, sample, condition, bedgraph_file, annotated_3utr ->
            [ "identification", sample, bedgraph_file.name, bedgraph_file.name, bedgraph_file, annotated_3utr ] }
        .set { ch_create_config_file_input }

    /*
     * Create config file to be used as input for step 2 of DaPars
     */
    CREATE_CONFIG_FILE ( ch_create_config_file_input )

    /*
     * Run step 2 of DaPars: identify the dynamic APA usages between two conditions.
     */
    DAPARS_MAIN ( CREATE_CONFIG_FILE.out.ch_dapars_input )

    /*
     * Convert DaPars output file to identification challenge output file
     */
    DAPARS_MAIN.out.ch_dapars_output
        .set { ch_postprocessing_input }

    POSTPROCESSING_IDENTIFICATION ( ch_postprocessing_input )
}

