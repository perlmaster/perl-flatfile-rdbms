#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_gui.pl
#
# Author    : Barry Kimelman
#
# Created   : August 13, 2006
#
# Purpose   : Perl/Tk script used to access the Flatfile RDBMS.
#
######################################################################

use strict;
use warnings;

require Tk;
use Tk;
require Tk::Dialog;
use Data::Dumper;
use File::Spec;
use FindBin;
use lib $FindBin::Bin;
use lib qw(.);
use My::Myglobalvars qw($mainwin $listbox_font $listbox_background_color $button_font
			$button_background_color $label_font $label_background_color $text_font
			$dialog_font $frame_background_color $window_background_color $session_start_clock
			$session_start_time @session_command_history $tempdir $errmsg %default_fonts
			$debug_flag);

require "flatfile_files.pl";
require "flatfile_rdbms.pl";
require "ff_cmd_list_tables.pl";
require "ff_cmd_describe_table.pl";
require "ff_cmd_create_table.pl";
require "ff_cmd_select_records.pl";
require "ff_cmd_insert_record.pl";
require "flatfile_validate.pl";
require "time_date.pl";
require "ff_cmd_delete_records.pl";
require "ff_cmd_delete_table.pl";
require "ff_cmd_update_records.pl";
require "ff-compare.pl";
require "ff_encrypt_text.pl";
require "ff_print_data.pl";
require "ff_widgets.pl";
require "ff_cmd_session.pl";
require "ff_logfile.pl";
require "ff_query.pl";
require "ff_cmd_show_logfile.pl";
require "ff_cmd_load_table.pl";
require "ff_cmd_default_fonts.pl";

my $Version = "1.0  December 24, 2003";

my @command_buttons;

######################################################################
#
# Function  : debug_print
#
# Purpose   : Optionally print a debugging message.
#
# Inputs    : @_ - array of strings comprising message
#
# Output    : (none)
#
# Returns   : nothing
#
# Example   : debug_print("Process the files : ",join(" ",@xx),"\n");
#
# Notes     : (none)
#
######################################################################

