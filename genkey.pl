#!/usr/bin/perl

use strict;

MAIN:
{
	my ( $maxval , $count , $number , %random , @numbers , $alphnum );
	my ( @array1 , @array2 , $encrypt );

	if ( 1 > @ARGV ) {
		$alphnum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-,;:(){}~!%^=*";
	} # IF
	else {
		$alphnum = $ARGV[0];
	} # ELSE
	$maxval = length $alphnum;
	$count = $maxval;

	srand( time() - ($$ + ($$ << 15)) );
	%random = ();
	@numbers = ();
	for ( ; $count > 0 ; ) {
		$number = int(rand $maxval);
		if ( ! exists $random{$number} ) {
			$count -= 1;
			$random{$number} = 1;
			push @numbers,$number;
		} # IF
	} # FOR

	@array1 = split(//,$alphnum);
	@array2 = @array1[@numbers];
	$encrypt = join("",@array2);
	print "$encrypt\n";

	exit 0;
} # end of MAIN
