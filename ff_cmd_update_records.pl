#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_update_records.pl
#
# Author    : Barry Kimelman
#
# Created   : December 17, 2003
#
# Purpose   : Perl/Tk script to implement the "Update Records" command.
#
######################################################################

use strict;
require Tk;
use Tk;

use My::Myglobalvars qw($mainwin @session_command_history $label_font $label_background_color
			$listbox_background_color $listbox_font @systables_entries $systables_tablename_column
			$button_background_color $button_font $errmsg $text_font $dialog_font $syscols_datatype_column
			%validation_functions $rdbms_dirname $systables_filename_column $syscols_datatype_column
			%system_tables);

my $update_records_listbox;
my $update_record_win2;
my $update_records_tablename;
my $update_records_colname;
my @table_attributes;
my $update_records_criteria_textbox;
my $close_button;
my $help_button;
my $next_button;
my $update_label1;
my $update_label2;
my $mainframe;
my $leftframe_1;
my $leftframe_2;
my $leftframe_3;
my $leftframe_4;
my $leftframe_5;
my $leftframe_6;
my $leftframe_7;
my @columns_info;
my @ordered_column_names;
my $num_columns;
my $num_rows;
my $tables_index;
my @update_criteria_info;
my $columns_index;
my $new_column_value_textbox;

######################################################################
#
# Function  : generate_update_records_screen
#
# Purpose   : Generate the table selection screen for the
#             "Update Records" command.
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

sub generate_update_records_screen
{
	my ( $count );
	my $color = 'orange';

	$update_record_win2 = $mainwin->Toplevel;
	$update_record_win2->grab;
	push @session_command_history,"update records";

	$update_record_win2->minsize( qw(20 7));
	$update_record_win2->title("Update Records");
	$update_record_win2->configure(-background=>$color);

	$mainframe = $update_record_win2->Frame(-background => $color,)->pack(-side => 'top',
						-fill => 'x');
	$leftframe_1 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_2 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_3 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_4 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_5 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_6 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	$leftframe_7 = $mainframe->Frame(-background => $color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);

	$update_label1 = $leftframe_1->Label(-text => 'Select a table',
						-background => 'cyan',-font => $label_font,
						-background => $label_background_color
						)->pack(-side => 'top');

	$update_records_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();

	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$update_records_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}
	$update_records_listbox->bind('<1>' => \&event_update_table_selection);

	$close_button = $leftframe_7->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_update_records,
			-font => $button_font)->pack(-side => 'left');

	$help_button = $leftframe_7->Button(-text => 'Help',
			-command => \&display_update_records_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	$columns_index = -1;
	$tables_index = -1;

	return 1;
} # end of generate_update_records_screen

######################################################################
#
# Function  : close_update_records
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

sub close_update_records
{
	$update_record_win2->grabRelease;
	$update_record_win2->destroy;
	return;
} # end of close_update_records

######################################################################
#
# Function  : generate_columns_screen
#
# Purpose   : Process a click of the "Next" button on the "Update Records"
#             screen.
#
# Inputs    : (none)
#
# Output    : Columns selection screen.
#
# Returns   : (nothing)
#
# Example   :
#
# Notes     : (none)
#
######################################################################

sub generate_columns_screen
{
	my ( @selected );

	unless ( fetch_table_info($update_records_tablename,\@table_attributes) ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Table \"$update_records_tablename\" ".
										"does not exist : $errmsg",
						-title => 'Table Problem' );
		$update_record_win2->grabRelease;
		$update_record_win2->destroy;
		return;
	} # UNLESS

	$num_columns = fetch_table_columns($update_records_tablename,\@columns_info,
							\@ordered_column_names);
	if ( $num_columns < 1 ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't get column info for table " .
									"\"$update_records_tablename\" : " .
									$errmsg,
						-title => 'Table Problem' );
		$update_record_win2->grabRelease;
		$update_record_win2->destroy;
		return;
	} # IF

	$update_label2 = $leftframe_3->Label(-text => 'Enter Update criteria',
						-background => 'cyan',-font => $label_font,
						-background => $label_background_color
						)->pack(-side => 'top');
	$update_records_criteria_textbox = $leftframe_4->Text();
	$update_records_criteria_textbox->configure(-height      => 1,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 40,
		 -wrap        => 'word',
		 -font        => $text_font );
	$update_records_criteria_textbox->pack(-side => 'top');

	$update_records_listbox->delete('0','end');
	$update_records_listbox->insert('end', @ordered_column_names);
	$update_label1->configure(-text => "Select a column");
	$update_records_listbox->bind('<1>' => \&event_update_column_selection);

	my $new_column_value_label = $leftframe_5->Label(-text => 'Enter new value for column',
						-background => 'cyan',-font => $label_font,
						-background => $label_background_color
						)->pack(-side => 'top');
	$new_column_value_textbox = $leftframe_6->Text();
	$new_column_value_textbox->configure(-height      => 1,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 40,
		 -wrap        => 'word',
		 -font        => $text_font );
	$new_column_value_textbox->pack(-side => 'top');

	$next_button = $leftframe_7->Button(-text => 'Update',
			-command => \&perform_update,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return;
} # end of generate_columns_screen