sub debug_print
{
	if ( $debug_flag ) {
		print join("",@_);
	} # IF

	return;
} # end of debug_print

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
# Example   : ff_gui.pl [database_directory]
#
# Notes     : (none)
#
######################################################################

	my ( $count , $dirname , $status , $menu_bar , $file_mb , $help_mb );
	my ( $button , $fonts_mb );

	My::Myglobalvars::init_globals();
	$tempdir = exists $ENV{"TEMP"} ? $ENV{"TEMP"} : "C:\\TEMP";

	debug_print("$0 : tempdir = $tempdir\n");
	$session_start_clock = time;
	$session_start_time = &format_time_date($session_start_clock);

	$listbox_font = $default_fonts{"listbox_font"};
	$listbox_background_color = $default_fonts{"listbox_background_color"};
	$button_font = $default_fonts{"button_font"};
	$button_background_color = $default_fonts{"button_background_color"};
	$label_font = $default_fonts{"label_font"};
	$label_background_color = $default_fonts{"label_background_color"};
	$text_font = $default_fonts{"text_font"};
	$dialog_font = $default_fonts{"dialog_font"};
	$window_background_color = $default_fonts{"window_background_color"};
	$frame_background_color = $default_fonts{"frame_background_color"};


	$errmsg = "";
	@session_command_history = ();

	$dirname = ( 1 > @ARGV) ? "rdbms" : shift @ARGV;
	$status = &init_flatfile_rdbms_system($dirname);
	unless ( $status ) {
		die("Error : $errmsg\n");
	} # UNLESS

	$frame_background_color = $window_background_color;

	$mainwin = MainWindow->new();
	$mainwin->minsize( qw(400 250));
	$mainwin->title("Flatfile RDBMS Test");
	$mainwin->configure(-background=>$window_background_color);

	$menu_bar = $mainwin->Frame(-relief=>'groove', -borderwidth => 3,
								-background => 'purple',)->pack('-side' => 'top',
								-fill => 'x');
	$file_mb = $menu_bar->Menubutton(-text => 'File' , -background => 'purple',
									-activebackground => 'cyan',
									-foreground => 'white' ,)->pack(-side => 'left');
	$file_mb->command(-label => 'Exit', -activebackground => 'magenta',
					-command => \&exit_session);
	$file_mb->separator();

	$fonts_mb = $menu_bar->Menubutton(-text => 'Fonts' , -background => 'purple',
									-activebackground => 'cyan',
									-foreground => 'white' ,)->pack(-side => 'left');
	$fonts_mb->command(-label => 'Default Fonts', -activebackground => 'magenta',
					-command => \&set_fonts_to_default);
	$fonts_mb->separator();


	$help_mb = $menu_bar->Menubutton(-text => 'Help', -background => 'purple',
					-activebackground => 'cyan',
					-foreground => 'white',
					)->pack(-side => 'right');

	$help_mb->command(-label => 'About', -activebackground => 'magenta',
					-command => \&display_about_text);
	$help_mb->command(-label => 'Help', -activebackground => 'magenta',
					-command => \&display_help_text);
	$help_mb->separator();

	my $mainframe = $mainwin->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $font1 = "Courier 12 bold";

	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 14, -padx => 5);
	my $pre = $leftframe_2->Label(-text => 'Click button to execute indicated command',
						-background => $frame_background_color,-font => $font1)->pack();
	my $button_width = 15;
	my $button_side = 'top';
	@command_buttons = ( [ "List Tables" , \&list_tables_cmd ],
					[ "Describe Table" , \&generate_describe_table_screen ],
					[ "Create Table" , \&generate_create_table_screen ],
					[ "Load Table" , \&generate_load_table_window ],
					[ "Select Records" , \&generate_select_records_window ],
					[ "Insert Record" , \&generate_insert_record_screen ],
					[ "Delete Records" , \&generate_delete_records_screen ],
					[ "Delete Table" , \&generate_delete_table_screen ],
					[ "Update Records" , \&generate_update_records_screen ] ,
					[ "Show Logfile", \&show_logfile_screen ],
					[ "Session" , \&display_session_info ]
				) ;
	for ( $count = 0 ; $count <= $#command_buttons ; ++$count ) {
		$button = $leftframe_2->Button(-text => $command_buttons[$count][0], 
				-width => $button_width, -background => $button_background_color,
				-command => $command_buttons[$count][1], -font => $button_font
				)->pack(-side => $button_side);
	} # FOR

	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 5);
	$button = $leftframe_3->Button(-text => "Exit", 
			-width => $button_width, -background => $button_background_color,
			-command => \&exit_session, -font => $button_font
			)->pack(-side => $button_side);

	MainLoop;

	exit 0;

######################################################################
#
# Function  : display_help_text
#
# Purpose   : Display general help text for the utility.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : &display_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_help_text
{
	my ( $dialog , $message );

	$message = <<ENDHELP;
This utility provides a GUI style interface to the Perl Flatfile
Relational Database Management System.
ENDHELP
	$dialog = $mainwin->Dialog(-text => $message, -bitmap => 'info',
			-title => 'General Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => "Courier 10 bold" );
	$dialog->Show();

	return;
} # end of display_help_text

######################################################################
#
# Function  : display_about_text
#
# Purpose   : Display help text describing this version of the utility.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : &display_about_text();
#
# Notes     : (none)
#
######################################################################

sub display_about_text
{
	my ( $dialog , $message );

	$message = "Version ";
	$message .= <<ENDHELP;
$Version

Copyright (C) Barry Kimelman 2003
ENDHELP
	$dialog = $mainwin->Dialog(-text => $message, -bitmap => 'info',
			-title => 'About', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => "Courier 10 bold" );
	$dialog->Show();

	return;
} # end of display_about_text

######################################################################
#
# Function  : exit_session
#
# Purpose   : Process user's request to terminate execution.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : &exit_session();
#
# Notes     : (none)
#
######################################################################

sub exit_session
{

	$mainwin->destroy;
	exit 0;
} # end of exit_session
