#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_insert_record.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "Insert Record" command.
#
######################################################################

use strict;
require Tk;
use Tk;

my $input_screen1;
my $insert_record_flag = 0;
my %insert_record_column_data;
my @insert_record_column_info;
my $insert_record_tablename;
my $label_input_record;
my $record_input_table_listbox;
my $record_input_table_textbox;

use My::Myglobalvars qw(%validation_functions $mainwin $frame_background_color @session_command_history
				$label_font $label_background_color $listbox_background_color $listbox_font
				@systables_entries $systables_tablename_column $text_font $button_background_color
				$button_font $syscols_colname_column $errmsg $syscols_datatype_column
				$dialog_font %system_tables);

######################################################################
#
# Function  : generate_insert_record_screen
#
# Purpose   : Generate the table selection screen for the
#             "Insert Record" command.
#
# Inputs    : (none)
#
# Output    : Screen for "Insert Record" command.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub generate_insert_record_screen
{
	my ( $count );

	$input_screen1 = $mainwin->Toplevel;

	$insert_record_flag = 0;
	$input_screen1->grab;
	push @session_command_history,"insert record";

###	$input_screen1->minsize( qw(30 10));
	$input_screen1->title("Insert Record");
	$input_screen1->configure(-background=>$window_background_color);

	my $mainframe = $input_screen1->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 5);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 5);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 5);
	my $leftframe_4 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 5);
	my $leftframe_5 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 5);
	my $label1 = $leftframe_1->Label(-text => 'Currently defined tables',
							-font => $label_font,
							-background => $label_background_color
							)->pack();

	$record_input_table_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();
	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$record_input_table_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}
	$record_input_table_listbox->bind('<1>' => \&event_insert_table_selection);

	$label_input_record = $leftframe_3->Label(
				-text => '** No record layout requested **',
				-font => $label_font,
				-background => $label_background_color
				)->pack();
	$record_input_table_textbox = $leftframe_4->Scrolled("Text",-wrap => 'none',
							-font => $text_font)->pack(-side => 'bottom',
						-fill => 'both', -expand => 1);
	$record_input_table_textbox->configure(-height      => 20,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 50);

	my $button2 = $leftframe_5->Button(-text => 'Insert',
			-background => $button_background_color,
			-command => \&insert_record,
			-font => $button_font)->pack(-side => 'left');

	my $button3 = $leftframe_5->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_input_table_select,
			-font => $button_font)->pack(-side => 'left');

	my $button4 = $leftframe_5->Button(-text => 'Help',
			-command => \&display_insert_record_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return;
} # end of generate_insert_record_screen

######################################################################
#
# Function  : close_input_table_select
#
# Purpose   : Process a click of the "Close Window" button on the
#             table selection screen for the "Perform Input" command.
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

sub close_input_table_select
{
	$input_screen1->grabRelease;
	$input_screen1->destroy;

	return;
} # end of close_input_table_select

######################################################################
#
# Function  : generate_data_entry_screen
#
# Purpose   : Process a click of the "Data Entry" button on the
#             table selection screen for the "Perform Input" command.
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

sub generate_data_entry_screen
{
	my ( $count );
	my ( $num_cols , $colname , @column_names );

	$record_input_table_textbox->delete('1.0','end');

	$label_input_record->configure(-text => "Record layout for table : $insert_record_tablename");

	$count = fetch_table_columns($insert_record_tablename,\@insert_record_column_info,
									\@column_names);
	if ( $count <= 0 ) {
		$input_screen1->messageBox(-type => 'OK', -icon => "error",
						-message => "Table $insert_record_tablename has no columns",
						-title => 'Corrupted Data' );
		return 0;
	} # IF
	$num_cols = @insert_record_column_info;
	%insert_record_column_data = ();
	for ( $count = 0 ; $count < $num_cols ; ++$count ) {
		$colname = $insert_record_column_info[$count][$syscols_colname_column];
		my $w = $record_input_table_textbox->Label(-text => "$colname:",
						-relief => 'groove', -width => 20,
						-font => $label_font );
		$record_input_table_textbox->windowCreate('end', -window => $w);
		$insert_record_column_data{$colname} = "";
		$w = $record_input_table_textbox->Entry(-width => 20,
						-textvariable => \$insert_record_column_data{$colname},
						-font => $text_font );
		$record_input_table_textbox->windowCreate('end', -window => $w);
		$record_input_table_textbox->insert('end', "\n");
	} # FOR
	$insert_record_flag = 1;

	return;
} # end of generate_data_entry_screen

