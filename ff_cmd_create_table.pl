#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_create_table.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "Create Table" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw($mainwin $window_background_color @session_command_history
			$frame_background_color $label_font $label_background_color $text_font
			$button_background_color $button_font $errmsg %valid_data_types
			$dialog_font);

my $create_win2;
my $create_table_textbox;

######################################################################
#
# Function  : generate_create_table_screen
#
# Purpose   : Generate the "Create Table" command screen.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub generate_create_table_screen
{
	my ( $count );

	$create_win2 = $mainwin->Toplevel;
###	$create_win2->grab;

###	$create_win2->minsize( qw(30 10));
	$create_win2->title("Create A Table");
	$create_win2->configure(-background=>$window_background_color);
	push @session_command_history,"create table";

	my $mainframe = $create_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $label1 = $leftframe_1->Label(-font => $label_font,
				-text => "Enter table definition\nand click [Create Table]",
				-background => $label_background_color)->pack();
	$create_table_textbox = $leftframe_2->Scrolled("Text",
						-font => $text_font)->pack(-side => 'bottom',
						-fill => 'both', -expand => 1);
	my $button_width = 15;
	my $button_side = 'left';
	my $button1 = $leftframe_3->Button(-text => "Create Table",  -width => $button_width,
					-background => $button_background_color,
					-command => sub {execute_create_table($create_table_textbox,
					$create_win2)},
					-font => $button_font )->pack(-side => $button_side);

	my $button2 = $leftframe_3->Button(-text => "Close",  -width => $button_width,
					-background => $button_background_color,
					-command => sub {$create_win2->destroy},
					-font => $button_font )->pack(-side => $button_side);

	my $button3 = $leftframe_3->Button(-text => "Help",  -width => $button_width,
					-background => $button_background_color,
					-command => sub {display_create_table_help_text()},
					-font => $button_font )->pack(-side => $button_side);

	return 1;
} # end of generate_create_table_screen

##	$file_mb->command(-label => 'Exit', -activebackground => 'magenta',
##					-command => sub {$create_win2->destroy});

######################################################################
#
# Function  : execute_create_table
#
# Purpose   : Execute the "Create Table" command.
#
# Inputs    : $_[0] - textbox containing table description
#             $_[1] - window descriptor
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = execute_create_table($textbox,$window);
#
# Notes     : (none)
#
######################################################################

sub execute_create_table
{
	my ( $textbox , $window ) = @_;
	my ( $status , $description , @lines , $num_lines , $tablename );
	my ( $line , @fields , $num_fields , $bad_data , @colnames );
	my ( @data_types , %colnames , $duplicates , $details , $colname );

	$status = 1;
	$description = $textbox->get('1.0','end');
	@lines = split(/\n/,$description);
	$num_lines = scalar @lines;
	if ( 2 > $num_lines ) {
		$window->messageBox(-type => 'OK',
						-message => "You omitted the required text",
						-title => 'Your Selection' );
		return 0;
	} # IF

	$tablename = shift @lines;
	$bad_data = 0;
	$duplicates = 0;
	@colnames = ();
	%colnames = ();
	@data_types = ();
	foreach $line ( @lines ) {
		$line =~ s/^\s+//g; # remove leading whitespace
		$line =~ s/\s+$//g; # remove trailing whitespace
		@fields = split(/\s+/,$line);
		$num_fields = scalar @fields;
		if ( $num_fields < 2 ) {
			$bad_data = 1;
			next;
		} # IF
		$colname = lc $fields[0];
		if ( exists $colnames{$colname} ) {
			$duplicates = 1;
			last;
		} # IF
		$colnames{$colname} = 1;
		push @colnames,$fields[0];
		push @data_types,$fields[1];
	} # FOREACH
	if ( $bad_data || $duplicates ) {
		$details = $duplicates ? "duplicate column names" :
									"an invalid table specification";
		$window->messageBox(-type => 'OK',, -icon => 'error',
						-message => "You entered $details",
						-title => 'User Input Error' );
	} # IF
	else {
		$status = build_table($tablename,\@colnames,\@data_types);
		if ($status ) {
			$window->messageBox(-type => 'OK',
						-message => "Table $tablename successfully created",
						-title => 'Table Created' );
			$create_win2->destroy;
		} # UNLESS
		else {
			$window->messageBox(-type => 'OK',
						-message => "$errmsg",
						-title => 'Processing Error' );
		} # ELSE
	} # ELSE

	return $status;
} # end of execute_create_table

######################################################################
#
# Function  : display_create_table_help_text
#
# Purpose   : Display help text for the "Create Table" command.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : display_create_table_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_create_table_help_text
{
	my ( $dialog , $message );

	$message = <<ENDHELP;
This command create a single table

You enter the table information in the provided textbox.
On the 1st line you enter the name of the table. On the remaining
lines you enter the column definitions (1 per line). A column definition
consists of the column name followed by the column's data type.

A column name must start with an alphabetic character or an underscore
and the remaining characters can be alphanumeric or an underscore.
ENDHELP
	$message .= "\n\nThe valid data types are : " .
					join(", ",keys %valid_data_types) . ".";
	$dialog = $create_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Create Table Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_create_table_help_text

1;
