#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_print_data.pl
#
# Author    : Barry Kimelman
#
# Created   : January 2 14, 2004
#
# Purpose   : Send data to the printer.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw($tempdir);

######################################################################
#
# Function  : print_data
#
# Purpose   : Send data to the printer.
#
# Inputs    : $_[0] - data to be printed
#
# Output    : (none)
#
# Returns   : (nothing)
#
# Example   : &print_data($query_result);
#
# Notes     : (none)
#
######################################################################

sub print_data
{
	my ( $data ) = @_;
	my ( $tempfile , $now , $print_command );

	$now = &format_time_date(time);
	$tempfile = File::Spec->catfile($tempdir,"data.$$");
	$print_command = "notepad /p";
	if ( open(QUERY_DATA,">$tempfile") ) {
		print QUERY_DATA "\nPrinted $now\n\n$data";
		close QUERY_DATA;
		system("$print_command $tempfile");
		unlink $tempfile;
	} # IF
	return;
} # end of print_data

1;