######################################################################
#
# Function  : insert_record
#
# Purpose   : Process a click of the "Close Window" button on the
#             table selection screen for the "Perform Input" command.
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

sub insert_record
{
	my ( $status , $num_columns , $count , $colname , @row_data );

	unless ( $insert_record_flag ) {
		$input_screen1->messageBox(-type => 'OK', -icon => "error",
						-message => "No record layout",
						-title => 'Missing Record Data' );
		return 0;
	} # IF

	$status = validate_input_fields(\%insert_record_column_data,
										\@insert_record_column_info);
	if ( $status ) {
		$num_columns = @insert_record_column_info;
		$input_screen1->messageBox(-type => 'OK', -icon => "info",
						-message => "The record data is valid [$num_columns columns]",
						-title => 'Validation Result' );
		@row_data = ();
		for ( $count = 0 ; $count < $num_columns ; ++$count ) {
			$colname = $insert_record_column_info[$count][$syscols_colname_column];
			push @row_data,$insert_record_column_data{$colname};
		} # FOR
		$status = add_row_to_table($insert_record_tablename , \@row_data);
		unless ( $status ) {
			$input_screen1->messageBox(-type => 'OK', -icon => "error",
							-message => "Could not insert new record : $errmsg",
							-title => 'Insert Failed' );
		} # UNLESS
		$input_screen1->grabRelease;
		$input_screen1->destroy;
	} # IF
	else {
		$input_screen1->messageBox(-type => 'OK', -icon => "error",
						-message => "Invalid data detected : $errmsg",
						-title => 'Validation Result' );
	} # ELSE

	return;
} # end of insert_record

######################################################################
#
# Function  : validate_input_fields
#
# Purpose   : Validate the data entered by the user.
#
# Inputs    : $_[0] - ref to hash containing data entered by the user
#             $_[1] - ref to array of hashes containing column info
#
# Output    : (none)
#
# Returns   : IF all data is valid Then 1 Else 0
#
# Example   : $status = validate_input_fields(\%col_data,\@col_info);
#
# Notes     : (none)
#
######################################################################

sub validate_input_fields
{
	my ( $ref_col_data , $ref_col_info ) = @_;
	my ( $count , $colname , $num_columns , $status , $func , $data_type );
	my ( $data , $reason );

	$num_columns = scalar @$ref_col_info;
	$status = 1;
	for ( $count = 0 ; $count < $num_columns && $status ; ++$count ) {
		$colname = $$ref_col_info[$count][$syscols_colname_column];
		if ( exists $$ref_col_data{$colname} ) {
			$data_type = $$ref_col_info[$count][$syscols_datatype_column];
			$func = $validation_functions{$data_type};
			$data = $$ref_col_data{$colname};
			$status = &$func($data);
			unless ( $status ) {
				$reason = $errmsg;
				$errmsg = "Column \"$colname\" : $reason";
			} # UNLESS
		} # IF
		else {
			$errmsg = "Column \"$colname\" is unknown";
			$status = 0;
		} # ELSE
	} # FOR

	return $status;
} # end of validate_input_fields

######################################################################
#
# Function  : display_insert_record_help_text
#
# Purpose   : Display help text for the "Insert Record" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_insert_record_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_insert_record_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command inserts a record into one of the existing database tables.

First you select a table from the displayed list of existing tables and
then you click on "Generate data Entry screen". On the data entry form
you enter all the field values and then click on the "Insert Record" button.

All the data will be validated before the record is inserted into the
selected database table.
ENDHELP

	$dialog = $input_screen1->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Insert Record Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_insert_record_help_text

######################################################################
#
# Function  : event_insert_table_selection
#
# Purpose   : Respond to a table selection event.
#
# Inputs    : Listbox of tables.
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = event_insert_table_selection();
#
# Notes     : (none)
#
######################################################################

sub event_insert_table_selection
{
	my ( @selected , $tablename );

	@selected = $record_input_table_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$input_screen1->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$tablename = $systables_entries[$selected[0]][$systables_tablename_column];
	if ( exists $system_tables{$tablename} ) {
		$input_screen1->messageBox(-type => 'OK', -icon => "error",
						-message => "Direct insertion into a system table is not allowed",
						-title => 'Invalid Table Selection' );
		return 0;
	} # IF
	$insert_record_tablename = $tablename;
	generate_data_entry_screen();

	return 1;
} # end of event_insert_table_selection

1;
