#!/usr/bin/perl -w

######################################################################
#
# File      : flatfile_rdbms.pl
#
# Author    : Barry Kimelman
#
# Created   : December 2, 2003
#
# Purpose   : Routines to implement the logic of the Flatfile RDBMS.
#
######################################################################

use strict;

use My::Myglobalvars qw(%system_tables $errmsg %valid_data_types %numeric_data_types %valid_comparison_operators
			$rdbms_dirname $systables_file $systables_file_path @systables_entries %systables_hash
			$systables_table_id $max_table_id $num_systables_columns $systables_tablename_column
			$systables_filename_column $systables_table_id_column $systables_rectotal_column
			$systables_coltotal_column $syscols_file $syscols_file_path @syscols_entries
			$syscols_table_id $max_col_id $syscols_table_id_column $syscols_colname_column
			$syscols_col_id_column $syscols_datatype_column $num_syscols_columns %data_quotes
			$errmsg $field_separator $activity_log_file_path $activity_log_file);

######################################################################
#
# Function  : add_row_to_table
#
# Purpose   : Add a row to the specified table.
#
# Inputs    : $_[0] - tablename
#             $_[1] - ref to array containing row data
#
# Output    : Initializes the specified file.
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = add_row_to_table($tablename , \@row_data);
#
# Notes     : (none)
#
######################################################################

sub add_row_to_table
{
	my ( $tablename , $ref_row_data ) = @_;
	my ( $tables_index , $path , $row , $status , @encrypted , $column , @data );

# First add the row to the table

	$tables_index = $systables_hash{lc $tablename};
	$path = File::Spec->catfile($rdbms_dirname,$systables_entries[$tables_index][$systables_filename_column]);
	unless ( open(DATABASE_TABLE,">>$path") ) {
		$errmsg = "Can't append entry to table $tablename [$path] : $!";
		return 0;
	} # UNLESS
	@data = @$ref_row_data;
	@encrypted = ();
	foreach $column ( @data ) {
		push @encrypted,encrypt_string($column);
	} # FOREACH
	$row = join("$field_separator",@encrypted);
	print DATABASE_TABLE "$row\n";
	close DATABASE_TABLE;

# Now increment the corresponding row counter in SYSTABLES
	$systables_entries[$tables_index][$systables_rectotal_column] += 1;

# Now write out the modified contents of SYSTABLES
	$status = save_array_to_file(\@systables_entries,$systables_file_path,
					$num_systables_columns);

	return 1;
} # end of add_row_to_table

