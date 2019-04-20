#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_list_tables.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "List Tables" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw($mainwin @session_command_history $frame_background_color
			$label_font $label_background_color $listbox_background_color
			$listbox_font @systables_entries $systables_tablename_column
			$button_font $button_background_color $dialog_font);

my $list_win2;
my $list_tables_listbox;

######################################################################
#
# Function  : list_tables_cmd
#
# Purpose   : Execute the "List Tables" command.
#
# Inputs    : (none)
#
# Output    : Screen displaying a list of database tables.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub list_tables_cmd
{
	my ( $count );

	$list_win2 = $mainwin->Toplevel;
	$list_win2->grab;
	push @session_command_history,"list tables";

###	$list_win2->minsize( qw(30 10));
	$list_win2->title("Listing of Defined Database Tables");
	$list_win2->configure(-background=>$frame_background_color);

	my $mainframe = $list_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 10, -padx => 15);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 10, -padx => 15);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 10, -padx => 15);

	my $label1 = $leftframe_1->Label(-text => 'Currently defined tables are :',
								-font => $label_font,
								-background => $label_background_color
								)->pack();
	$list_tables_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();
	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$list_tables_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	} # FOR

	my $button1 = $leftframe_3->Button(-text => 'Close',
			-command => \&close_list_tables,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	my $button2 = $leftframe_3->Button(-text => 'Print',
			-command => \&print_list_tables,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	my $button3 = $leftframe_3->Button(-text => 'Help',
			-command => \&display_list_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return;
} # end of list_tables_cmd

######################################################################
#
# Function  : close_list_tables
#
# Purpose   : Process a clikc of the "Close" button on the "List Tables"
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

sub close_list_tables
{
	$list_win2->grabRelease;
	$list_win2->destroy;
	return;
} # end of close_list_tables

######################################################################
#
# Function  : print_list_tables
#
# Purpose   : Process a click of the "Print" button on the tables
#             listing window.
#
# Inputs    : (none)
#
# Output    : Print the list of tables on the system default printer.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub print_list_tables
{
	my ( @tables , $data );

	$data = "Currently defined tables are :\n\n";
	@tables = $list_tables_listbox->get('0','end');
	$data .= join("\n",@tables);
	print_data($data);

	return;
} # end of print_list_tables

######################################################################
#
# Function  : display_list_help_text
#
# Purpose   : Display help text for the "List Tables" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_list_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_list_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command displays a list of all the currently defined tables.

For detailed information on a table you can use the "Describe Table"
command.
ENDHELP

	$dialog = $list_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'List Tables Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_list_help_text

1;
