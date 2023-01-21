#!/bin/bash
snakemake \
    --snakefile="workflow/Snakefile" \
    --configfile="config/config.QAPA.yaml" \
    --cores 4 \
    --use-singularity \
    --singularity-args "--bind /home/sam" \
    --printshellcmds
