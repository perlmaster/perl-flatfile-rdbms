#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_default_fonts.pl
#
# Author    : Barry Kimelman
#
# Created   : August 18, 2005
#
# Purpose   : Perl/Tk script to implement the "Default Fonts" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw(@session_command_history $mainwin);

######################################################################
#
# Function  : set_fonts_to_default
#
# Purpose   : Display session information.
#
# Inputs    : (none)
#
# Output    : Screen displaying session information.
#
# Returns   : (nothing)
#
# Example   : set_fonts_to_default();
#
# Notes     : (none)
#
######################################################################

sub set_fonts_to_default
{
	my ( $clock , $now );

	$clock = time;
	$now = format_time_date($clock);
	push @session_command_history,"session";

###	$default_fonts_win2->minsize( qw(30 10));

	$mainwin->messageBox(-type => 'OK', -icon => 'error',
					-message => "command not yet implemented",
						-title => 'Set Fonts To Default Values' );

	return;
} # end of display_session_info

1;
