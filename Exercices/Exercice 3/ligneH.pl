#!/usr/bin/perl -w

use strict;

# Immeuble parser - This perl script parses skylines XML files.
# Recognised format is the following
# <immeuble from="x1" to="x2" h="height />

my $nArg = scalar @ARGV;

# Define variables of files to be parsed and 'from' parameter
my @files = ();
my $from  = 0;

if ($nArg == 0){
	# read from Stdio
	print "Reading from STDIO"
} else{

	foreach (@ARGV){
		&parseArg($_);
	}

	foreach (@files){
		&processFile($_)
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
				die "-from=X can only be defined once.";
			}
		} else{
			die "-from=x: x argument can't be parsed to a positive number";
		}

	} else {

		if (-e $arg) {
			push(@files, $arg);
		} else{
			die "File $arg doesn't exist.";
		}

	}
}

# The processFile subroutine parses a file

sub processFile {

	open(my $file, "<$_" ) or die "Can't open $_: $!\n";

	print "Ligne d'horizon pour $_: \n";

	my $FSM_state = 0;

	while (<$file>) {
		chomp;

		my $number =()= $_ =~ /<immeuble /gi;

		if($number){
		#	print $_ =~ /<immeuble /."\n";
		}

		print $_."\n";
		print $number."\n";

	}

	if ($FSM_state) {
		die "File format of file $_ is not valid."
	}

	close $file;
}
