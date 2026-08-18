#------------------------PAS reference regions------------------------
# Build the PAS (polyadenylation site) reference regions from the GTF file.
# The reference regions only depend on the annotation, so this step only needs
# to be run once per GTF file and the output can be reused across runs.

# load libraries
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("APAlyzer"))) == FALSE ) { stop("[ERROR] Package 'APAlyzer' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("GenomicFeatures"))) == FALSE ) { stop("[ERROR] Package 'GenomicFeatures' required! Aborted.") }

#########################
###  PARSE ARGUMENTS  ###
#########################

# Get script name
script = sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Build description message
description = "Build the PAS reference regions\n"
version = "Version: 1.0.0 (Aug 2026)"
requirements = "Requires: optparse, APAlyzer, GenomicFeatures"
msg = paste(description, version, requirements, sep="\n")

# Define list of arguments
option_list = list(
  make_option(
    "--in_preprocessing",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Output of the preprocessing step (provides the path to the gtf file)",
    metavar = "files"
  ),
  make_option(
    "--out_pas_reference",
    action = "store",
    type = "character",
    default = FALSE,
    help = "PAS reference regions to be used by the counting steps",
    metavar = "files"
  ),
  make_option(
    c("-h", "--help"),
    action = "store_true",
    default = FALSE,
    help = "Show this information and die."
  ),
  make_option(
    c("-v", "--verbose"),
    action = "store_true",
    default = FALSE,
    help = "Print log messages to STDOUT."
  )
)

# Parse command-line arguments
opt_parser = OptionParser(
                usage = paste("Usage:", script, "[OPTIONS] \n", sep = " "),
                option_list = option_list,
                add_help_option = FALSE,
                description = msg)
opt = parse_args(opt_parser)

#------------------------------------------------------------------
# Load variables from preprocessing step
load(opt$in_preprocessing)

#----------------------Build the PAS reference regions----------------------
PASREFraw = PAS2GEF(GTFfile, AnnoMethod="V2")
refUTRraw = PASREFraw$refUTRraw
dfIPAraw = PASREFraw$dfIPA
dfLEraw = PASREFraw$dfLE
PASREF = REF4PAS(refUTRraw,dfIPAraw,dfLEraw)
# reference region used for 3'UTR APA analysis
UTRdbraw = PASREF$UTRdbraw
# dfIPA and dfLE are needed in intronic APA analysis
dfIPA = PASREF$dfIPA
dfLE = PASREF$dfLE

# ensure that coordinates are numeric
dfIPA$Pos = as.numeric(as.character(dfIPA$Pos))
dfIPA$upstreamSS = as.numeric(as.character(dfIPA$upstreamSS))
dfIPA$downstreamSS = as.numeric(as.character(dfIPA$downstreamSS))
dfLE$LEstart = as.numeric(as.character(dfLE$LEstart))
dfLE$TES = as.numeric(as.character(dfLE$TES))

############################
###  SAVE FINAL OUTPUTS  ###
############################

save(list = c("UTRdbraw", "dfIPA", "dfLE"), file = opt$out_pas_reference)
