#!/usr/bin/perl
#
# @author Greg Morgna
# @version 0.1
#
# Sanitize (remove IP addrs etc.) from a text file.
#

use strict;
use warnings;

no strict 'refs'; # needed to assign STDOUT

use Getopt::Std;

#
# Globals
#
use vars qw/ %opt /;

my $outfile;

#my $infile = \*STDIN; # or die "Cannot open STDIN: $!";
#
#while (my $line = <$infile>) {
#	print STDERR "XXX $line";
#}
#
#die();

#
# usage()
#
sub usage()
{
	print STDERR "Usage: $0 [-hv] [-f file] [-o file] [-s string]\n";
	print STDERR "\t-f file   : Input file\n";
	print STDERR "\t-h        : this message\n";
	print STDERR "\t-s string : Sanitize string. Default='UI' [U=Username, I=IP Addres]\n";
	print STDERR "\t-o file   : Output file\n";
	print STDERR "\t-v        : Verbose output to STDERR\n";
	print STDERR "\n";
	print STDERR "Example: $0 -v -d -fofile\n";
	exit();
}

#
#
#
sub sanitizeIPv4 {
	my ($line, $n) = @_;

	my @matches = ($line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?:\:\d{1,5})*/gm);

	if (@matches > 0) {
		$line =~ s/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?:\:\d{1,5})*/n\.n\.n\.n/g; 

		if ($opt{v}) {
			print STDERR "Line " . $n . ": " . join(", ", @matches) . "\n";
		}
	}

	return $line;
}

#
#
#
sub sanitizeUsername {

	my ($line, $n) = @_;

	my @matches = ($line =~ /\s+user\=([^\s]+)\s+/g);

	if (@matches > 0) {
		$line =~ s/\s+user=([^\s]+)*\s+/ user="XXXX" /g;

		if ($opt{v}) {
			print STDERR "Line " . $n . ": " . join(", ", @matches) . "\n";
		}
	}

	return $line;
}


#
# parseFile()
#
sub parse 
{
	my $infile;
	my ($filename) = @_;

	if ($filename eq "STDIN") {
		$infile = \*STDIN;
	} else {
		open ($infile, "<", $filename) or die "Cannot open input file $filename: $!";
	}

	print STDERR "Parsing $filename ...\n";

	my $n = 0;

	while(my $line = <$infile>) {
		$n++;

		# ip addresses
		if (index($opt{s}, 'I') != -1) {
			$line = sanitizeIPv4($line, $n); 
		}

		# usernames
		if (index($opt{s}, 'U') != -1) {
			$line = sanitizeUsername($line, $n); 
		}

		print $outfile $line;
	}

	if ($filename eq "STDIN") {
		close($infile);
	}

	if ($opt{v}) {
		print STDERR "Parsing $filename ... $n lines. Done.\n";
	}
}


#
# main
#

my $opt_string = 'hvo:f:s:';
getopts( "$opt_string", \%opt ) or usage();
usage() if $opt{h};

my @fileList;

if (!$opt{f} && @ARGV == 0) {
	print STDERR "No input files.\n";
	usage();
}

# default filter is all of them
if (!$opt{s}) {
	$opt{s} = "UI";
}

if ($opt{f}) {
	if ($opt{f} eq "-") {
		@fileList = qw(STDIN);
	} else {
		@fileList = "$opt{f}";
	}
} else {
	if (@ARGV == 1 && $ARGV[0] eq "-") {
		@fileList = qw(STDIN);
	} else {
		@fileList = @ARGV;
	}
}

if (@fileList == 0) {

}

if ($opt{v}) {
	  my $state = ($opt{v}) ? "ON": "OFF";
	  print STDERR "Verbose mode $state.\n";

	  print STDERR "Using infile " . "@fileList" . ".\n";

	  $state = ($opt{o}) ? "$opt{o}": "STDOUT";
	  print STDERR "Using outfile $state.\n";
}

if ($opt{o}) {
	open ($outfile, ">", $opt{o}) or die "Cannot open output file $opt{o}: $!";
} else {
	$outfile = select (STDOUT); 
}	

foreach my $file (@fileList) {
	parse($file);
}

if ($opt{o}) {
	close($outfile);
}

if ($opt{v}) {
	print STDERR "Done.\n"
}

# end file



