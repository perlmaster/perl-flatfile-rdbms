#!/usr/bin/perl -w

######################################################################
#
# File      : ff-compare.pl
#
# Author    : Barry Kimelman
#
# Created   : December 22, 2003
#
# Purpose   : Comparison routines used by the Flatfile RDBMS.
#
######################################################################

use strict;
use lib qw(.);
use My::Myglobalvars qw(%numeric_data_types);

my %comparison_functions = ( "LIKE" => \&compare_like , "EQ" => \&compare_eq ,
			"NE" => \&compare_ne , "GT" => \&compare_gt , "LT" => \&compare_lt ,
			"LE" => \&compare_le , "GE" => \&compare_ge ,
			"UNLIKE" => \&compare_unlike
			) ;

my $date_less_than = -1;
my $date_equal = 0;
my $date_greater_than = 1;

my $time_less_than = -1;
my $time_equal = 0;
my $time_greater_than = 1;

my $timedate_less_than = -1;
my $timedate_equal = 0;
my $timedate_greater_than = 1;

######################################################################
#
# Function  : match_column_value
#
# Purpose   : Match a column value to a selection criteria.
#
# Inputs    : $_[0] - column data value
#             $_[1] - comparison operator
#             $_[2] - selection criteria value
#             $_[3] - column data type
#
# Output    : (none)
#
# Returns   : IF a match Then 1 ELSE 0
#
# Example   : $flag = match_column_value($col_data,$op,$value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub match_column_value
{
	my ( $col_data , $op , $value , $data_type ) = @_;
	my ( $status , $function );

	$status = 0;
	$function = $comparison_functions{$op};
	$status = &$function($col_data,$value,$data_type);

	return $status;
} # end of match_column_value

######################################################################
#
# Function  : compare_eq
#
# Purpose   : Perform an "EQ" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF equal Then true ELSE false
#
# Example   : $status = compare_eq($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_eq
{
	my ( $column_data , $criteria_value , $data_type ) = @_;
	my ( $status , @timedate );

	if ( exists $numeric_data_types{$data_type} ) {
		$status = $column_data == $criteria_value;
	} # IF
	else {
		if ( $data_type eq "timedate" ) {
			@timedate = split(/\s+/,$criteria_value);
			if ( 1 == @timedate ) {
				@timedate = split(/\s+/,$column_data);
				$status = compare_date_value($timedate[1],$criteria_value) ==
								$date_equal;
			} # IF
			else {
				$status = compare_timedate_value($column_data,$criteria_value) ==
								$timedate_equal;
			} # ELSE
		} elsif ( $data_type eq "date" ) {
			$status = compare_date_value($column_data,$criteria_value) ==
								$date_equal;
		} elsif ( $data_type eq "time" ) {
			$status = compare_time_value($column_data,$criteria_value) ==
								$time_equal;
		} else {
			$status = $column_data eq $criteria_value;
		} # ELSE
	} # ELSE

	return $status;
} # end of compare_eq

######################################################################
#
# Function  : compare_like
#
# Purpose   : Perform an "LIKE" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF like Then true ELSE false
#
# Example   : $status = compare_like($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_like
{
	my ( $column_data , $criteria_value , $data_type ) = @_;
	my ( $status );

	$status = 1;
	if ( $column_data =~ m/${criteria_value}/ ) {
		$status = 1;
	} # IF
	else {
		$status = 0;
	} # ELSE

	return $status;
} # end of compare_like

######################################################################
#
# Function  : compare_unlike
#
# Purpose   : Perform an "UNLIKE" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF unlike Then true ELSE false
#
# Example   : $status = compare_unlike($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_unlike
{
	my ( $status );

	$status = ! compare_like(@_);
	return $status;
} # end of compare_unlike

######################################################################
#
# Function  : compare_ne
#
# Purpose   : Perform an "NE" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF ne Then true ELSE false
#
# Example   : $status = compare_ne($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_ne
{
	my ( $status );

	$status = ! compare_eq(@_);

	return $status;
} # end of compare_ne

