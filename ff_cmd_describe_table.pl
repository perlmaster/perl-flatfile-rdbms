#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_describe_table.pl
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
use My::Myglobalvars qw($mainwin @session_command_history $window_background_color
			$frame_background_color $label_background_color $label_font
			$listbox_background_color $listbox_font @systables_entries
			$systables_tablename_column $text_font $button_background_color
			$button_font $dialog_font);

my $describe_table_listbox;
my $describe_table_textbox;
my $description_flag;
my $describe_win2;
my $describe_table_tablename;

######################################################################
#
# Function  : generate_describe_table_screen
#
# Purpose   : Generate the "Describe Table" command screen.
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

sub generate_describe_table_screen
{
	my ( $count );

	$describe_win2 = $mainwin->Toplevel;
	$description_flag = 0;
	$describe_win2->grab;
	push @session_command_history,"describe table";

	$describe_win2->title("Description of Database Table");
	$describe_win2->configure(-background=>$window_background_color);

	my $mainframe = $describe_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 5);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 5);
	my $leftframe_4 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 4, -padx => 5);
	my $label1 = $leftframe_1->Label(
					-background => $label_background_color,
			-text => "Select a table from the list",
					-font => $label_font)->pack();

	$describe_table_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();
	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$describe_table_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}
	$describe_table_listbox->bind('<1>' => \&event_describe_table_selection);

	$describe_table_textbox = $leftframe_3->Scrolled("Text",-wrap => 'none',
							-font => $text_font)->pack(-side => 'bottom',
						-fill => 'both', -expand => 1);
	$describe_table_textbox->configure(-height      => 20,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 50,
		 -font        => $text_font );
#
	my $button2 = $leftframe_4->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_description, -font => $button_font
			)->pack(-side => 'left');

	my $button3 = $leftframe_4->Button(-text => 'Print',
			-background => $button_background_color,
			-command => \&print_description, -font => $button_font
			)->pack(-side => 'left');

	my $button4 = $leftframe_4->Button(-text => 'Help',
			-command => \&display_describe_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return;
} # end of generate_describe_table_screen

######################################################################
#
# Function  : show_table_description
#
# Purpose   : Process a click of the "Show Description" button on the
#             "Describe Table" screen.
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

sub show_table_description
{
	my ( $selected , @attributes , $description );
	my ( $count , @columns , $colnum , @lines , $num_lines , $textbox );
	my ( @column_names );

	unless ( fetch_table_info($describe_table_tablename,\@attributes) ) {
		$describe_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "Table \"$describe_table_tablename\" does not exist",
						-title => 'Your Selection' );
		$describe_win2->grabRelease;
		$describe_win2->destroy;
		return;
	} # UNLESS

	$describe_table_textbox->delete('1.0','end');
	$description = "Table $describe_table_tablename\n\n";
	$description .= "Filename : $attributes[1]\n";
	$description .= "Table_id : $attributes[2]\n";
	$description .= "Created  : $attributes[3]\n";
	$description .= "Modified : $attributes[4]\n";
	$description .= "Accessed : $attributes[5]\n";
	$description .= "NumRecs  : $attributes[6]\n";
	$description .= "Sysflag  : $attributes[7]\n";
	$description .= "IdxCols  : $attributes[8]\n";
	$description .= "NumCols  : $attributes[9]\n";
	$count = fetch_table_columns($describe_table_tablename,\@columns,\@column_names);
	if ( $count > 0 ) {
		$description .= "\n$count columns\n";
		for ( $colnum = 0 ; $colnum < $count ; ++$colnum ) {
			$description .= sprintf "%-12s %s",$columns[$colnum][3],$columns[$colnum][1];
			if ( $columns[$colnum][4] > 0 ) {  # Length > 0 ?
				$description .= "($columns[$colnum][4]";
				if ( $columns[$colnum][5] > 0 ) { # Maxwidth > 0 ?
					$description .= ":$columns[$colnum][5]";
				} # IF
				$description .= ")";
			} # IF a length
			if ( $columns[$colnum][6] ) { # An index column ?
				$description .= " INDEXED";
			} # IF
			$description .= "\n";
		} # FOR loop over each column
	} # IF columns are defined
	else {
		$description .= "No defined columns\n";
	} # ELSE
	@lines = split(/\n/,$description);
	$num_lines = scalar @lines;
	for ( $count = 0 ; $count < $num_lines ; ++$count ) {
		$describe_table_textbox->insert("end","$lines[$count]\n");
	} # FOR
	$describe_table_textbox->pack();
	$description_flag = 1;

	return;
} # end of show_table_description

######################################################################
#
# Function  : close_description
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

sub close_description
{
	$describe_win2->grabRelease;
	$describe_win2->destroy;

	return;
} # end of close_description

######################################################################
#
# Function  : print_description
#
# Purpose   : Process a click of the "Print" button on the Describe
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

sub print_description
{
	my ( $description );

	if ( $description_flag ) {
		$description = $describe_table_textbox->get('1.0','end');
		print_data($description);
	} # IF
	else {
		$describe_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "There is no table description." ,
						-title => 'Table Description' );
	} # ELSE

	return;
} # end of print_description

######################################################################
#
# Function  : display_describe_help_text
#
# Purpose   : Display help text for the "Describe Table" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_describe_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_describe_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command displays detailed information on a single database table.

Select a single table from the displayed list of existing tables and
the description for thattable will be displayed.
ENDHELP

	$dialog = $describe_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Describe Table Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_describe_help_text

######################################################################
#
# Function  : event_describe_table_selection
#
# Purpose   : Respond to a table selection event.
#
# Inputs    : Listbox of tables.
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = event_describe_table_selection();
#
# Notes     : (none)
#
######################################################################

sub event_describe_table_selection
{
	my ( @selected );

	@selected = $describe_table_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$describe_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$describe_table_tablename = $systables_entries[$selected[0]][$systables_tablename_column];
	show_table_description();

	return 1;
} # end of event_describe_table_selection

1;