######################################################################
#
# Function  : create_database_table
#
# Purpose   : Create a physical file representing a table.
#
# Inputs    : $_[0] - name of file
#             $_[1] - name of table
#             $_[2] - value for "sysflag"
#             $_[3] - number of index columns
#
# Output    : Initializes the specified file.
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = create_database_table($filename , $tablename ,
#                             $sysflag , $num_index_cols);
#
# Notes     : (none)
#
######################################################################

sub create_database_table
{
	my ( $filename , $tablename , $sysflag , $num_index_cols ) = @_;
	my ( $path , $now , @row_data , $status );

# First we need to create the physical file that will hold the table data

	$path = File::Spec->catfile($rdbms_dirname,$filename);
	unless ( open(TABLE,">$path") ) {
		$errmsg = "Can't create file for table \"$tablename\" : $!";
		return 0;
	} # UNLESS
	close TABLE;

# Now me must add a row to SYSTABLES for this new table

	$now = get_time_date_stamp();
	$max_table_id += 1;
	@row_data = ( lc $tablename , $filename , $max_table_id , $now , $now , $now ,
					0 , $sysflag , $num_index_cols , 0 );
	$status = add_row_to_table("systables",\@row_data);

	return $status;
} # end of create_database_table

######################################################################
#
# Function  : create_flatfile_rdbms_system
#
# Purpose   : Create a flatfile rdbms file.
#
# Inputs    : $_[0] - name of file
#
# Output    : Initializes the specified file.
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = create_flatfile_rdbms_system($dirname);
#
# Notes     : (none)
#
######################################################################

sub create_flatfile_rdbms_system
{
	my ( $dirname ) = @_;
	my ( $status , $now , @columns );

	$status = 1;

	unless ( mkdir($dirname,0775) ) {
		$errmsg = "mkdir failed for \"$dirname\" : $!";
		return 0;
	} # UNLESS
	$rdbms_dirname = $dirname;
	$activity_log_file_path = File::Spec->catfile($dirname,$activity_log_file);
	init_activity_logfile("Database system created.\n");

	$systables_file_path = File::Spec->catfile($dirname,$systables_file);
	unless ( open(SYSTABLES,">$systables_file_path") ) {
		$errmsg = "Can't create file for table \"SYSTABLES\"";
		return 0;
	} # UNLESS
	$now = get_time_date_stamp();
	close SYSTABLES;

	$syscols_file_path = File::Spec->catfile($dirname,$syscols_file);
	unless ( open(SYSCOLS,">$syscols_file_path") ) {
		$errmsg = "Can't create file for table \"SYSCOLS\"";
		return 0;
	} # UNLESS
	close SYSCOLS;

	%systables_hash =  ( "systables" => 0 , "syscols" => 1 ) ;

# We now NEED to define the array which holds the information from the
# SYSTABLES table. This information is used by the functions which
# manipulate the database.

	@systables_entries = ( [ "systables", $systables_file , $systables_table_id ,
							$now , $now , $now , 0 , 1 , 0 , 0] ,
							[ "syscols", $syscols_file , $syscols_table_id ,
							$now , $now , $now , 0 , 1 , 0 , 0] );

	@syscols_entries = ();

	$status = create_database_table("systables.txt" , "systables" , 1 , 0);
	unless ( $status ) {
		return $status;
	} # UNLESS

	$status = create_database_table("syscols.txt" , "syscols" , 1 , 0);
	unless ( $status ) {
		return $status;
	} # UNLESS

	@columns = ( ["tablename","string",1,0,""] ,
					["filename","string",0,0,""] ,
					["tableid","int",1,0,""] ,
					["created_date","timedate",0,0,""] ,
					["modified_date","timedate",0,0,""] ,
					["accessed_date","timedate",0,0,""] ,
					["num_records","int",0,0,""] ,
					["sysflag","int",0,0,""] ,
					["num_index_cols","int",0,0,""] ,
					["num_columns","int",0,0,""] );
	$status = add_columns_to_table("systables",0,\@columns);

	@columns = ( ["tableid","int",1,0,""] ,
					["colname","string",1,0,""] ,
					["colid","int",1,0,""] ,
					["datatype","string",0,0,""] ,
					["length","int",0,0,""] ,
					["maxwidth","int",0,0,""] ,
					["index_col","int",0,0,""] ,
					["validate_flag","int",0,0,""] ,
					["validate_pattern","string",0,0,""] );
	$status = add_columns_to_table("syscols",1,\@columns);

	return $status;
} # end of create_flatfile_rdbms_system

######################################################################
#
# Function  : load_data_from_syscols
#
# Purpose   : Load data from SYSCOLS.
#
# Inputs    : (none)
#
# Output    : (nothing)
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = load_data_from_syscols();
#
# Notes     : (none)
#
######################################################################

sub load_data_from_syscols
{
	my ( $status , $count );

	$status = load_file_into_array(\@syscols_entries,$syscols_file_path);
	unless ( $status ) {
		return $status;
	} # UNLESS
	$count = @syscols_entries;

# Determine the maximum for "colid" across all defined tables
	for ( $count = 0 ; $count <= $#syscols_entries ; ++$count ) {
		if ( $syscols_entries[$count][$syscols_col_id_column] > $max_col_id ) {
			$max_col_id = $syscols_entries[$count][$syscols_col_id_column];
		} # IF
	} # FOR

	return 1;
} # end of load_data_from_syscols

######################################################################
#
# Function  : init_flatfile_rdbms_system
#
# Purpose   : Initialize processing for an existing flatfile rdbms system.
#
# Inputs    : $_[0] - name of directory containing flatfile rdbms
#
# Output    : Initializes system processing..
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = init_flatfile_rdbms_system($dirname);
#
# Notes     : (none)
#
######################################################################

sub init_flatfile_rdbms_system
{
	my ( $dirname ) = @_;
	my ( $status , $count , $num_tables );

# First setup directory and path values

	$status = 1;
	unless ( -d $dirname ) {
		$errmsg = "\"$dirname\" is not a directory : $!";
		return 0;
	} # UNLESS
	$rdbms_dirname = $dirname;
	$systables_file_path = File::Spec->catfile($dirname,$systables_file);
	$syscols_file_path = File::Spec->catfile($dirname,$syscols_file);
	$activity_log_file_path = File::Spec->catfile($dirname,$activity_log_file);

# Load in the data from the SYSTABLES table

	$status = load_file_into_array(\@systables_entries,$systables_file_path);
	unless ( $status ) {
		return $status;
	} # UNLESS
	$num_tables = @systables_entries;
	%systables_hash = ();
	for ( $count = 0 ; $count < $num_tables ; ++$count ) {
		$systables_hash{$systables_entries[$count][$systables_tablename_column]} =
						$count;
		if ( $systables_entries[$count][$systables_table_id_column] > $max_table_id ) {
			$max_table_id = $systables_entries[$count][$systables_table_id_column];
		} # IF
	} # FOR

# Load in the data from the SYSCOLS table

	$status = load_data_from_syscols();

	return $status;
} # end of init_flatfile_rdbms_system

######################################################################
#
# Function  : add_columns_to_table
#
# Purpose   : Add the specified column to the specified table.
#
# Inputs     : $_[0] - name of table
#              $_[1] - table id
#              $_[2] - ref to array of hashes
#                     each "hash" has the following structure
#                     [ $colname,$data_type,$index_col,$validate_flag,
#                       $validate_pattern ]
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = add_columns_to_table($tablename,$table_id,\@columns);
#
# Notes     : (none)
#
######################################################################

sub add_columns_to_table
{
	my ( $tablename , $table_id , $ref_columns ) = @_;
	my ( $num_columns , $count , $status , $validate_pattern , @row_data );
	my ( $tables_index );

	$num_columns = @$ref_columns;
	$status = 1;

	for ( $count = 0 ; $count < $num_columns ; ++$count ) {
		$max_col_id += 1;  # Get new column id
		if ( 1 > length $$ref_columns[$count][4] ) {
			$validate_pattern = "?";
		} # IF
		else {
			$validate_pattern = $$ref_columns[$count][4];
		} # ELSE
		@row_data = ( $table_id , lc $$ref_columns[$count][0] , $max_col_id ,
						$$ref_columns[$count][1] , 0 , 0 , $$ref_columns[$count][2] ,
						$$ref_columns[$count][3] , $validate_pattern );
		$status = add_row_to_table("syscols" , \@row_data);
	} # FOR

# Now increment the corresponding columns counter in SYSTABLES
	$tables_index = $systables_hash{lc $tablename};
	$systables_entries[$tables_index][$systables_coltotal_column] += $num_columns;

# Now write out the modified contents of SYSTABLES
	$status = save_array_to_file(\@systables_entries,$systables_file_path,
					$num_systables_columns);

	return $status;
} # end of add_columns_to_table

######################################################################
#
# Function  : get_table_id_from_name
#
# Purpose   : Add the specified column to the specified table.
#
# Inputs    : $_[0] - name of table
#
# Output    : (none)
#
# Returns   : IF valid name Then table_id ELSE -1
#
# Example   : $table_id = get_table_id_from_name($tablename);
#
# Notes     : (none)
#
######################################################################

sub get_table_id_from_name
{
	my ( $tablename ) = @_;
	my ( $name , $table_id );

	$name = lc $tablename;
	if ( exists $systables_hash{$name} ) {
		$table_id = $systables_entries[$systables_hash{$name}][$systables_table_id_column];
	} # IF
	else {
		$table_id = -1;
		$errmsg = "Invalid tablename";
	} # ELSE

	return $table_id;
} # end of get_table_id_from_name

######################################################################
#
# Function  : fetch_table_columns
#
# Purpose   : Fetch the column definitions for the specified table.
#
# Inputs    : $_[0] - name of table
#             $_[1] - reference to array to receive column definitions
#             $_[2] - reference to array to receive ordered list of
#                     column names
#
# Output    : (none)
#
# Returns   : IF valid name Then number_of_columns ELSE -1
#
# Example   : $num_columns = fetch_table_columns($tablename,\@columns,
#                                     \@column_names);
#
# Notes     : (none)
#
######################################################################

sub fetch_table_columns
{
	my ( $tablename , $ref_array , $ref_names_list ) = @_;
	my ( $name , $count , $table_id , $num_columns );

	$name = lc $tablename;
	$table_id = -1;
	@$ref_array = ();
	@$ref_names_list = ();
	unless ( exists $systables_hash{$name} ) {
		$errmsg = "Invalid tablename";
		return -1;
	} # UNLESS

	$table_id = $systables_entries[$systables_hash{$name}][$systables_table_id_column];
	$num_columns = 0;
	for ( $count = 0 ; $count <= $#syscols_entries ; ++$count ) {
		if ( $table_id == $syscols_entries[$count][$syscols_table_id_column] ) {
			$num_columns += 1;
			push @$ref_array, $syscols_entries[$count];
			push @$ref_names_list,$syscols_entries[$count][$syscols_colname_column];
		} # IF
	} # FOR

	return $num_columns;
} # end of fetch_table_columns

######################################################################
#
# Function  : fetch_table_info
#
# Purpose   : Fetch the attributes for the specified table.
#
# Inputs    : $_[0] - name of table
#             $_[1] - reference to array to receive attributes
#
# Output    : (none)
#
# Returns   : IF valid name Then 1 ELSE 0
#
# Example   : $status = fetch_table_info($tablename,\@columns);
#
# Notes     : (none)
#
######################################################################

sub fetch_table_info
{
	my ( $tablename , $ref_array ) = @_;
	my ( $systables_index , $name , $colnum );

	@$ref_array = ();
	$name = lc $tablename;
	unless ( exists $systables_hash{$name} ) {
		return 0;
	} # UNLESS
	$systables_index = $systables_hash{$name};
	for ( $colnum = 0 ; $colnum < $num_systables_columns ; ++$colnum ) {
		$$ref_array[$colnum] = $systables_entries[$systables_index][$colnum];
	} # FOR

	return 1;
} # end of fetch_table_info

######################################################################
#
# Function  : fetch_table_column_names
#
# Purpose   : Fetch the list of columns for the specified table.
#
# Inputs    : $_[0] - name of table
#             $_[1] - reference to hash to receive data
#                     (key : column name , value : column_id number)
#             $_[2] - reference to array to receive list of column
#                     names in table definition order
#             $_[3] - reference to hash to receive list of column
#                     data types (key : colname , value : data_type)
#
# Output    : (none)
#
# Returns   : IF valid name Then table_id ELSE -1
#
# Example   : $table_id = fetch_table_column_names($tablename,
#                                        \%columns,\@columns,
#                                        \%data_types);
#
# Notes     : (none)
#
######################################################################

sub fetch_table_column_names
{
	my ( $tablename , $ref_hash , $ref_array , $ref_data_types ) = @_;
	my ( $table_id , $count , $colname );

	%$ref_hash = ();
	@$ref_array = ();
	%$ref_data_types = ();

# Get table id corresponding to tablename
	$table_id = get_table_id_from_name($tablename);
	if ( $table_id < 0 ) {
		return $table_id;
	} # IF

# Construct a hash : key = colname , value = column_id
	for ( $count = 0 ; $count <= $#syscols_entries ; ++$count ) {
		if ( $table_id == $syscols_entries[$count][$syscols_table_id_column] ) {
			$colname = $syscols_entries[$count][$syscols_colname_column];
			$$ref_hash{$colname} =
							$syscols_entries[$count][$syscols_col_id_column];
			push @$ref_array,$colname;
			$$ref_data_types{$colname} = $syscols_entries[$count][$syscols_datatype_column];
		} # IF
	} # FOR

	return $table_id;
} # end of fetch_table_column_names

######################################################################
#
# Function  : build_table
#
# Purpose   : Create the specified database table.
#
# Inputs    : $_[0] - name of table
#             $_[1] - ref to array containing the column names
#             $_[2] - ref to array containing the column data types
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = build_table($tablename,\@colnames,
#                             \@data_types);
#
# Notes     : (none)
#
######################################################################

sub build_table
{
	my ( $tablename , $ref_column_names , $ref_data_types ) = @_;
	my ( $status , $num_columns , $count , $colname , $data_type );
	my ( $filename , @columns , $now );

	$status = 1;
	$tablename = lc $tablename;
	if ( $tablename =~ m/\W/ ) {
		$errmsg = "Invalid characters in tablename";
		return 0;
	} # IF
	if ( exists $systables_hash{$tablename} ) {
		$errmsg = "Table already exists";
		return 0;
	} # IF

	$num_columns = @$ref_column_names;

	@columns = ();
	for ( $count = 0 ; $count < $num_columns ; ++$count ) {
		$colname = lc $$ref_column_names[$count];
		$data_type = lc $$ref_data_types[$count];
		if ( $colname =~ m/\W/ ) {
			$errmsg = "Invalid characters in column name \"$colname\"";
			return 0;
		} # IF
		unless ( $colname =~ m/^[a-zA-Z_]/ ) {
			$errmsg = "Invalid 1st character in column name \"$colname\"";
			return 0;
		} # UNLESS
		unless ( exists $valid_data_types{$data_type} ) {
			$errmsg = "Invalid data_type \"$data_type\" for column \"$colname\"";
			return 0;
		} # UNLESS
		push @columns,[$colname,$data_type,0,0,""];
	} # FOR

	$filename = $tablename . ".txt";
	$status = create_database_table($filename , $tablename ,0,0);
	unless ( $status ) {
		return $status;
	} # UNLESS
	$now = get_time_date_stamp();
	push @systables_entries,[$tablename,$filename,$max_table_id,$now,
								$now,$now,0,0,,0,0];
	$systables_hash{$tablename} = $#systables_entries;

	$status = add_columns_to_table($tablename,$max_table_id,\@columns);
	unless ( $status ) {
		return $status;
	} # UNLESS
	
# Load in the data from the SYSCOLS table
	$status = load_data_from_syscols();

	return $status;
} # end of build_table

######################################################################
#
# Function  : parse_criteria
#
# Purpose   : Parse a record specification criteria string.
#
# Inputs    : $_[0] - string containing user-specified criteria
#             $_[1] - ref to array containing info on table columns
#             $_[2] - ref to array to receive parsed criteria info
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = parse_criteria($criteria,\@column_info,
#                                \@query_info);
#
# Notes     : (none)
#
######################################################################

sub parse_criteria
{
	my ( $criteria , $ref_column_info , $ref_query_info ) = @_;
	my ( $column_number , @fields , $colname , $operator , $value , $quote );
	my ( $found , $data_type , $valid_types , $status , @timedate );
	my ( $end_quote , $length );

	@$ref_query_info = ();
	$criteria =~ s/^\s+//g; # remove leading whitespace
	$criteria =~ s/\s+$//g; # remove trailing whitespace
	@fields = split(/\s+/,$criteria,3);
	if ( 3 != @fields ) {
		$errmsg = "Incorrect number of fields for column criteria";
		return 0;
	} # IF

	$colname = lc $fields[0];
	$operator = uc $fields[1];
	$value = $fields[2];
	$length = length $value;
	$quote = substr ($value,0,1);
	if ( exists $data_quotes{$quote} ) {
		$end_quote = substr ($value,-1,1);
		if ( $length < 2 || $end_quote ne $data_quotes{$quote} ) {
			$errmsg = "Invalid or missing quote for column criteria data value";
			return 0;
		} # IF
		$value = substr($value,1); # remove 1st character (ie. the quote)
		chop $value; # remove the ending quote
		$length -= 2;
	} # IF
	$found = -1;
	for ( $column_number = 0 ; $column_number <= $#$ref_column_info ; ++$column_number ) {
		if ( $colname eq $$ref_column_info[$column_number][$syscols_colname_column] ) {
			$found = $column_number;
			last;
		} # IF
	} # FOR
	if ( $found < 0 ) {
		$errmsg = "Invalid column name for selection criteria";
		return 0;
	} # IF

	$data_type = $$ref_column_info[$column_number][$syscols_datatype_column];
	unless ( exists $valid_comparison_operators{$operator} ) {
		$errmsg = "Invalid selection criteria operator";
		return 0;
	} # UNLESS

	$valid_types = $valid_comparison_operators{$operator};
	unless ( $valid_types eq "*" || $valid_types =~ m/;${data_type};/ ) {
		$errmsg = "Invalid data type for selection criteria operator";
		return 0;
	} # UNLESS

	$status = 1;
	if ( $data_type eq "timedate" ) {
		@timedate = split(/\s+/,$value);
		if ( 1 == @timedate ) {
			$status = validate_date($value);
		} # IF
		else {
			$status = validate_timedate($value);
		} # ELSE
		unless ( $status ) {
			$errmsg = "Invalid data for TIMEDATE criteria : $errmsg";
			return 0;
		} # UNLESS
	} # IF

	@$ref_query_info =  ( $colname , $operator , $value , $column_number );
	return $status;
} # end of parse_criteria

######################################################################
#
# Function  : set_table_records_counter
#
# Purpose   : Parse a record specification criteria string.
#
# Inputs    : $_[0] - index into @systables_entries for table
#             $_[1] - new value for records counter field
#
# Output    : (none)
#
# Returns   : IF error Then 0 ELSE 1
#
# Example   : $status = set_table_records_counter($index,$count);
#
# Notes     : (none)
#
######################################################################

sub set_table_records_counter
{
	my ( $table_index , $count ) = @_;
	my ( $status );

	$systables_entries[$table_index][$systables_rectotal_column] = $count;

# Now write out the modified contents of SYSTABLES
	$status = save_array_to_file(\@systables_entries,$systables_file_path,
					$num_systables_columns);

	return $status;
} # end of set_table_records_counter

1;
