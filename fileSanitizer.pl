#!/usr/bin/perl
#
# @author Greg Morgan
# @version 0.1
#
# Sanitize (remove IP addrs etc.) from a text file.
#
# To see the sanitized values
#
#  > filesanitizer.pl -v < myLogFile 2> filter.txt
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
my $opt_string = 'hvo:f:s:q';
my @fileList;

#
# usage()
#
sub usage()
{
	print STDERR "Usage: $0 [-hqv] [-f file] [-o file] [-s string]\n";
	print STDERR "\t-f file   : Input file (Default STDIN)\n";
	print STDERR "\t-h        : this message\n";
	print STDERR "\t-o file   : Output file (Default STDOUT)\n";
	print STDERR "\t-q		  : Quite. No console output\n";
	print STDERR "\t-s string : Sanitize string. Default='UI' [U=Username, I=IP Addres]\n";	
	print STDERR "\t-v        : Verbose output to STDERR\n";
	print STDERR "\n";
	print STDERR "Example: $0 -v infile\n";
	exit();
}

#
# Sanitize user="10.0.128.16" type log data.  Does not do IPv6.
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
# Sanitize user="..." type log data.
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
	my ($inFilename) = @_;

	if ($inFilename eq "STDIN") {
		$infile = \*STDIN;
	} else {
		open ($infile, "<", $inFilename) or die "Cannot open input file $inFilename: $!";
	}

	if (!$opt{q}) {
		print STDERR "Parsing $inFilename ...\n";
	}

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

	if ($inFilename ne "STDIN") {
		close($infile);
	}

	if (!$opt{q}) {
		print STDERR "Parsing $inFilename ... $n lines. Done.\n";
	}
}

#
# main
#

getopts( "$opt_string", \%opt ) or usage();

usage() if $opt{h};

if ($opt{v} && $opt{q}) {
	$opt{q} = 0;
}

# default filter is all of them
if (!$opt{s}) {
	$opt{s} = "UI"; # 'U' = usernames, 'I' = ip addresses
}

if ($opt{f}) {
	@fileList = "$opt{f}";
} else {
	if (@ARGV == 0) {
		@fileList = qw(STDIN);
	} else {
		@fileList = @ARGV;
	}
}

if (@fileList == 0) {
	die("Error - No files\n");
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

# end file



