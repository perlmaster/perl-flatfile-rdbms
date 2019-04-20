#!/usr/bin/perl

use strict;
use FindBin;
use lib $FindBin::Bin;

require "encrypt_text.pl";

MAIN:
{
	my ( $old , $new , $test );

	foreach $old ( @ARGV ) {
		print "$old\n";
		$new = encode_string($old);
		print "$new\n";

		$test = decode_string($new);
		print "$test\n";
	} # FOREACH

	exit 0;
} # end of MAIN