######################################################################
#
# Function  : compare_lt
#
# Purpose   : Perform an "LT" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF lt Then true ELSE false
#
# Example   : $status = compare_lt($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_lt
{
	my ( $column_data , $criteria_value , $data_type ) = @_;
	my ( $status , @timedate );

	if ( exists $numeric_data_types{$data_type} ) {
		$status = $column_data < $criteria_value;
	} # IF
	else {
		if ( $data_type eq "timedate" ) {
			@timedate = split(/\s+/,$criteria_value);
			if ( 1 == @timedate ) {
				@timedate = split(/\s+/,$column_data);
				$status = compare_date_value($timedate[1],$criteria_value) ==
								$date_less_than;
			} # IF
			else {
				$status = compare_timedate_value($column_data,$criteria_value) ==
								$timedate_less_than;
			} # ELSE
		} elsif ( $data_type eq "date" ) {
			$status = compare_date_value($column_data,$criteria_value) ==
								$date_less_than;
		} elsif ( $data_type eq "time" ) {
			$status = compare_time_value($column_data,$criteria_value) ==
								$time_less_than;
		} else {
			$status = $column_data lt $criteria_value;
		} # ELSE
	} # ELSE

	return $status;
} # end of compare_lt

######################################################################
#
# Function  : compare_gt
#
# Purpose   : Perform an "GT" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF gt Then true ELSE false
#
# Example   : $status = compare_gt($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_gt
{
	my ( $column_data , $criteria_value , $data_type ) = @_;
	my ( $status , @timedate );

	if ( exists $numeric_data_types{$data_type} ) {
		$status = $column_data > $criteria_value;
	} # IF
	else {
		if ( $data_type eq "timedate" ) {
			@timedate = split(/\s+/,$criteria_value);
			if ( 1 == @timedate ) {
				@timedate = split(/\s+/,$column_data);
				$status = compare_date_value($timedate[1],$criteria_value) ==
								$date_greater_than;
			} # IF
			else {
				$status = compare_timedate_value($column_data,$criteria_value) ==
								$timedate_greater_than;
			} # ELSE
		} elsif ( $data_type eq "date" ) {
			$status = compare_date_value($column_data,$criteria_value) ==
								$date_greater_than;
		} elsif ( $data_type eq "time" ) {
			$status = compare_time_value($column_data,$criteria_value) ==
								$time_greater_than;
		} else {
			$status = $column_data gt $criteria_value;
		} # ELSE
	} # ELSE

	return $status;
} # end of compare_gt

######################################################################
#
# Function  : compare_le
#
# Purpose   : Perform an "LE" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF le Then true ELSE false
#
# Example   : $status = compare_le($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_le
{
	my ( $status );

	$status = ! compare_gt(@_);

	return $status;
} # end of compare_le

######################################################################
#
# Function  : compare_ge
#
# Purpose   : Perform an "GE" comparison operation.
#
# Inputs    : $_[0] - column data
#             $_[1] - selection criteria value
#             $_[2] - column data type
#
# Output    : (none)
#
# Returns   : IF ge Then true ELSE false
#
# Example   : $status = compare_ge($col_data,$criteria_value,$data_type);
#
# Notes     : (none)
#
######################################################################

sub compare_ge
{
	my ( $status );

	$status = ! compare_lt(@_);

	return $status;
} # end of compare_ge

######################################################################
#
# Function  : compare_date_value
#
# Purpose   : Compare 2 strings representing dates.
#
# Inputs    : $_[0] - 1st date string
#             $_[1] - 2nd date string
#
# Output    : (none)
#
# Returns   : IF date1 < date2 Then -1 Elsif date1 == date2 Then 0
#             Else 1
#
# Example   : $status = compare_date_value($date1,$date2);
#
# Notes     : (none)
#
######################################################################

