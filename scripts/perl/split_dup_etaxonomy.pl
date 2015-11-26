#!/usr/bin/perl

use warnings;
use strict;

#my $filename = "temp.csv";
my $filename = "dup_etaxonomy.csv";

open( my $fh => $filename) || die "Cannot open $filename: $!";
my $mismatch_count = 0;

my $firstline = 1;

while(my $line = <$fh>) {

	my $irn = '';
	my $secdepartment = '';
	my $genus = '';
	my $species = '';
	my $subspecies = '';
	my $infrasubspecies = '';	
	my $summarydata = '';
	my $leftstring = '';
	my $rightstring = '';
	my $rankstring = '';
	my $valuestring = '';
	
	if ($firstline == 1) {
		print 'irn,SecDepartment,Genus,Species,Subspecies,Infrasubspecies,SummaryData'."\n";
		$firstline = 0;
	}
	else
	{	
		if (substr($line,0,3) ne "irn") {

			# Find position 4th comma			
			my $fourthcommapos = 0;

			my $x = 1;
			while ($line =~ /(,)/g) {
				if ($x == 4) {
					$fourthcommapos = pos $line;
				};				
				$x ++;
		    	}

			$leftstring = substr($line, 0, $fourthcommapos);
			$rightstring = substr($line, $fourthcommapos, length($line) - length($leftstring));			
			
			$rightstring =~ s/,/¬/g;

			$line = $leftstring.$rightstring;

			my @row = split(",",$line);

			$irn = $row[0];
			$secdepartment = $row[1];
			$summarydata = $row[4];

			$rankstring = $row[2];
			$rankstring =~ s/\"//g;
			$rankstring =~ s/\|/@/g;         
			my @ranks = split("@", $rankstring);
	
			$valuestring = $row[3];
			$valuestring =~ s/\"//g;
			$valuestring =~ s/\|/@/g;         
			my @values = split("@", $valuestring);

			my $counter = 0;

			while ($counter < @ranks) {
				if ($ranks[$counter] eq 'Genus') {
					$genus = '"'.$values[$counter].'"';
				} 
				elsif ($ranks[$counter] eq 'Species') {
					$species = '"'.$values[$counter].'"';
				}
				elsif ($ranks[$counter] eq 'Subspecies') {
					$subspecies = '"'.$values[$counter].'"';
				}
				elsif ($ranks[$counter] eq 'Infrasubspecies') {
					$infrasubspecies = '"'.$values[$counter].'"';
				}

				$counter ++;
			}
			
		};

		$summarydata =~ s/¬/,/g;

		print "$irn,$secdepartment,$genus,$species,$subspecies,$infrasubspecies,$summarydata";
	}
}
close($fh);
