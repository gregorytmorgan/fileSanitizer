#!/usr/bin/perl
#
# Sanitize (remove IP addrs etc.)  a text file.
#

use strict;

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
	print STDERR "Usage: $0 [-hvd] [-f file]\n";
	print STDERR "\t-h        : this message\n";
	print STDERR "\t-v        : Verbose output to STDERR\n";
	print STDERR "\t-f file   : Input file\n";
	print STDERR "\t-p file   : Output file\n";
	print STDERR "\n";
	print STDERR "Example: $0 -v -d -f file\n";
	exit();
}


#
# parseFile()
#
sub parseForIPs 
{
	my $infile;
	my ($filename) = @_;

	if ($filename eq "STDIN") {
		$infile = \*STDIN;
	} else {
		open ($infile, "<", $filename) or die "Cannot open input file $filename: $!";
	}

	print STDERR "Tell:" . tell($infile) . "\n";

	print STDERR "Parsing $filename ...\n";

	my $n = 0;

	while(my $line = <$infile>) {
		$n++;

		my @matches = ($line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?:\:\d{1,5})*/gm);

		if (@matches > 0) {
			$line =~ s/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?:\:\d{1,5})*/0\.0\.0\.0/g; 

			if ($opt{v}) {
				print STDERR "Line " . $n . ": " . join(", ", @matches) . "\n";
			}
		}

		print $outfile $line;
	}

	if ($filename != "STDIN") {
		close($infile);
	}

	if ($opt{v}) {
		print STDERR "Parsing $filename ... $n lines. Done.\n";
	}
}


#
# main
#

my $opt_string = 'hvdo:f:';
getopts( "$opt_string", \%opt ) or usage();
usage() if $opt{h};

my @fileList;

if (!$opt{f} && @ARGV == 0) {
	print STDERR "No input files.\n";
	usage();
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
	parseForIPs($file);
}

if ($opt{o}) {
	close($outfile);
}

if ($opt{v}) {
	print STDERR "Done.\n"
}

# end file



