#------------------------IPA differential analysis------------------------
# Identify significantly regulated IPA APA events between the two conditions

# load libraries
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("APAlyzer"))) == FALSE ) { stop("[ERROR] Package 'APAlyzer' required! Aborted.") }

#########################
###  PARSE ARGUMENTS  ###
#########################

# Get script name
script = sub("--file=", "", basename(commandArgs(trailingOnly=FALSE)[4]))

# Build description message
description = "Identify significantly regulated IPA APA events\n"
version = "Version: 1.0.0 (Aug 2026)"
requirements = "Requires: optparse, APAlyzer"
msg = paste(description, version, requirements, sep="\n")

# Define list of arguments
option_list = list(
  make_option(
    "--in_preprocessing",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Output of the preprocessing step (provides the sample and condition metadata)",
    metavar = "files"
  ),
  make_option(
    "--in_counts",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Relative expression of IPA APA events from the counting step",
    metavar = "files"
  ),
  make_option(
    "--read_cutoff",
    action = "store",
    type = "character",
    default = FALSE,
    help = "read cutoff",
  ),
  make_option(
    "--out_diff",
    action = "store",
    type = "character",
    default = FALSE,
    help = "IPA APA differential output variables to postprocess",
    metavar = "files"
  ),
  make_option(
    "--out_diff_tsv",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Full IPA APA differential results table",
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
# Load variables from the preprocessing and counting steps
load(opt$in_preprocessing)
load(opt$in_counts)

#---------------Significantly regulated APA in introns-----------------
sampleTable = data.frame(samplename =
                           names(flsall),
                         condition = condition_counts)

if(nrow(IPA_OUT) > 1) {
    out_diff = APAdiff(sampleTable,
                       IPA_OUT,
                       conKET = unique_conditions[1],
                       trtKEY = unique_conditions[2],
                       PAS = 'IPA',
                       CUTreads = opt$read_cutoff)
} else {
    out_diff = NULL
}

############################
###  SAVE FINAL OUTPUTS  ###
############################

# Write the full results table alongside the RData object
if(is.null(out_diff)) {
    file.create(opt$out_diff_tsv)
} else {
    write.table(out_diff, file = opt$out_diff_tsv, sep = "\t",
                row.names = FALSE, col.names = TRUE, quote = FALSE)
}

# Subset to the columns needed by the postprocessing step
if(!is.null(out_diff)) {
    out_df = out_diff[,c("gene_symbol", "pvalue")]
} else {
    out_df = NULL
}

save(list = c("out_df"), file = opt$out_diff)
