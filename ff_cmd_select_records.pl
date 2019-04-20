#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_select_records.pl
#
# Author    : Barry Kimelman
#
# Created   : December 14, 2003
#
# Purpose   : Perl/Tk script to implement the "Select" command.
#
######################################################################

use strict;
require Tk;
use Tk;

use My::Myglobalvars qw($mainwin @session_command_history $window_background_color $frame_background_color
			$label_background_color $label_font $listbox_background_color $listbox_font @systables_entries
			$systables_tablename_column $text_font $button_background_color $button_font $field_separator
			$errmsg %valid_comparison_operators %data_quotes $dialog_font @systables_entries
			$systables_tablename_column);

my $query_result_textbox;
my $query_data_flag;
my $select_win2;
my $select_table_listbox;
my $select_criteria_textbox;
my $selected_table;
my $table_label;
my $cols_label;
my $criteria_label;
my @table_attributes;
my @columns_info;
my @ordered_column_names;
my $num_columns;
my $table_selected_flag;
my $num_selected_columns;
my $selected_columns;
my $selected_columns_label;

######################################################################
#
# Function  : generate_select_records_window
#
# Purpose   : Generate the data entry window for a SELECT operation.
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

sub generate_select_records_window
{
	my ( $count );

	$select_win2 = $mainwin->Toplevel;
	$select_win2->grab;
	$query_data_flag = 0;
	$table_selected_flag = 0;
	$num_selected_columns = 0;
	push @session_command_history,"select records";

###	$select_win2->minsize(qw(60 25));
	$select_win2->title("Select Records");
	$select_win2->configure(-background=>$window_background_color);

	my $mainframe = $select_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_4 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_5 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);

	$table_label = $leftframe_1->Label(-text => 'select a table',
						-background => $label_background_color,
						-font => $label_font)->pack();

	$select_table_listbox = $leftframe_1->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => 20, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-selectmode => 'browse',
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();

	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$select_table_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}
	$select_table_listbox->bind('<1>' => \&event_select_table_selection);

	$cols_label = $leftframe_2->Label(-text => 'Selected columns',
						-background => $label_background_color,
						-font => $label_font)->pack();
	$selected_columns_label = $leftframe_2->Label(-text => '[none]',
						-background => $label_background_color,
						-font => $label_font)->pack();

	$criteria_label = $leftframe_3->Label(-text => 'Enter selection criteria',
						-background => $label_background_color,
						-font => $label_font)->pack();
	$select_criteria_textbox = $leftframe_3->Text();
	$select_criteria_textbox->configure(-height      => 1,
		 -background  => 'white',
		 -foreground  => 'black',
		 -width       => 20,
		 -wrap        => 'word',
		 -font        => $text_font );
	$select_criteria_textbox->pack();


	my $exit_button = $leftframe_4->Button(-text => "Close",  -width => 10,
					-background => $button_background_color,
					-command => \&exit_select_records_window,
					-font => $button_font )->pack(-side => 'left');

	my $execute_button = $leftframe_4->Button(-text => "Execute",
					-background => $button_background_color,
					-width => 10,-command => \&execute_select,
					-font => $button_font)->pack(-side => 'left');

	my $print_button = $leftframe_4->Button(-text => "Print",
					-background => $button_background_color,
					-width => 10,-command => \&print_query_data,
					-font => $button_font)->pack(-side => 'left');

	my $help_button = $leftframe_4->Button(-text => "Help",
					-background => $button_background_color,
					-width => 10,-command => \&display_select_help_text,
					-font => $button_font)->pack(-side => 'left');


	$query_result_textbox = $leftframe_5->Scrolled("Text",
							-wrap => 'none', -height => 15,
							-font => $text_font)->pack(-side => 'bottom',
						-fill => 'both', -expand => 1);
###	$query_result_textbox->configure(-wrap => 'word', -wrapLength => 0);

	return;
} # end of generate_select_records_window

######################################################################
#
# Function  : exit_select_records_window
#
# Purpose   : Process a click of the "Exit" button on the SELECT
#             window.
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

sub exit_select_records_window
{
	$select_win2->grabRelease;
	$select_win2->destroy;

	return;
} # end of exit_select_records_window

######################################################################
#
# Function  : execute_select
#
# Purpose   : Process a click of the "Execute" button on the SELECT
#             window.
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

