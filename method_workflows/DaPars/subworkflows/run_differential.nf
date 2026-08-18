/*
 * Run DaPars for differential challenge
 */

include { CREATE_CONFIG_FILE          } from '../modules/create_config_file' addParams( options: [:] )
include { DAPARS_MAIN                 } from '../modules/dapars_main' addParams( options: [:] )
include { POSTPROCESSING_DIFFERENTIAL } from '../modules/postprocessing_differential' addParams( options: [:] )

workflow RUN_DIFFERENTIAL {
    take:
    ch_convert_to_bedgraph_out
    ch_extracted_3utr_output

    main:
    /*
     *  Prepare input channel
     *  toSortedList only emits once every sample has been converted to bedgraph, so a
     *  single config file is created from the complete set of bedgraph files. Sorting on
     *  the samplesheet row index and grouping by condition (groupBy preserves the order
     *  in which the conditions are first seen) makes group1 the condition of the first
     *  row of the samplesheet and group2 the remaining condition.
     */
    ch_convert_to_bedgraph_out
        .combine( ch_extracted_3utr_output )
        .toSortedList { a, b -> a[0] <=> b[0] }
        .map { rows ->
            def annotated_3utr = rows[0][4]
            def groups = rows.groupBy { it[2] }
            def conditions = groups.keySet() as List
            if ( conditions.size() < 2 ) {
                exit 1, "The differential challenge compares two conditions, but the samplesheet " +
                        "only contains the condition '${conditions[0]}'"
            }
            def group1 = groups[conditions[0]].collect { it[3] }
            def group2 = conditions[1..-1].collectMany { condition -> groups[condition].collect { it[3] } }
            [ "differential",
              conditions.join('_vs_'),
              group1.collect { it.name }.join(','),
              group2.collect { it.name }.join(','),
              group1 + group2,
              annotated_3utr ]
        }
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
     * Convert DaPars output file to differential challenge output file
     */
     DAPARS_MAIN.out.ch_dapars_output
        .set { ch_postprocessing_input }

    POSTPROCESSING_DIFFERENTIAL ( ch_postprocessing_input )
}

