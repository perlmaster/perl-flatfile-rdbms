#!/usr/bin/perl -w

######################################################################
#
# File      : ff-create.pl
#
# Author    : Barry Kimelman
#
# Created   : August 13, 2006
#
# Purpose   : Test program to create the Flatfile RDBMS.
#
######################################################################

use strict;
use Data::Dumper;
use File::Spec;
use FindBin;
use lib $FindBin::Bin;
use lib qw(.);
use My::Myglobalvars qw($errmsg);

require "flatfile_files.pl";
require "flatfile_rdbms.pl";
require "time_date.pl";
require "ff_encrypt_text.pl";
require "ff_logfile.pl";

MAIN:
{
	my ( $status , $dirname );

	$errmsg = "";

	$dirname = ( 1 > @ARGV) ? "rdbms" : $ARGV[0];
	$status = create_flatfile_rdbms_system($dirname);
	if ( $status == 0 ) {
		print "Error : $errmsg\n";
	} # IF
	else {
		print "database successfully created under $dirname\n";
	} # ELSE

	exit 0;
} # end of MAIN
