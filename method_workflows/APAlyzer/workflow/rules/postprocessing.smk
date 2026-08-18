"""
This file contains rules that run the APAlyzer_postprocessing.R script
using the outputs of the differential steps and create the differential
challenge output tsv files. Separate files are generated for the 3'UTR APA
and IPA analyses, alongside the merge of the two analyses.
"""

import os

rule postprocess_3utr:
    """
    A rule that postprocesses the 3'UTR APA differential output and creates a
    differential output tsv file
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_postprocessing = rules.diff_3utr.output.out_diff

    output:
        out_postprocessing = os.path.join(config["out_dir"], OUT_STEM + ".3utr.tsv")

    log:
        os.path.join(LOG_DIR, "postprocess_3utr.log")

    container:
        config["container"]

    shell:
       """(Rscript  workflow/scripts/APAlyzer_postprocessing.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_postprocessing {input.in_postprocessing} \
            --out_postprocessing {output.out_postprocessing}) &> {log}"""

rule postprocess_ipa:
    """
    A rule that postprocesses the IPA differential output and creates a
    differential output tsv file
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_postprocessing = rules.diff_ipa.output.out_diff

    output:
        out_postprocessing = os.path.join(config["out_dir"], OUT_STEM + ".ipa.tsv")

    log:
        os.path.join(LOG_DIR, "postprocess_ipa.log")

    container:
        config["container"]

    shell:
       """(Rscript  workflow/scripts/APAlyzer_postprocessing.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_postprocessing {input.in_postprocessing} \
            --out_postprocessing {output.out_postprocessing}) &> {log}"""

rule postprocess_merged:
    """
    A rule that merges the 3'UTR APA and IPA differential output and creates the
    final differential challenge output tsv file
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_3utr = rules.diff_3utr.output.out_diff,
        in_ipa = rules.diff_ipa.output.out_diff

    output:
        out_postprocessing = os.path.join(config["out_dir"], config["differential_output_file"])

    log:
        os.path.join(LOG_DIR, "postprocess_merged.log")

    container:
        config["container"]

    shell:
       """(Rscript  workflow/scripts/APAlyzer_postprocessing.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_postprocessing {input.in_3utr},{input.in_ipa} \
            --out_postprocessing {output.out_postprocessing}) &> {log}"""
