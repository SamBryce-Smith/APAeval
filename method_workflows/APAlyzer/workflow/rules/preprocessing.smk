"""
This file contains rules to obtain suitable input gtf file format and calls
APAlyzer_preprocessing.R script to prepare variables needed
to run APAlyzer
"""

import os

rule rename_gtf:
    """
    A rule that renames gtf file to the correct format for preprocessing

    APAlyzer's PAS2GEF() parses the organism, genome version and Ensembl version from the
    basename of the GTF file, so a symbolic link with the expected naming convention is
    created rather than copying the (potentially very large) annotation file.
    """

    input:
        gtf = config["gtf"]

    output:
        gtf_renamed = os.path.join(
		config["out_dir"], 
		config["gtf_organism"]+ "." + \
		config["gtf_genome_version"] + "." + \
		config["gtf_ensemble_version"] + ".gtf")
    shell:
        "ln -sfn $(realpath {input}) {output}"

rule preprocessing:
    """
    A rule that called APAlyzer_preprocessing.R script to prepare
    variables needed to run APAlyzer
    """

    input:
        gtf = rules.rename_gtf.output.gtf_renamed,
        gene_dict_csv = get_gene_dict_input

    output:
        out_preprocessing = os.path.join(config["out_dir"], 'preprocessing.RData')
 
    params:
       sample_file = config["sample_file"],
       gene_dict_opt = lambda wildcards, input: f"--gene_dict_csv {input.gene_dict_csv}" if config["use_precomputed_gene_dict"] else ""

    log:
        os.path.join(LOG_DIR, "preprocessing.log")

    container:
        config["container"]

    shell:
        """(Rscript  workflow/scripts/APAlyzer_preprocessing.R \
            --sample_file_path {params.sample_file} \
            --input_gtf {input.gtf} \
            {params.gene_dict_opt} \
            --out_preprocessing {output.out_preprocessing};) &> {log}"""
