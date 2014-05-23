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

	&parseArgs(@ARGV);

	while(<>){
		print $_;
	}

}


# The parseArg subroutine parses arguments from the command-line.

sub parseArgs {

	foreach my $index (0 .. $#ARGV) {

		my $arg = $_[$index];

		if($arg =~ m/^-from=/m){

			# The argument is a -from option, proceed to validation

			if ($arg =~ /(?<=^-from=)([0-9]*)$/ ){
				if (!$from){
					$from = $1;
					delete $ARGV[$index];
				} else{
					print "-from=X can only be defined once.";
					exit 1;
				}
			} else{
				print "-from=x: x argument can't be parsed to a positive number";
				exit 1;
			}

		} else {

			# The argument is not an option, it's a file. Let's check if it exists.

			if (! -e $arg) {
				print "File $arg doesn't exist.";
				exit 1;
			}
		}
	}
}
