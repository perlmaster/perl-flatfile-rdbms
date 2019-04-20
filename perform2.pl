#!/usr/perl5/bin/perl -w

use strict;
use lib qw(.);
use My::Myglobalvars qw($backup_extension);

sub perform2
{
	print "perform2() entered.\n";
	$backup_extension = ".foobar";

	return 0;
}

1;
