#!/usr/bin/perl -w

use strict;
use lib qw(.);
use My::Myglobalvars qw($errmsg $field_separator $backup_extension);

######################################################################
#
# File      : flatfile_files.pl
#
# Author    : Barry Kimelman
#
# Created   : December 2, 2003
#
# Purpose   : Utility routines and variables for manipulating data
#             files.
#
######################################################################

######################################################################
#
# Function  : load_file_into_array
#
# Purpose   : Load the contents of the file into an array.
#
# Inputs    : $_[0] - reference to array to receive file data
#             $_[1] - name of file
#
# Output    : (none)
#
# Returns   : IF I/O error Then 0 ELSE 1
#
# Example   : $status = load_file_into_array(\@data,$filename);
#
# Notes     : (none)
#
######################################################################

sub load_file_into_array
{
	my ( $array_ref , $filename ) = @_;
	my ( $count , @records , @fields , $buffer );

	@$array_ref = ();
	unless ( open(INPUT,"<$filename") ) {
		$errmsg = "Can't open file \"$filename\" : $!";
		return 0;
	} # UNLESS

	@records = <INPUT>;
	close INPUT;
	chomp @records;
	$count = 0;
	foreach $buffer ( @records ) {
		$buffer = decrypt_string($buffer);
		@fields = split(/${field_separator}/,$buffer);
		$$array_ref[$count++] = [ @fields ];
	} # FOREACH

	return 1;
} # end of load_file_into_array

######################################################################
#
# Function  : save_array_to_file
#
# Purpose   : Save the contents of a hash into a file.
#
# Inputs    : $_[0] - reference to array containing data to be saved
#             $_[1] - name of file to be updated
#             $_[2] - number of data elements in array value
#
# Output    : (none)
#
# Returns   : IF error THEN 0 ELSE 1
#
# Example   : $status = save_array_to_file(\@data,$filename,5);
#
# Notes     : (none)
#
######################################################################

sub save_array_to_file
{
	my ( $array_ref , $filename , $num_elements ) = @_;
	my ( $index , $count , $backup_name , @data , $encrypted );

#	append_to_activity_logfile("save_array_to_file($filename,$num_elements)\n",
#					Dumper($array_ref),"\n");

# First make a backup copy of the file to be modified
	$backup_name = $filename . $backup_extension;
	unlink $backup_name;
	rename $filename,$backup_name;

	unless ( open(DATABASE_FILE,">$filename") ) {
		$errmsg = "Can't open file \"$filename\" : $!";
		return 0;
	} # UNLESS

	for ( $index = 0 ; $index <= $#$array_ref ; ++$index ) {
		@data = ();
		for ( $count = 0 ; $count < $num_elements ; ++$count ) {
			$encrypted = encrypt_string($$array_ref[$index][$count]);
			push @data,$encrypted;
		} # FOR
		print DATABASE_FILE join($field_separator,@data),"\n";
	} # FOR

	close DATABASE_FILE;
	return 1;
} # end of save_array_to_file


######################################################################
#
# Function  : create_empty_database_table_file
#
# Purpose   : Create an empty file for a database table.
#
# Inputs    : $_[0] - name of table file to be created
#
# Output    : (none)
#
# Returns   : IF error THEN 0 ELSE 1
#
# Example   : $status = create_empty_database_table_file($filename);
#
# Notes     : (none)
#
######################################################################

sub create_empty_database_table_file
{
	my ( $filename ) = @_;
	my ( $backup_name );

	$backup_name = $filename . $backup_extension;
	unlink $backup_name;


	unless ( open(DATABASE_FILE,">$filename") ) {
		$errmsg = "Can't open file \"$filename\" : $!";
		return 0;
	} # UNLESS
	close DATABASE_FILE;

	return 1;
} # end of create_empty_database_table_file

1;
