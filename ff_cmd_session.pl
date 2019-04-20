#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_session.pl
#
# Author    : Barry Kimelman
#
# Created   : January 7, 2004
#
# Purpose   : Perl/Tk script to implement the "Session" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw(@session_command_history $mainwin $window_background_color
			$frame_background_color $text_font $session_start_time $button_background_color
			$button_font);

my $session_win2;
my $session_textbox;

######################################################################
#
# Function  : display_session_info
#
# Purpose   : Display session information.
#
# Inputs    : (none)
#
# Output    : Screen displaying session information.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub display_session_info
{
	my ( $clock , $now , $mainframe , $leftframe_1 , $command );

	$clock = time;
	$now = format_time_date($clock);
	push @session_command_history,"session";

	$session_win2 = $mainwin->Toplevel;
	$session_win2->grab;

###	$session_win2->minsize( qw(30 10));
	$session_win2->title("Session Information");
	$session_win2->configure(-background=>$window_background_color);

	$mainframe = $session_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	$leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);

	$session_textbox = $leftframe_1->Scrolled("Text",
							-wrap => 'none', -height => 15,
							-font => $text_font)->pack(-side => 'top',
						-fill => 'both', -expand => 1);

	$session_textbox->delete('1.0','end');
	$session_textbox->insert("end","Session started : $session_start_time\n");
	$session_textbox->insert("end","Current Time    : $now\n\nCommand History :\n\n");
	foreach $command ( @session_command_history ) {
		$session_textbox->insert("end","$command\n");
	} # FOREACH


	my $button1 = $leftframe_1->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_session, -font => $button_font
			)->pack(-side => 'top');

	return;
} # end of display_session_info

######################################################################
#
# Function  : close_session
#
# Purpose   : Process a clikc of the "Close" button.
#             screen.
#
# Inputs    : (none)
#
# Output    : Screen displaying close message.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub close_session
{
	$session_win2->grabRelease;
	$session_win2->destroy;
	return;
} # end of close_session

1;
