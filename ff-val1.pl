#!/usr/bin/perl -w

######################################################################
#
# File      : val1.pl
#
# Author    : Barry Kimelman
#
# Created   : December 12, 2003
#
# Purpose   : Test program for Data validation routines.
#
######################################################################

use strict;
use FindBin;
use lib $FindBin::Bin;

require "flatfile_validate.pl";

######################################################################
#
# Function  : MAIN
#
# Purpose   : Program entry point.
#
# Inputs    : @ARGV
#
# Output    : Various messages and screens
#
# Returns   : (nothing)
#
# Example   : val1.pl data_type string
#
# Notes     : (none)
#
######################################################################

	my ( $string , $type );
	my %valid_data_types = ( "int" => \&validate_int , "float" => \&validate_float ,
							"string" => \&validate_string , "timedate" => \&validate_timedate );
	my ( $status , $func );

	if ( 2 != @ARGV ) {
		die("Usage : $0 data_type string\n");
	} # IF

	( $type , $string ) = @ARGV;
	unless ( exists $valid_data_types{$type} ) {
		die("Invalid data type\n");
	} # UNLESS

	$func = $valid_data_types{$type};
	$status = &$func($string);
	print "status = $status\n";
	unless ( $status ) {
		print "$errors::errmsg\n";
	} # UNLESS

	exit 0;
