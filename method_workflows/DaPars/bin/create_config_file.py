#!/usr/bin/env python3

import sys
import argparse
import configparser

def parse_args(args=None):
	Description = "Create config file for step 2 of DaPars."
	Epilog = "Example usage: python create_config_file.py" + \
			" <ANNOTATED_3UTR> <GROUP1_BEDGRAPHS> <GROUP2_BEDGRAPHS> <OUTPUT_DIR>" + \
			" <NUM_LEAST_IN_GROUP1> <NUM_LEAST_IN_GROUP2>"  + \
			" <COVERAGE_CUTOFF> <FDR_CUTOFF> <PDUI_CUTOFF> <FOLD_CHANGE_CUTOFF> <CONFIG_OUTPUT>"

	parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
	parser.add_argument("ANNOTATED_3UTR")
	parser.add_argument("GROUP1_BEDGRAPHS", help="Comma-separated bedgraph files of the first condition.")
	parser.add_argument("GROUP2_BEDGRAPHS", help="Comma-separated bedgraph files of the second condition.")
	parser.add_argument("OUTPUT_DIR")
	parser.add_argument("NUM_LEAST_IN_GROUP1")
	parser.add_argument("NUM_LEAST_IN_GROUP2")
	parser.add_argument("COVERAGE_CUTOFF")
	parser.add_argument("FDR_CUTOFF")
	parser.add_argument("PDUI_CUTOFF")
	parser.add_argument("FOLD_CHANGE_CUTOFF")
	parser.add_argument("CONFIG_OUTPUT")

	return parser.parse_args(args)


def create_config_file(args):
	"""
	This function creates the config file for step 2 of DaPars
	The bedgraph files of each group are grouped by condition by the pipeline and
	are staged next to the config file, so they are referenced by name only.
	"""
	config = {
		'Annotated_3UTR': args.ANNOTATED_3UTR,
		'Group1_Tophat_aligned_Wig': args.GROUP1_BEDGRAPHS,
		'Group2_Tophat_aligned_Wig': args.GROUP2_BEDGRAPHS,
		'Output_result_file': 'dapars_output',
		'Output_directory': args.OUTPUT_DIR,
		'Num_least_in_group1': args.NUM_LEAST_IN_GROUP1,
		'Num_least_in_group2': args.NUM_LEAST_IN_GROUP2,
		'Coverage_cutoff': args.COVERAGE_CUTOFF,
		'FDR_cutoff': args.FDR_CUTOFF,
		'PDUI_cutoff': args.PDUI_CUTOFF,
		'Fold_change_cutoff': args.FOLD_CHANGE_CUTOFF
	}

	with open(args.CONFIG_OUTPUT, 'w') as f:
		for key, value in config.items():
			f.write('%s=%s\n' % (key, value))


def main(args=None):
	args = parse_args(args)
	create_config_file(args)


if __name__ == '__main__':
	sys.exit(main())
