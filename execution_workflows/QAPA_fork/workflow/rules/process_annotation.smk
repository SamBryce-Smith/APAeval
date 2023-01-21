rule make_identifiers_tbl:
    input:
        config["gtf"]

    output:
        os.path.join(config["out_dir"], "annotation", "annotation_identifers.txt")

    params:
        script = os.path.join(config["scripts_dir"], "GTFtoMartExport.py")

    log:
        stdout = os.path.join(config["out_dir"], "logs", "preprocess_annotation", "make_identifiers_tbl.stdout.log"),
        stderr = os.path.join(config["out_dir"], "logs", "preprocess_annotation", "make_identifiers_tbl.stderr.log"),
        
    shell:
        """
        python {params.script} \
        {input} {output} \
        1> {log.stdout} \
        2> {log.stderr}
        """