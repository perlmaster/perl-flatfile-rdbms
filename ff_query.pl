#!/usr/bin/perl -w

######################################################################
#
# File      : ff_query.pl
#
# Author    : Barry Kimelman
#
# Created   : January 10, 2004
#
# Purpose   : Routines to implement query processing for the
#             Flatfile RDBMS.
#
######################################################################

use strict;
use lib qw(.);
use My::Myglobalvars qw(%systables_hash $errmsg @systables_entries $systables_table_id_column
			$rdbms_dirname $systables_filename_column $systables_coltotal_column
			$field_separator);

######################################################################
#
# Function  : run_query
#
# Purpose   : Perform the requested query.
#
# Inputs    : $_[0] - name of table
#             $_[1] - joined list of column names
#             $_[2] - selection criteria
#             $_[3] - ref to array to receive query result
#             $_[4] - ref to array to receive array of parsed column names
#             $_[5] - ref to array to receive maximum column lengths
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = &run_query($tablename,$columns,$criteria,\@result,
#                              \@colnames,\@col_maxlen);
#
# Notes     : (none)
#
######################################################################

sub run_query
{
	my ( $tablename , $column_names , $criteria , $ref_result , $ref_colnames , $ref_maxlen ) = @_;
	my ( $table_id , $status , @column_names , %columns , $colname );
	my ( $sep , @query_columns_list , %query_columns_flags );
	my ( $num_query_columns , $num_table_columns , $col , @ordered_columns );
	my ( @column_info , @query_info , %column_data_types );

	@$ref_result = ();
	@$ref_colnames = ();
	@$ref_maxlen = ();
	unless ( exists $systables_hash{lc $tablename} ) {
		$errmsg = "Invalid tablename \"$tablename\"";
		return 0;
	} # UNLESS

	if ( &fetch_table_column_names($tablename,\%columns,\@ordered_columns,\%column_data_types) < 0 ) {
		return 0;
	} # IF
	$num_table_columns = scalar keys %columns;
	$num_query_columns = 0;
	@query_columns_list = ();

# Build a hash : key is column_name , value is -1
	%query_columns_flags = map { $_ , -1 } keys %columns;

	$status = 1;
	$errmsg = "Invalid column names :";
	$sep = " ";
	@column_names = split(/,/,$column_names);
	foreach $colname ( @column_names ) {
		$colname = lc $colname;
		if ( $colname ne "*" ) {
			if ( exists $columns{$colname} ) {
				if ( $query_columns_flags{$colname} < 0 ) { # Column not yet specified ?
					$query_columns_flags{$colname} = $num_query_columns++;
					push @query_columns_list,$colname;
				} # IF
			} # IF
			else {
				$status = 0;
				$errmsg .= $sep . $colname;
				$sep = " , ";
			} # ELSE
		} # IF colname is not "*"
		else {
			foreach $col ( @ordered_columns ) {
				if ( $query_columns_flags{$col} < 0 ) { # Column not yet specified ?
					$query_columns_flags{$col} = $num_query_columns++;
					push @query_columns_list,$col;
				} # IF
			} # FOREACH
		} # ELSE colname is "*"
	} # FOREACH loop over user specified colnames
	if ( $status && 0 < length $criteria ) {
		$num_table_columns = &fetch_table_columns($tablename,\@column_info,
												\@ordered_columns);
		$status = &parse_criteria($criteria,\@column_info,\@query_info);
	} # IF
	else {
		@query_info = ();
	} # ELSE
	if ( $status ) {
		@$ref_colnames = @query_columns_list;
		foreach $colname ( @query_columns_list ) {
			push @$ref_maxlen,length $colname;
		} # FOREACH
		$status = &extract_table_rows($tablename,\%columns,\@query_columns_list,
								$ref_result,\@ordered_columns,$ref_maxlen,
								\@query_info,\%column_data_types);
	} # IF

	return $status;
} # end of run_query

######################################################################
#
# Function  : extract_table_rows
#
# Purpose   : Perform the requested query.
#
# Inputs    : $_[0] - name of table
#             $_[1] - ref to hash containing result from
#                     &fetch_table_column_names()
#             $_[2] -  ref to array containing list of columns to be
#                      included in returned rows (this list is in the
#                      order specified by the user)
#             $_[3] -  ref to array to receive returned rows
#             $_[4] - ref to array containing ordered list of columns
#             $_[5] - ref to array containing maximum column data lengths
#             $_[6] - ref to array containing parsed selection criteria
#                     ( $colname , $op , $value )
#             $_[7] - ref to hash containing list of column data types
#                     ( key : colname , value : data type )
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = &extract_table_rows($tablename,\%columns,
#                             \@query_columns_list,\@result_rows,
#                             \@ordered_columns,\@col_maxlen,
#                             \@query_info,\%data_types);
#
# Notes     : (none)
#
######################################################################

sub extract_table_rows
{
	my ( $tablename , $ref_columns_hash , $ref_user_columns , 
			$ref_result_set , $ref_ordered_columns , $ref_maxlen ,
			$ref_query_info , $ref_data_types ) = @_;
	my ( $status , $systables_index , $table_id , @table_entries , $file_path );
	my ( $num_rows , $count , $num_cols , $colname , $row , %colhash );
	my ( $length , $col_index , %col_positions , $col_position , $query_flag );
	my ( $col_data , $data_type , $ignore );

	$status = 1;
	@$ref_result_set = ();
	$tablename = lc $tablename;
	unless ( exists $systables_hash{$tablename} ) {
		$errmsg = "extract_table_rows() : Invalid tablename \"$tablename\"";
		return 0;
	} # UNLESS
	$systables_index = $systables_hash{$tablename};
	$table_id = $systables_entries[$systables_index][$systables_table_id_column];
	$file_path = File::Spec->catfile($rdbms_dirname,
				$systables_entries[$systables_index][$systables_filename_column]);

# Load in the data from the specified table

	$status = &load_file_into_array(\@table_entries,$file_path);
	unless ( $status ) {
		return $status;
	} # UNLESS

	if ( 0 < @$ref_query_info ) {
		$query_flag = 1;
	} # IF
	else {
		$query_flag = 0;
	} # ELSE
	$num_rows = @table_entries;
	$num_cols = $systables_entries[$systables_index][$systables_coltotal_column];
	%colhash = map { $$ref_ordered_columns[$_],$_ } ( 0 .. $num_cols-1 );
	%col_positions = map { $$ref_user_columns[$_],$_ } ( 0 .. $#$ref_user_columns );
	for ( $count = 0 ; $count < $num_rows ; ++$count ) {
		$row = "";
		$ignore = 0;
		foreach $colname ( @$ref_user_columns ) {
			$col_index = $colhash{$colname};
			$col_position = $col_positions{$colname};
			$col_data = $table_entries[$count][$col_index];
			$data_type = $$ref_data_types{$colname};
			if ( $query_flag && $$ref_query_info[0] eq $colname ) {
				if ( ! &match_column_value($col_data,$$ref_query_info[1],
										$$ref_query_info[2],$data_type) ) {
					$ignore = 1;
					last;
				} # IF
			} # IF
			$row .= $col_data . $field_separator;
			$length = length $col_data;
			if ( $length > $$ref_maxlen[$col_position] ) {
				$$ref_maxlen[$col_position] = $length;
			} # IF
		} # FOREACH over specified columns
		unless ( $ignore ) {
			chop $row;
			push @$ref_result_set,$row;
		} # UNLESS
	} # FOR loop over each row in table

	return $status;
} # end of extract_table_rows

1;
