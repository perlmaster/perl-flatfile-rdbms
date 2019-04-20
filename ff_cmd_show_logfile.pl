#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_show_logfile.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "Describe Table" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw($mainwin $window_background_color $frame_background_color
			$label_background_color $label_font $text_font $activity_log_file_path
			$text_font $button_background_color $button_font $dialog_font);

my $logfile_win;
my $logfile_textbox;

######################################################################
#
# Function  : show_logfile_screen
#
# Purpose   : Generate the "Show Logfile" command screen.
#
# Inputs    : (none)
#
# Output    : Contents of logfile.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub show_logfile_screen
{
	my ( @data );

	$logfile_win = $mainwin->Toplevel;
	$logfile_win->grab;
	$logfile_win->title("Logfile Contents");
	$logfile_win->configure(-background=>$window_background_color);

	my $mainframe = $logfile_win->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 8);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 8);

	my $label1 = $leftframe_1->Label(
					-background => $label_background_color,
					-text => "Contents of Logfile",
					-font => $label_font)->pack();
	$logfile_textbox = $leftframe_2->Scrolled("Text",-wrap => 'none',
							-font => $text_font)->pack(-side => 'bottom',
						-fill => 'both', -expand => 1);
	if ( open(LOGFILE,"$activity_log_file_path") ) {
		@data = <LOGFILE>;
		close LOGFILE;
		$logfile_textbox->insert('end', @data);
	} # IF
	else {
		$logfile_textbox->insert('end', "Error : $!\n");
	} # ELSE

	$logfile_textbox->configure(-height      => 20,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 50,
		 -font        => $text_font );

	my $button2 = $leftframe_3->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_logfile, -font => $button_font
			)->pack(-side => 'left');

	my $button3 = $leftframe_3->Button(-text => 'Print',
			-background => $button_background_color,
			-command => \&print_logfile, -font => $button_font
			)->pack(-side => 'left');

	my $button4 = $leftframe_3->Button(-text => 'Help',
			-command => \&display_logfile_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return;
} # end of show_logfile_screen

######################################################################
#
# Function  : close_logfile
#
# Purpose   : Process a click of the "Close Description" button on the
#             "Describe Table" screen.
#
# Inputs    : (none)
#
# Output    : Close the window.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub close_logfile
{
	$logfile_win->grabRelease;
	$logfile_win->destroy;

	return;
} # end of close_logfile

######################################################################
#
# Function  : print_logfile
#
# Purpose   : Process a click of the "Print" button on the Logfile
#             window.
#
# Inputs    : (none)
#
# Output    : Print the table description on the system default printer.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub print_logfile
{
	my ( $logfile_data );

	$logfile_data = $logfile_textbox->get('1.0','end');
	print_data($logfile_data);

	return;
} # end of print_logfile

######################################################################
#
# Function  : display_logfile_help_text
#
# Purpose   : Display help text for the "Describe Table" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_logfile_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_logfile_help_text
{
	my ( $dialog , $message );

	$message = <<ENDHELP;
This command displays the contents of the logfile.
ENDHELP

	$dialog = $logfile_win->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Show Logfile Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_logfile_help_text

1;
