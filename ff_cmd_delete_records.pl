#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_delete_records.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "Delete Records" command.
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
			$button_font %system_tables $systables_filename_column $errmsg
			$syscols_datatype_column $dialog_font);

my $delete_records_tablename;
my $delete_records_listbox;
my $delete_record_win2;
my $delete_record_tablename;
my @table_attributes;
my $delete_records_criteria_textbox;

######################################################################
#
# Function  : generate_delete_records_screen
#
# Purpose   : Generate the table selection screen for the
#             "Delete Records" command.
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

sub generate_delete_records_screen
{
	my ( $count );

	$delete_record_win2 = $mainwin->Toplevel;
	$delete_record_win2->grab;
	push @session_command_history,"delete records";

###	$delete_record_win2->minsize( qw(30 10));
	$delete_record_win2->title("Delete Records");
	$delete_record_win2->configure(-background=>$window_background_color);

	my $mainframe = $delete_record_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 15);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 15);
	my $leftframe_4 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 15);
	my $leftframe_5 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 15);

	my $delete_label1 = $leftframe_1->Label(
						-text => "Select table to be processed",
						-background => $label_background_color,
						-font => $label_font)->pack(-side => 'top');

	$delete_records_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();

	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$delete_records_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}

	my $delete_label2 = $leftframe_3->Label(-text => 'Enter Delete criteria',
						-background => $label_background_color,
						-font => $label_font)->pack(-side => 'top');
	$delete_records_criteria_textbox = $leftframe_4->Text();
	$delete_records_criteria_textbox->configure(-height      => 1,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 40,
		 -wrap        => 'word',
		 -font        => $text_font );
	$delete_records_criteria_textbox->pack(-side => 'top');

	my $button1 = $leftframe_5->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_delete_records, -font => $button_font
			)->pack(-side => 'left');

	my $button2 = $leftframe_5->Button(-text => 'Delete',
			-background => $button_background_color,
			-command => \&perform_delete_records, -font => $button_font
			)->pack(-side => 'left');

	my $button3 = $leftframe_5->Button(-text => 'Help',
			-command => \&display_delete_records_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return 1;
} # end of generate_delete_records_screen

######################################################################
#
# Function  : close_delete_records
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

sub close_delete_records
{
	$delete_record_win2->grabRelease;
	$delete_record_win2->destroy;
	return;
} # end of close_delete_records

######################################################################
#
# Function  : perform_delete_records
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

sub perform_delete_records
{
	my ( @selected , $answer , $table_filepath , $tables_index , $num_rows );
	my ( @file_data , $status , $count , $num_cols , %colhash , $criteria );
	my ( %col_positions , @column_info , @ordered_column_names );
	my ( $criteria_column_index , @delete_criteria_info , $num_deleted );
	my ( $col_data , $data_type , @new_file_data , $num_saved );

	@selected = $delete_records_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$delete_record_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$tables_index = $selected[0];
	$delete_record_tablename = $systables_entries[$tables_index][$systables_tablename_column];
	if ( exists $system_tables{$delete_record_tablename} ) {
		$delete_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Direct deletion from a system table is not allowed",
						-title => 'Invalid Table Selection' );
		return 0;
	} # IF

	unless ( fetch_table_info($delete_record_tablename,\@table_attributes) ) {
		$delete_record_win2->messageBox(-type => 'OK',
						-message => "Table \"$delete_record_tablename\" does not exist",
						-title => 'Your Selection' );
		$delete_record_win2->grabRelease;
		$delete_record_win2->destroy;
		return;
	} # UNLESS

	$criteria = $delete_records_criteria_textbox->get('1.0','end');
	chomp $criteria;
	$table_filepath = File::Spec->catfile($rdbms_dirname ,
				$systables_entries[$tables_index][$systables_filename_column]);
	if ( 1 > length $criteria ) {
		$answer = ask_yes_no_question("Are you sure you want to empty the table?",
						$delete_record_win2);
		unless ( $answer ) {
			$delete_record_win2->messageBox(-type => 'OK', -icon => 'info',
							-message => "Delete operation cancelled at user's request",
							-title => 'Operation Cancelled' );
			return 1;
		} # UNLESS
		$status = create_empty_database_table_file($table_filepath);
		unless ( $status ) {
			$delete_record_win2->messageBox(-type => 'OK', -icon => 'error',
							-message => "Delete operation failed : $errmsg",
							-title => 'Operation Failed' );
		} # UNLESS
		$status = set_table_records_counter($tables_index,0);
		unless ( $status ) {
			$delete_record_win2->messageBox(-type => 'OK', -icon => 'error',
							-message => "Error reseting records counter : $errmsg",
							-title => 'Operation Failed' );
		} # UNLESS
		return $status;
	} # IF no delete criteria was specified

	$num_cols = fetch_table_columns($delete_record_tablename,\@column_info,
							\@ordered_column_names);
	if ( $num_cols < 1 ) {
		$delete_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't load column info : $errmsg",
						-title => 'I/O Error' );
		return 0;
	} # IF
	$status = parse_criteria($criteria,\@column_info,\@delete_criteria_info);
	unless ( $status ) {
		$delete_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "$errmsg",
						-title => 'Criteria Error' );
		return 0;
	} # UNLESS

	$status = load_file_into_array(\@file_data,$table_filepath);
	unless ( $status ) {
		$delete_record_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't load table data : $errmsg",
						-title => 'I/O Error' );
		return 0;
	} # UNLESS
	$num_rows = scalar @file_data;
	%colhash = map { $ordered_column_names[$_],$_ } ( 0 .. $num_cols-1 );
	$criteria_column_index = $colhash{$delete_criteria_info[0]};
	$data_type = $column_info[$criteria_column_index][$syscols_datatype_column];

	$num_deleted = 0;
	$num_saved = 0;
	@new_file_data = ();
	for ( $count = 0 ; $count < $num_rows ; ++$count ) {
		$col_data = $file_data[$count][$criteria_column_index];
		if ( match_column_value($col_data,$delete_criteria_info[1],
								$delete_criteria_info[2],$data_type) ) {
			$num_deleted += 1;
		} # IF
		else {
			$num_saved += 1;
			push @new_file_data,$file_data[$count];
		} # ELSE
	} # FOR loop over rows in table
	$delete_record_win2->messageBox(-type => 'OK', -icon => "info",
					-message => "$num_deleted records match criteria",
					-title => 'Delete Results' );

	if ( $num_deleted > 0 ) {
		$status = save_array_to_file(\@new_file_data,$table_filepath,$num_cols);
		unless ( $status ) {
			$delete_record_win2->messageBox(-type => 'OK', -icon => "error",
							-message => "$errmsg",
							-title => 'I/O Error' );
			return 0;
		} # UNLESS
		$status = &set_table_records_counter($tables_index,$num_saved);
		unless ( $status ) {
			$delete_record_win2->messageBox(-type => 'OK', -icon => 'error',
							-message => "Error reseting records counter : $errmsg",
							-title => 'Operation Failed' );
		} # UNLESS
	} # IF

	$delete_record_win2->grabRelease;
	$delete_record_win2->destroy;
	return;
} # end of perform_delete_records

######################################################################
#
# Function  : display_delete_records_help_text
#
# Purpose   : Display help text for the "Delete Records" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_delete_records_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_delete_records_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command deletes records from an existing database table.

You must select an entry from the list of displayed database tables.

The "deletion criteria" field is optional. If Omitted then this command
will delete all the records from the selected table.

See the help text for the "Select Records" command for further details
on the "criteria" field.
ENDHELP

	$dialog = $delete_record_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Delete Records Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_delete_records_help_text

1;