sub compare_date_value
{
	my ( $date1 , $date2 ) = @_;
	my ( $status , $month1 , $day1 , $year1 , $month2 , $day2 , $year2 );

	( $month1 , $day1 , $year1 ) = split(/\//,$date1);
	( $month2 , $day2 , $year2 ) = split(/\//,$date2);

	if ( $year1 < $year2 ) {
		$status = $date_less_than;
	} elsif ( $year1 == $year2 ) {
		if ( $month1 < $month2 ) {
			$status = $date_less_than;
		} elsif ( $month1 == $month2 ) {
			if ( $day1 < $day2 ) {
				$status = $date_less_than;
			} elsif ( $day1 == $day2 ) {
				$status = $date_equal;
			} # ELSIF
			else {
				$status = $date_greater_than;
			} # ELSE
		} # ELSIF
		else {
			$status = $date_greater_than;
		} # ELSE
	} # ELSIF
	else {
		$status = $date_greater_than;
	} # ELSE

	return $status;
} # end of compare_date_value

######################################################################
#
# Function  : compare_time_value
#
# Purpose   : Compare 2 strings representing times.
#
# Inputs    : $_[0] - 1st time string
#             $_[1] - 2nd time string
#
# Output    : (none)
#
# Returns   : IF time1 < time2 Then -1 Elsif time1 == time2 Then 0
#             Else 1
#
# Example   : $status = compare_time_value($time1,$time2);
#
# Notes     : (none)
#
######################################################################

sub compare_time_value
{
	my ( $time1 , $time2 ) = @_;
	my ( $status , $hours1 , $minutes1 , $seconds1 , $hours2 , $minutes2 );
	my ( $seconds2 );

	( $hours1 , $minutes1 , $seconds1 ) = split(/:/,$time1);
	( $hours2 , $minutes2 , $seconds2 ) = split(/:/,$time2);

	if ( $hours1 < $hours2 ) {
		$status = $time_less_than;
	} elsif ( $hours1 == $hours2 ) {
		if ( $minutes1 < $minutes2 ) {
			$status = $time_less_than;
		} elsif ( $minutes1 == $minutes2 ) {
			if ( $seconds1 < $seconds2 ) {
				$status = $time_less_than;
			} elsif ( $seconds1 == $seconds2 ) {
				$status = $time_equal;
			} # ELSIF
			else {
				$status = $time_greater_than;
			} # ELSE
		} # ELSIF
		else {
			$status = $time_greater_than;
		} # ELSE
	} # ELSIF
	else {
		$status = $time_greater_than;
	} # ELSE

	return $status;
} # end of compare_time_value

######################################################################
#
# Function  : compare_timedate_value
#
# Purpose   : Compare 2 strings representing times.
#
# Inputs    : $_[0] - 1st timedate string
#             $_[1] - 2nd timedate string
#
# Output    : (none)
#
# Returns   : IF timedate1 < timedate2 Then -1
#             Elsif timedate1 == timedate2 Then 0
#             Else 1
#
# Example   : $status = compare_timedate_value($timedate1,$timedate2);
#
# Notes     : (none)
#
######################################################################

sub compare_timedate_value
{
	my ( $timedate1 , $timedate2 ) = @_;
	my ( $date1 , $time1 , $date2 , $time2 , $status );

	( $time1 , $date1 ) = split(/\s+/,$timedate1);
	( $time2 , $date2 ) = split(/\s+/,$timedate2);

	$status = compare_date_value($date1,$date2);
	if ( $status == $date_less_than ) {
		$status = $timedate_less_than;
	} elsif ( $status == $date_equal ) {
		$status = compare_time_value($time1,$time2);
		if ( $status == $time_less_than ) {
			$status = $timedate_less_than;
		} elsif ( $status == $time_equal ) {
			$status = $timedate_equal;
		} else {
			$status = $timedate_greater_than;
		} # ELSE
	} else {
		$status = $timedate_greater_than;
	} # ELSE

	return $status;
} # end of compare_timedate_value

1;
