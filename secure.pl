#!/usr/bin/perl

use strict;
use Getopt::Std;

sub encode_string
{
	my( $string ) = @_;

	for ( $string ) {
		eval qq{ tr/${alphnum}/${encrypt}/ };
	} # FOR

	return $string;
}

sub decode_string
{
	my ( $string ) = @_;

	for ( $string ) {
		eval qq{ tr/${encrypt}/${alphnum}/ };
	} # FOR

	return $string;
}

MAIN:
{
	my ( $maxval , $count , $number , %random , $numbers , $alphnum );
	my ( @array1 , @array2 , $encrypt , $old , $new , $test );

	$alphnum = "abcdefghijklmnopqrstuvwxyz0123456789";
	$maxval = length $alphnum;
	$count = $maxval;

	srand( time() - ($$ + ($$ << 15)) );
	%random = ();
	for ( ; $count > 0 ; ) {
		$number = int(rand $maxval);
		if ( ! exists $random{$number} ) {
			$count -= 1;
			$random{$number} = 1;
		} # IF
	} # FOR
	@numbers = keys %random;

	@array1 = split(//,$alphnum);
	@array2 = @array1[@numbers];
	$encrypt = join("",@array2);
	print "$alphnum\n$encrypt\n";

	foreach $old ( @ARGV ) {
		print "$old\n";
		$new = encode_string($old);
		print "$new\n";

		$test = decode_string($new);
		print "$test\n";
	} # FOREACH

	exit 0;
} # end of MAIN
