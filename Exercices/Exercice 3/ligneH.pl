#!/usr/bin/perl -w

use strict;

# Immeuble parser - This perl script parses skylines XML files.
# Recognised format is the following
# <immeuble from="x1" to="x2" h="height />

my $nArg = scalar @ARGV;

if ($nArg == 0){
	# read from Stdio
	print "Reading from STDIO"
} else{
	
	# Define variables of files to be parsed and 'from' parameter
	my @files = [];
	my @from  = 0;
	
	foreach (@ARGV){
		&parseArg($_);
		#Each entry from the arguments is either a valid path or an option
	}
}


# The parseArg subroutine parses arguments from the command-line.

sub parseArg {
	# verify if matches from 
	if ( ){
		
	}
	
	# else it's file name, let's see if it exists
	$_[0]
}
