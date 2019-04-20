#!/usr/perl5/bin/perl -w

use strict;
use lib qw(.);
use My::Myglobalvars qw($backup_extension);

sub init_flat2
{
	print "Call My::Myglobalvars::init_globals()\n";

	My::Myglobalvars::init_globals();

	return 0;
}

1;
