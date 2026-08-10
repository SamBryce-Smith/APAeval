/*
 * Check input samplesheet and get read channels
 */

params.options = [:]

include { CHECK_SAMPLESHEET;
          get_sample_info } from '../modules/check_samplesheet' addParams( options: params.options )

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv
    
    main:
    // The row index is attached here, while the samplesheet order is still known, so that
    // the differential step can group the samples in the order given in the samplesheet
    CHECK_SAMPLESHEET ( samplesheet )
        .splitCsv ( header:true, sep:',' )
        .toList()
        .flatMap { rows -> rows.indexed().collect { idx, row -> [ idx ] + get_sample_info(row) } }
        .set { ch_sample }

    emit:
    ch_sample // [ idx, sample, condition, bam, bai ]
}