sub execute_select
{
	my ( $columns , $status , @result , $num_rows , $message );
	my ( $DIALOG2 , $line1 , $line2 , $temp , $colname , $length , @columns );
	my ( @column_maxlen , @fields , $num_columns , $count , $row );
	my ( $field , $criteria );

	unless ( $table_selected_flag ) {
		$select_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # UNLESS

	if ( 1 > $num_selected_columns ) {
		$selected_columns = "*";
	} # IF
	$columns = $selected_columns;
	$criteria = $select_criteria_textbox->get('1.0','end');
	chomp $criteria;

	$status = &run_query($selected_table,$columns,$criteria,\@result,\@columns,\@column_maxlen);
	if ( $status ) {
		$query_data_flag = 1;
		$num_rows = @result;
		$select_win2->messageBox(-type => 'OK',
						-message => "Query Succeeded , $num_rows rows",
						-title => 'Query Result' );
		$num_columns = @columns;
		$line1 = join(" , ",@column_maxlen);
		$line1 = "";
		for ( $count = 0 ; $count < $num_columns ; ++$count ) {
			$length = $column_maxlen[$count];
			$line1 .= sprintf "%-${length}.${length}s",$columns[$count];
			$line1 .= " ";
		} # FOREACH
		chop $line1;
		$line1 .= "\n";
		$line2 = "";
		for ( $count = 0 ; $count < $num_columns ; ++$count ) {
			$temp = "_" x $column_maxlen[$count];
			$line2 .= $temp . " ";
		} # FOREACH
		chop $line2;
		$line2 .= "\n";

		$query_result_textbox->delete('1.0','end');
		$query_result_textbox->insert("end",$line1);
		$query_result_textbox->insert("end",$line2);
		foreach $row ( @result ) {
			$temp = "";
			@fields = split(/${field_separator}/,$row);
			for ( $count = 0 ; $count < $num_columns ; ++$count ) {
				$length = $column_maxlen[$count];
				$temp .= sprintf "%-${length}.${length}s",$fields[$count];
				$temp .= " ";
			} # FOR
			chop $temp;
			$temp .= "\n";
			$query_result_textbox->insert("end",$temp);
		} # FOREACH

	} # IF query succeeded
	else {
		$query_data_flag = 0;
		$select_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "Query Failed : $errmsg" ,
						-title => 'Query Result' );
	} # ELSE

	return $status;
} # end of execute_select

######################################################################
#
# Function  : display_select_help_text
#
# Purpose   : Display help text for the "Create Table" command.
#
# Inputs    : (none)
#
# Output    : Various screens.
#
# Returns   : If success Then 1 Else 0
#
# Example   : &display_select_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_select_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command retrieves records from the specified database table.

For the column names, you can either enter "*" (for all the columns)
or a comma-separated list of column names.

For the tablename you must select an entry from the list of defined tables.

The selection criteria is optional. Without this option all the
records for the table will be retrieved. The format of the
selection criteria is as follows :

        column_name comparison_operator  comparison_value
ENDHELP
	$message .= "\n\nThe valid comnparison operators are : " .
					join(", ",keys %valid_comparison_operators) . ".";
	$message .= "\n\nFor string data values the allowable quote characters are : ";
	foreach $quote ( keys %data_quotes ) {
		$message .= " $quote" . $data_quotes{$quote};
	} # FOREACH

	$message .= "\n\nFor the \"LIKE\" and \"UNLIKE\" operators the expected";
	$message .= " comparison_value must be a valid Perl regular expression";

	$dialog = $select_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Select Records Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_select_help_text

######################################################################
#
# Function  : event_select_table_selection
#
# Purpose   : Respond to a table selection event.
#
# Inputs    : Listbox of tables.
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = &event_select_table_selection();
#
# Notes     : (none)
#
######################################################################

sub event_select_table_selection
{
	my ( @selected , $tablename );

	$num_selected_columns = 0;
	@selected = $select_table_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$select_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$selected_table = $systables_entries[$selected[0]][$systables_tablename_column];
	$table_label->configure(-text => 'Select columns');

	$select_table_listbox->delete('0','end');

	unless ( &fetch_table_info($selected_table,\@table_attributes) ) {
		$select_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Table \"$selected_table\" ".
										"does not exist : $errmsg",
						-title => 'Table Problem' );
		$select_win2->grabRelease;
		$select_win2->destroy;
		return;
	} # UNLESS

	$num_columns = &fetch_table_columns($selected_table,\@columns_info,
							\@ordered_column_names);
	if ( $num_columns < 1 ) {
		$select_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Can't get column info for table " .
									"\"$selected_table\" : " .
									$errmsg,
						-title => 'Table Problem' );
		$select_win2->grabRelease;
		$select_win2->destroy;
		return;
	} # IF

	$table_selected_flag = 1;
	$select_table_listbox->insert('end', @ordered_column_names);
	$select_table_listbox->bind('<1>' => \&event_select_column_selection);

	return 1;
} # end of event_select_table_selection

######################################################################
#
# Function  : event_select_column_selection
#
# Purpose   : Respond to a column selection event.
#
# Inputs    : (none)
#
# Output    : Various stuff.
#
# Returns   : If success Then 1 Else 0
#
# Example   : $status = &event_select_column_selection();
#
# Notes     : (none)
#
######################################################################

sub event_select_column_selection
{
	my ( @selected , $colname );

	@selected = $select_table_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$select_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No column was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$colname = $ordered_column_names[$selected[0]];
	$num_selected_columns += 1;
	if ( $num_selected_columns == 1 ) {
		$selected_columns = $colname;
	} # IF
	else {
		$selected_columns .= ",$colname";
	} # ELSE
	$selected_columns_label->configure(-text => $selected_columns);

	return;
} # end of event_select_column_selection
1;
