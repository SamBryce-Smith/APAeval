"""
This file contains the rules that run the APAlyzer analysis itself:
 - building the PAS reference regions from the GTF file (once per annotation)
 - counting reads over the 3'UTR APA and IPA reference regions
 - identifying significantly regulated APA events with APAdiff
"""

import os

rule pas_reference:
    """
    A rule that builds the PAS reference regions used by the counting steps.

    The reference only depends on the GTF annotation, so it can be reused across runs by
    setting 'use_precomputed_pas_reference'/'precomputed_pas_reference' in the config file.
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing

    output:
        out_pas_reference = os.path.join(config["out_dir"], "pas_reference.RData")

    log:
        os.path.join(LOG_DIR, "pas_reference.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_pas_reference.R \
            --in_preprocessing {input.in_preprocessing} \
            --out_pas_reference {output.out_pas_reference};) &> {log}"""

rule count_3utr:
    """
    A rule that calculates the relative expression of 3'UTR APA events
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_pas_reference = get_pas_reference_input

    output:
        out_counts = os.path.join(config["out_dir"], "counts_3utr.RData")

    params:
        strandtype = config["strandtype"]

    log:
        os.path.join(LOG_DIR, "count_3utr.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_count_3utr.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_pas_reference {input.in_pas_reference} \
            --strandtype {params.strandtype} \
            --out_counts {output.out_counts};) &> {log}"""

rule count_ipa:
    """
    A rule that calculates the relative expression of intronic APA (IPA) events
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_pas_reference = get_pas_reference_input

    output:
        out_counts = os.path.join(config["out_dir"], "counts_ipa.RData")

    params:
        strandtype = config["strandtype"],
        min_mqs = config["ipa_min_mqs"],
        seq_type = config["ipa_seq_type"]

    threads:
        config["ipa_threads"]

    log:
        os.path.join(LOG_DIR, "count_ipa.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_count_ipa.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_pas_reference {input.in_pas_reference} \
            --strandtype {params.strandtype} \
            --nts {threads} \
            --min_mqs {params.min_mqs} \
            --seq_type {params.seq_type} \
            --out_counts {output.out_counts};) &> {log}"""

rule diff_3utr:
    """
    A rule that identifies significantly regulated 3'UTR APA events with APAdiff
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_counts = rules.count_3utr.output.out_counts

    output:
        out_diff = os.path.join(config["out_dir"], "diff_3utr.RData"),
        out_diff_tsv = os.path.join(config["out_dir"], "diff_3utr.tsv")

    params:
        read_cutoff = config["read_cutoff"]

    log:
        os.path.join(LOG_DIR, "diff_3utr.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_diff_3utr.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_counts {input.in_counts} \
            --read_cutoff {params.read_cutoff} \
            --out_diff {output.out_diff} \
            --out_diff_tsv {output.out_diff_tsv};) &> {log}"""

rule diff_ipa:
    """
    A rule that identifies significantly regulated intronic APA (IPA) events with APAdiff
    """

    input:
        in_preprocessing = rules.preprocessing.output.out_preprocessing,
        in_counts = rules.count_ipa.output.out_counts

    output:
        out_diff = os.path.join(config["out_dir"], "diff_ipa.RData"),
        out_diff_tsv = os.path.join(config["out_dir"], "diff_ipa.tsv")

    params:
        read_cutoff = config["read_cutoff"]

    log:
        os.path.join(LOG_DIR, "diff_ipa.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_diff_ipa.R \
            --in_preprocessing {input.in_preprocessing} \
            --in_counts {input.in_counts} \
            --read_cutoff {params.read_cutoff} \
            --out_diff {output.out_diff} \
            --out_diff_tsv {output.out_diff_tsv};) &> {log}"""