######################################################################
#
# Function  : display_update_records_help_text
#
# Purpose   : Display help text for the "Update Records" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_update_records_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_update_records_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command updates records in an existing database table.

First you must select an entry from the displayed list of existing
database tables.

Once you have selected a table then you should click on the
"Next" button. This will take you to a screen where you can
select the column to be updated and enter the optional record
selection criteria. From this screen you can click the "Update"
button to perform the requested update operation.
ENDHELP

	$dialog = $update_record_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Update Records Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_update_records_help_text

######################################################################
#
# Function  : perform_update
#
# Purpose   : Perform the requested update.
#
# Inputs    : Screen fields.
#
# Output    : Status message.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = perform_update();
#
# Notes     : (none)
#
######################################################################

sub perform_update
{
	my ( $criteria , $status , @file_data , $table_filepath , $count );
	my ( $new_column_value , $col1 , $data_type , $func , $num_updated );
	my ( $criteria_data_type , $match , $old_column_value );
	my ( $criteria_column_index , $criteria_column_value );

	if ( $columns_index < 0 ) { # Was anything selected ?
		$update_record_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No column was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$new_column_value = $new_column_value_textbox->get('1.0','end');
	chomp $new_column_value;
	if ( 1 > length $new_column_value ) { # Was anything selected ?
		$update_record_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No new column value was entered",
						-title => 'Missing Column Value' );
		return;
	} # IF

	$num_columns = fetch_table_columns($update_records_tablename,\@columns_info,
							\@ordered_column_names);
	if ( $num_columns < 1 ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't load column info : $errmsg",
						-title => 'I/O Error' );
		return 0;
	} # IF
	$data_type = $columns_info[$columns_index][$syscols_datatype_column];

	$func = $validation_functions{$data_type};
	$status = &$func($new_column_value);
	unless ( $status ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Column \"$update_records_colname\" : $errmsg",
						-title => 'Data Validation Error' );
		return 0;
	} # UNLESS


	$criteria = $update_records_criteria_textbox->get('1.0','end');
	chomp $criteria;
	if ( 0 < length $criteria ) {
		$status = parse_criteria($criteria,\@columns_info,\@update_criteria_info);
		unless ( $status ) {
			$update_record_win2->messageBox(-type => 'OK', -icon => "error",
							-message => "$errmsg",
							-title => 'Criteria Error' );
			return 0;
		} # UNLESS
	} # IF
	$criteria_column_index = $update_criteria_info[3];

	$table_filepath = File::Spec->catfile($rdbms_dirname,
				$systables_entries[$tables_index][$systables_filename_column]);
	$status = load_file_into_array(\@file_data,$table_filepath);
	unless ( $status ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't load table data : $errmsg",
						-title => 'I/O Error' );
		return 0;
	} # UNLESS
	$num_rows = scalar @file_data;
	$num_updated = 0;
	$criteria_data_type = $columns_info[$criteria_column_index][$syscols_datatype_column];

	for ( $count = 0 ; $count < $num_rows ; ++$count ) {
		$old_column_value = $file_data[$count][$columns_index];
		$criteria_column_value = $file_data[$count][$criteria_column_index];
		$match = match_column_value($criteria_column_value,
							$update_criteria_info[1],
							$update_criteria_info[2],
							$criteria_data_type);
		if ( $match ) {
			$num_updated += 1;
			$col1 = $file_data[$count][0];
			$file_data[$count][$columns_index] = $new_column_value;
		} # IF
	} # FOR

	$update_record_win2->messageBox(-type => 'OK', -icon => 'info',
						-message => "$num_updated row(s) matched criteria",
						-title => 'Column Selection' );

	if ( $num_updated > 0 ) {
		$status = save_array_to_file(\@file_data,$table_filepath,$num_columns);
		unless ( $status ) {
			$update_record_win2->messageBox(-type => 'OK', -icon => "error",
							-message => "Update failed : $errmsg",
							-title => 'I/O Error' );
		} # UNLESS
	} # IF

	return 1;
} # end of perform_update

######################################################################
#
# Function  : event_update_table_selection
#
# Purpose   : Respond to a table selection event.
#
# Inputs    : Listbox of tables.
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = event_update_table_selection();
#
# Notes     : (none)
#
######################################################################

sub event_update_table_selection
{
	my ( @selected , $tablename );

	@selected = $update_records_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$update_record_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return 0;
	} # IF

	$tables_index = $selected[0];
	$tablename = $systables_entries[$tables_index][$systables_tablename_column];
	if ( exists $system_tables{$tablename} ) {
		$update_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Direct update of a system table is not allowed",
						-title => 'Invalid Table Selection' );
		return 0;
	} # IF
	$update_records_tablename = $tablename;
	generate_columns_screen();

	return 1;
} # end of event_update_table_selection

######################################################################
#
# Function  : event_update_column_selection
#
# Purpose   : Respond to a table selection event.
#
# Inputs    : Listbox of tables.
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = event_update_column_selection();
#
# Notes     : (none)
#
######################################################################

sub event_update_column_selection
{
	my ( @selected , $tablename );

	@selected = $update_records_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$update_record_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "event_update_column_selection() : No column was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$columns_index = $selected[0];
	$update_records_colname = $ordered_column_names[$columns_index];

	return 1;
} # end of event_update_column_selection

1;
