#!/usr/bin/perl
use warnings;
use strict;
use Net::Traceroute::PurePerl;
use Data::Dumper;
use IO::Handle;

my $timeout = 3;

my $src = $ARGV[0];
my $des = $ARGV[1];

if (not defined $des) {
	print "USAGE: pltrcrt.pl [infile] [outfile]\n";
	exit 0;
}

open(my $SRC,'<',$src) or die $!;
open(my $DES,'>',$des) or die $!;
 
 
while (<$SRC>) {
	my $t = new Net::Traceroute::PurePerl(
     		backend        => 'PurePerl', 
     		host           => $_,
     		debug          => 0,
     		max_ttl        => 10,
     		query_timeout  => 2,
     		packetlen      => 40,
    		protocol       => 'icmp',
     		timeout 	   => $timeout,
	);
	eval {
		local $SIG{ALRM} = sub {
			die "timeout" 
		};
		alarm $timeout;
		$t->traceroute();
		alarm 0;
		
		for (my $i = $t->hops; $i >= 1; $i--){
			if ($t->hop_query_stat($i,1)){
				print "NULL,";
				print $DES "NULL,";
			} else {
				print $t->hops,",";
				print $DES $t->hops,",";
				print $t->hop_query_host($i,0);
				print $DES $t->hop_query_host($i,0);
				if ($i != 1) { 
					print ",";
		       			print $DES ",";
				}
			}
		}
		print "\n";
		print $DES "\n";
		$DES->flush();
	}
}
close($SRC);
close($DES);
