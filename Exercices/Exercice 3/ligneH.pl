#!/usr/bin/perl -w

use strict;

# Immeuble parser - This perl script parses skylines XML files.
# Recognised format is the following
# <immeuble from="x1" to="x2" h="height />

my $nArg = scalar @ARGV;

# Define variables of files to be parsed and 'from' parameter
my @files = [];
my $from  = 0;

if ($nArg == 0){
	# read from Stdio
	print "Reading from STDIO"
} else{

	foreach (@ARGV){
		&parseArg($_);
		#Each entry from the arguments is either a valid path or an option
	}
}


# The parseArg subroutine parses arguments from the command-line.

sub parseArg {

	my $arg = $_[0];
	
	if($arg =~ m/^-from=/m){

		if ($arg =~ /(?<=^-from=)([0-9]*)$/ ){
			if (!$from){
				$from = $1;
			} else{
				print "-from=X can only be defined once.";
				exit 1;
			}
		} else{
			print "-from=x: x argument can't be parsed to a positive number";
			exit 1;
		}

	} else {

		if (-e $arg) {
			push(@files, $arg);
		} else{
			print "File $arg doesn't exist.";
			exit 1;
		}

	}
}
