#!/usr/local/bin/perl -w

######################################################################
#
# File      : ff_cmd_delete_table.pl
#
# Author    : Barry Kimelman
#
# Created   : December 17, 2003
#
# Purpose   : Perl/Tk script to implement the "Delete Table" command.
#
######################################################################

use strict;
require Tk;
use Tk;
use lib qw(.);
use My::Myglobalvars qw($mainwin @session_command_history $window_background_color
			$frame_background_color $label_background_color $label_font
			$listbox_background_color $listbox_font @systables_entries
			$systables_tablename_column $button_background_color $button_font
			%system_tables $systables_table_id_column $rdbms_dirname
			$systables_filename_column %systables_hash $systables_coltotal_column
			$systables_rectotal_column @syscols_entries $syscols_table_id_column
			$systables_file_path $num_systables_columns $errmsg $syscols_file_path
			$num_syscols_columns $backup_extension $dialog_font);

my $delete_table_tablename;
my $delete_table_listbox;
my $delete_table_win2;
my @table_attributes;

######################################################################
#
# Function  : generate_delete_table_screen
#
# Purpose   : Generate the table selection screen for the
#             "Delete Table" command.
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

sub generate_delete_table_screen
{
	my ( $count );

	$delete_table_win2 = $mainwin->Toplevel;
	$delete_table_win2->grab;
	push @session_command_history,"delete table";

	$delete_table_win2->minsize( qw(20 5));
	$delete_table_win2->title("Delete Table");
	$delete_table_win2->configure(-background=>$window_background_color);

	my $mainframe = $delete_table_win2->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-fill => 'x');
	my $leftframe_1 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_2 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);
	my $leftframe_3 = $mainframe->Frame(-background => $frame_background_color,)->pack(-side => 'top',
						-pady => 5, -padx => 8);

	my $delete_label1 = $leftframe_1->Label(
						-text => "Select table and then\nClick [Execute]",
						-background => $label_background_color,
						-font => $label_font)->pack(-side => 'top');

	$delete_table_listbox = $leftframe_2->Scrolled("Listbox",-relief => 'sunken',
						-scrollbars => 'e',
						-width => -1, # Note : -1 ===> Shrink to fit
						-height => 5,
						-setgrid => 1,
						-background => $listbox_background_color,
						-font => $listbox_font)->pack();

	for ( $count = 0 ; $count <= $#systables_entries ; ++$count ) {
		$delete_table_listbox->insert('end', $systables_entries[$count][$systables_tablename_column]);
	}

	my $button1 = $leftframe_3->Button(-text => 'Close',
			-background => $button_background_color,
			-command => \&close_delete_table, -font => $button_font
			)->pack(-side => 'left');

	my $button2 = $leftframe_3->Button(-text => 'Delete',
			-background => $button_background_color,
			-command => \&perform_delete_table, -font => $button_font
			)->pack(-side => 'left');

	my $button3 = $leftframe_3->Button(-text => 'Help',
			-command => \&display_delete_table_help_text,
			-font => $button_font,
			-background => $button_background_color
			)->pack(-side => 'left');

	return 1;
} # end of generate_delete_table_screen

######################################################################
#
# Function  : close_delete_table
#
# Purpose   : Process a clikc of the "Close" button on the "Delete Table"
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

sub close_delete_table
{
	$delete_table_win2->grabRelease;
	$delete_table_win2->destroy;
	return;
} # end of close_delete_table

######################################################################
#
# Function  : perform_delete_table
#
# Purpose   : Process a clikc of the "Execute" button on the "Delete Table"
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

sub perform_delete_table
{
	my ( @selected , $tableid , $filename , $tables_index , $count );
	my ( @systables_entries_temp , @syscols_entries_temp , $limit );
	my ( $status , $numcols );

	@selected = $delete_table_listbox->curselection();
	if ( 1 > @selected ) { # Was anything selected ?
		$delete_table_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "No table was selected",
						-title => 'Missing Selection' );
		return;
	} # IF

	$delete_table_tablename = $systables_entries[$selected[0]][$systables_tablename_column];
	if ( exists $system_tables{$delete_table_tablename} ) {
		$delete_table_win2->messageBox(-type => 'OK', -icon => "error",
						-message => "Direct deletion of a system table is not allowed",
						-title => 'Invalid Table Selection' );
		return 0;
	} # IF

	unless ( fetch_table_info($delete_table_tablename,\@table_attributes) ) {
		$delete_table_win2->messageBox(-type => 'OK',
						-message => "Table \"$delete_table_tablename\" does not exist",
						-title => 'Your Selection' );
		$delete_table_win2->grabRelease;
		$delete_table_win2->destroy;
		return;
	} # UNLESS

	$tableid = $table_attributes[$systables_table_id_column];
	$filename = File::Spec->catfile($rdbms_dirname,$table_attributes[$systables_filename_column]);
	$tables_index = $systables_hash{lc $delete_table_tablename};
	$numcols = $systables_entries[$tables_index][$systables_coltotal_column];

	append_to_activity_logfile("Delete table $delete_table_tablename; tableid = $tableid\n",
				"tables_index = $tables_index\n");
