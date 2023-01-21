#!/bin/bash
snakemake \
    --rerun-incomplete \
    --snakefile="workflow/Snakefile" \
    --configfile="config/config.QAPA.yaml" \
    --cores 4 \
    --use-singularity \
    --printshellcmds \
    --dryrun
