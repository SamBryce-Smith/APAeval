rule make_quant_beds:
    input:
        rules.qapa_quant_single.output

    output:
        tpm = os.path.join(config["out_dir"],
                     "challenge_outputs", 
                     "_".join([config["param_code"],
                               config["method"],
                               "{sample}" + config["quantification_output_suffix"]
                               ]
                              )
                    ),
        ppau = os.path.join(config["out_dir"],
                     "challenge_outputs", 
                     "_".join([config["param_code"],
                               config["method"],
                               "{sample}" + config["relative_quantification_output_suffix"]
                               ]
                              )
                    ),
        
    params:
        script = os.path.join(config["scripts_dir"], "make_quant_bed.py"),

    
    log:
        stdout = os.path.join(config["out_dir"], "logs",
                    "challenge_outputs",
                    "make_quant_beds.{sample}.stdout.log"),
        stderr = os.path.join(config["out_dir"], "logs",
                    "challenges_outputs",
                    "make_quant_beds.{sample}.stderr.log")
 
    shell: 
        """
        python {params.script} \
        {input} {output.ppau} {output.tpm} \
        1> {log.stdout} \
        2> {log.stderr}
        """