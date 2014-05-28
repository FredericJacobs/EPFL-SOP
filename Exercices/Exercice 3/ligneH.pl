#!/usr/bin/perl -w

use strict;

my $nArg = scalar @ARGV;

# Define variables of files to be parsed and 'from' parameter

my @files = ();
my $from  = 0;


if ($nArg > 0){

	# Let's parse the argument and perform some basic validation on the files

	foreach (@ARGV){
		&parseArg($_);
	}

}


if (scalar @files < 1){

	my @buildings = &processStdIn();
	my @horizonline = &drawHorizonline(@buildings);

	print " \nLigne d'horizon pour stdin: \n";

	&printHorizonline(@horizonline);

} else {

	# Let's parse each 'xml' file and add to the buildings it contain to the buildings array.

	foreach (@files){
		my $file = $_;
		my @buildings = &processFile($file);

		if (scalar @buildings < 1){
			print "$_ does not contain any building information."
		} else{
			my @horizonline = &drawHorizonline(@buildings);

			#Finally, let's output them with the appropriate format.
			print "\nLigne d'horizon pour ".$file."\n";
			&printHorizonline(@horizonline);
		}
	}
}

print "\n";

# The parseArg subroutine parses arguments from the command-line.

sub parseArg{

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

		if (-e $arg){
			push(@files, $arg);
		} else{
			die "File $arg doesn't exist.";
		}

	}
}

sub processStdIn{

	# By substituting the field record separator, we can process one entry at the time.
	$/ = "/>";

	my @buildingsInFile = ();

	while (<STDIN>){
		my $temp = &parseEntry($_);

		if($temp){
				push @buildingsInFile, &parseEntry($temp);
		}
	}

	return @buildingsInFile;
}

# The processFile subroutine parses a file

sub processFile{

	open(my $file, "<$_" ) or die "Can't open $_: $!\n";

	# By substituting the field record separator, we can process one entry at the time.
	$/ = "/>";

	my @buildingsInFile = ();

  while (<$file>){
		my $temp = &parseEntry($_);

		if($temp){
				push @buildingsInFile, &parseEntry($temp);
		}
	}

	close $file;
	return @buildingsInFile;
}

sub parseEntry{
	# We validate entries
	my @entry = /<immeuble\s+([^\/]+)\/>/g;

	if(@entry){

		my @args = split /\s+/, $entry[0];
		my $immeuble = {};

		foreach (@args){
			my ($property_name, $value) = $_ =~ /(\w+)="([0-9]+)"/;
			$immeuble->{$property_name} = scalar $value;
		}
		return $immeuble;
	}
}


sub drawHorizonline{

	# Implementation of the suggested algorithm

	my @buildings = @_;

	# We make an array with all the abscisses

  my @xs = ();

  foreach (@buildings){

		my $b_from = $_->{'from'};
		my $b_to	 = $_->{'to'};

		if ($b_from and ($b_to > $from)){
	    push @xs, $_->{'from'};
	    push @xs, $_->{'to'};
		}
	}

	# Sort array in ascending order

  @xs = sort{ $a <=> $b } @xs;

	# Initializing sky variable to 0

  my $ciel = 0;

	# Make horizon, starting from the specified from abscisse.

	my @horizonline = ();

  if ($from < $xs[0]){
    push @horizonline, [$from, 0];
  }

  foreach my $x (@xs){

		# h is the highest height encountered in the loop.

	  my $h = 0;

		foreach my $building (@buildings){
	    if (($x >= $building->{'from'}) and ($x < $building->{'to'}) and ($building->{'h'}) > $h){
	      $h = $building->{'h'};
	    }
	  }

	  if ($h != $ciel and $x > $from or (($x == $from) and $from >= $xs[0])){
	    push @horizonline, [$x, $ciel], [$x, $h];
	    $ciel = $h;
	  }
  }

  return @horizonline;
}

sub printHorizonline{

  foreach (@_){
    print "(".$_->[0].",".$_->[1]."); ";
  }
	
  print "\n";

}
