#------------------------Preprocessing------------------------
# 1. Check sample file column names
# 2. Check that number of conditions is exactly 2
# 3. Get list of sample names and absolute paths to bam file
# 4. Get a dictionary of gene symbol to gene id from gtf file
#    (or read a precomputed gene_name,gene_id table from a CSV file)

# load libraries
if ( suppressWarnings(suppressPackageStartupMessages(require("optparse"))) == FALSE ) { stop("[ERROR] Package 'optparse' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("stringr"))) == FALSE ) { stop("[ERROR] Package 'stringr' required! Aborted.") }
if ( suppressWarnings(suppressPackageStartupMessages(require("hash"))) == FALSE ) { stop("[ERROR] Package 'hash' required! Aborted.") }

#########################
###  PARSE ARGUMENTS  ###
#########################

# Get script name
script = sub("--file=", "", basename(commandArgs(trailingOnly = FALSE)[4]))

# Build description message
description = "Build reference genome\n"
version = "Version: 1.0.0 (Dec 2021)"
requirements = "Requires: optparse, stringr, hash"
msg = paste(description, version, requirements, sep = "\n")

# Define list of arguments
option_list = list(
  make_option(
    "--input_gtf",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Input gtf. Required!",
    metavar = "files"
  ),
  make_option(
    "--sample_file_path",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Sample file path. Required!",
    metavar = "files"
  ),
  make_option(
    "--gene_dict_csv",
    action = "store",
    type = "character",
    default = NULL,
    help = "Optional precomputed gene symbol to gene id table (CSV file with columns
                'gene_name' and 'gene_id'). If provided, the table is read from this file
                instead of being generated from the input gtf file.",
    metavar = "files"
  ),
  make_option(
    "--out_preprocessing",
    action = "store",
    type = "character",
    default = FALSE,
    help = "Preprocessing variables needed for APAlyzer",
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
                usage = paste("Usage:", script, "[OPTIONS] \n", sep=" "),
                option_list = option_list,
                add_help_option = FALSE,
                description = msg)
opt = parse_args(opt_parser)

####################
###  GET INPUTS  ###
####################

# get sample file
sample_file = opt$sample_file_path

# Read the sample file
df = read.csv(file=sample_file)

# get absolute path to the GTF file
# Note: the directory is normalised rather than the full path, because the file itself is a
# symbolic link created by the 'rename_gtf' rule and APAlyzer's PAS2GEF() parses the organism,
# genome version and Ensembl version from the *basename* of the file. Resolving the link would
# restore the original file name and break that convention.
GTFfile = file.path(normalizePath(dirname(opt$input_gtf)), basename(opt$input_gtf))

###########################
###  CHECK SAMPLE FILE  ###
###########################

# Check column names of the sample file
show_col_error = FALSE
expected_colnames = c("condition", "sample", "bam")
if(length(expected_colnames) != length(colnames(df))) {
    show_col_error = TRUE
}
for(colname in colnames(df)) {
    if(colname %in% expected_colnames == FALSE){
        show_col_error = TRUE
    }
}
if(show_col_error) {
    stop(paste(c("The expected columns are", expected_colnames, "but got", actual_colnames), collapse = " "))
}

# Check that there are exactly two conditions
conditions = df[, "condition"]
unique_conditions = conditions[!duplicated(conditions)]
if(length(unique_conditions) != 2) {
    stop(paste0("Number of conditions in sample file should be exactly 2, got ", length(conditions)))
}

################################
###  PREPARE APALYZER INPUTS ###
################################

# Rearrange rows in sample file to group by condition
df = df[order(df$condition),]

# Get list of sample names
flsall = df[, "bam"]
names(flsall) = df[, "sample"]

# Get list of conditions and counts
condition_counts = c()
for(condition in conditions) {
    condition_counts = c(condition_counts, rep(condition, sum(conditions==condition)))
}

# Get a dictionary of gene symbol to gene id
if(!is.null(opt$gene_dict_csv) && !identical(opt$gene_dict_csv, FALSE) && opt$gene_dict_csv != "") {

    # Read a precomputed gene symbol to gene id table from a CSV file
    gene_dict_df = read.csv(file = opt$gene_dict_csv, stringsAsFactors = FALSE)
    missing_cols = setdiff(c("gene_name", "gene_id"), colnames(gene_dict_df))
    if(length(missing_cols) > 0) {
        stop(paste("The precomputed gene dict CSV file must contain the columns",
                   "'gene_name' and 'gene_id', but the following are missing:",
                   paste(missing_cols, collapse = ", ")))
    }
    gene_dict = hash(keys = as.character(gene_dict_df$gene_name),
                     values = as.character(gene_dict_df$gene_id))

} else {

    # Build the gene symbol to gene id dictionary from the gtf file
    gtf_df = read.csv(file = GTFfile, sep = '\t', comment.char = '#')
    # initialize a dictionary
    gene_dict = hash()
    for(row in gtf_df[,9]) {
      for(str in str_split(row, ';')[[1]]) {
        str = trimws(str)
        gene_symbol = ""
        # get gene id
        key_value_pair = str_split(str, " ")[[1]]
        key = key_value_pair[1]
        value = key_value_pair[2]
        if(key == "gene_id") {
          gene_id = value
        }
        # get gene symbol
        if(key== "gene_name") {
          gene_symbol = value
        }
        if(gene_symbol != "") {
          gene_dict[[gene_symbol]] = gene_id
        }
      }
    }
}

############################
###  SAVE FINAL OUTPUTS  ###
############################

# Save the variables needed for the downstream steps
save(list = c("flsall", "gene_dict", "GTFfile", "unique_conditions", "condition_counts"), file = opt$out_preprocessing)
