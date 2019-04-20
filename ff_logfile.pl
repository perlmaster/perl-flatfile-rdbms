#!/usr/bin/perl -w

######################################################################
#
# File      : ff_logfile.pl
#
# Author    : Barry Kimelman
#
# Created   : January 10, 2004
#
# Purpose   : Routines to manage the logfile for the Flatfile RDBMS.
#
######################################################################

use strict;
use lib qw(.);
use My::Myglobalvars qw($activity_log_file_path);

######################################################################
#
# Function  : init_activity_logfile
#
# Purpose   : Initialize the activity logfile.
#
# Inputs    : @_ strings comprising message
#
# Output    : Appends a record to the end of the activity logfile.
#
# Returns   : (nothing)
#
# Example   : &init_activity_logfile();
#
# Notes     : (none)
#
######################################################################

sub init_activity_logfile
{
	my ( $today );

	if ( open(ACTIVITY_LOGFILE,">$activity_log_file_path") ) {
		$today = &format_time_date(time);
		print ACTIVITY_LOGFILE "$today : ",@_;
		close ACTIVITY_LOGFILE;
	} # IF

	return;
} # end of init_activity_logfile

######################################################################
#
# Function  : append_to_activity_logfile
#
# Purpose   : Append a record to the end of the activity logfile.
#
# Inputs    : @_ strings comprising message
#
# Output    : Appends a record to the end of the activity logfile.
#
# Returns   : (nothing)
#
# Example   : &append_to_activity_logfile("Hello world\n");
#
# Notes     : (none)
#
######################################################################

sub append_to_activity_logfile
{
	my ( $today );

	if ( open(ACTIVITY_LOGFILE,">>$activity_log_file_path") ) {
		$today = &format_time_date(time);
		print ACTIVITY_LOGFILE "$today : ",@_;
		close ACTIVITY_LOGFILE;
	} # IF

	return;
} # end of append_to_activity_logfile

1;