#
# First delete the appropriate row from @systables_entries
#
# The Perl "delete" function actually seems to "undef" an array entry
# rather than physically removing it from the array, so I must do the
# delete operation myself.
#
#	delete $systables_entries[$tables_index];
#
	$limit = $#systables_entries;
	append_to_activity_logfile("last index in SYSTABLES is $limit\n");
	@systables_entries_temp = ();
	for ( $count = 0 ; $count <= $limit ; ++$count ) {
		if ( $count != $tables_index ) {
			append_to_activity_logfile("Keep entry $count\n");
			push @systables_entries_temp,$systables_entries[$count];
		} # IF
	} # FOR
	@systables_entries = @systables_entries_temp;
# Decrement records counter for SYSTABLES by 1
	$systables_entries[0][$systables_rectotal_column] -= 1;

#
# Now delete the appropriate entries from @syscols_entries
# (ie. the columns for the selected table)
#
	$limit = $#syscols_entries;
	append_to_activity_logfile("last index in SYSCOLS is $limit\n");
	@syscols_entries_temp = ();
	for ( $count = 0 ; $count <= $limit ; ++$count ) {
		if ( $tableid != $syscols_entries[$count][$syscols_table_id_column] ) {
			append_to_activity_logfile("Keep entry $count\n");
			push @syscols_entries_temp,$syscols_entries[$count];
		} # IF
	} # FOR
	@syscols_entries = @syscols_entries_temp;
# Decrement records counter for SYSCOLS by $numcols
	$systables_entries[1][$systables_rectotal_column] -= $numcols;

# Now write out the modified contents of SYSTABLES
	$status = save_array_to_file(\@systables_entries,
					$systables_file_path,
					$num_systables_columns);
	unless ( $status ) {
		$delete_table_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "$errmsg",
						-title => 'Deletion Error' );
		return 0;
	} # UNLESS

# Now write out the modified contents of SYSCOLS
	$status = save_array_to_file(\@syscols_entries,
					$syscols_file_path,
					$num_syscols_columns);
	unless ( $status ) {
		$delete_table_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "$errmsg",
						-title => 'Deletion Error' );
		return 0;
	} # UNLESS

# Now delete the physical file that holds the table data
	if ( 1 != unlink $filename ) {
		$delete_table_win2->messageBox(-type => 'OK', -icon => 'error',
						-message => "Can't delete physical file \"$filename\" : $!\n",
						-title => 'Deletion Error' );
	} # IF
# Now delete the backup physical file that holds the table data
	$filename .= $backup_extension;
	unlink $filename;

	$delete_table_win2->grabRelease;
	$delete_table_win2->destroy;

	return 1;
} # end of perform_delete_table

######################################################################
#
# Function  : display_delete_table_help_text
#
# Purpose   : Display help text for the "Delete Table" command.
#
# Inputs    : (none)
#
# Output    : Help text.
#
# Returns   : (nothing)
#
# Example   : display_delete_table_help_text();
#
# Notes     : (none)
#
######################################################################

sub display_delete_table_help_text
{
	my ( $dialog , $message , $quote );

	$message = <<ENDHELP;
This command deletes a single table from the database.

First you must select an entry from the displayed list of existing
database tables. After the table has been selected you click on the
"Delete" button to delete the table.
ENDHELP

	$dialog = $delete_table_win2->Dialog(-text => $message, -bitmap => 'info',
			-title => 'Delete Table Help', -default_button => 'Continue',
			-buttons => [qw/Continue/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$dialog->Show();

	return;
} # end of display_delete_table_help_text

1;
