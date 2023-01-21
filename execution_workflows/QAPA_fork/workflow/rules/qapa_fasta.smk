# Place any additional SUBWORKFLOWS here.




rule qapa_fasta_decoy:
    input: 
        utr_bed = config["utr_bed"],
        genome_fa = config["genome_fasta"]
    output:
        utr_fa = os.path.join(config["out_dir"], "qapa_fasta", "utr_sequences.fa"),
        decoys = os.path.join(config["out_dir"], "qapa_fasta", "decoys.txt")

    log:
        stdout = os.path.join(config["out_dir"], "logs", "qapa_fasta", "qapa_fasta_decoy.stdout.log"),
        stderr = os.path.join(config["out_dir"], "logs", "qapa_fasta", "qapa_fasta_decoy.stderr.log"),
    
    container:
        "docker://sambrycesmith/qapa_fork:231dd0c"

    shell:
        """
        qapa fasta \
        -f {input.genome_fa} \
        --decoys \
        -d {output.decoys} \
        {input.utr_bed} {output.utr_fa} \
        1> {log.stdout} \
        2> {log.stderr}
        """ 


rule qapa_fasta:
    input: 
        utr_bed = config["utr_bed"],
        genome_fa = config["genome_fasta"]
    output:
        utr_fa = os.path.join(config["out_dir"], "qapa_fasta", "utr_sequences.fa")

    log:
        stdout = os.path.join(config["out_dir"], "logs", "qapa_fasta", "qapa_fasta_decoy.stdout.log"),
        stderr = os.path.join(config["out_dir"], "logs", "qapa_fasta", "qapa_fasta_decoy.stderr.log"),
    
    container:
        "docker://sambrycesmith/qapa_fork:231dd0c"

    shell:
        """
        qapa fasta \
        -f {input.genome_fa} \
        {input.utr_bed} {output.utr_fa} \
        1> {log.stdout} \
        2> {log.stderr}
        """ 