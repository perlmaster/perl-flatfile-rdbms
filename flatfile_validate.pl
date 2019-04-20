#!/usr/bin/perl -w

######################################################################
#
# File      : flatfile_validate.pl
#
# Author    : Barry Kimelman
#
# Created   : December 12, 2003
#
# Purpose   : Data validation routines used by the Flatfile RDBMS.
#
######################################################################

use strict;
use lib qw(.);
use My::Myglobalvars qw($errmsg);

######################################################################
#
# Function  : validate_int
#
# Purpose   : Validate the specified string as an integer.
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_int($string);
#
# Notes     : (none)
#
######################################################################

sub validate_int
{
	my ( $string ) = @_;
	my ( $status );

	if ( 1 > length $string ) {
		$errmsg = "Empty numeric field";
		$status = 0;
	} # IF
	elsif ( $string =~ m/^[-]??\d+$/ ) {
		$status = 1;
	} # IF
	else {
		$errmsg = "Non-numeric characters";
		$status = 0;
	} # ELSE

	return $status;
} # end of validate_int

######################################################################
#
# Function  : validate_float
#
# Purpose   : Validate the specified string as floating point.
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_float($string);
#
# Notes     : (none)
#
######################################################################

sub validate_float
{
	my ( $string ) = @_;
	my ( $status );

	if ( 1 > length $string ) {
		$errmsg = "Empty floating-point field";
		$status = 0;
	} # IF
	elsif ( $string =~ m/^[-]??\d+\.\d{1,}$/ ) {
		$status = 1;
	} # IF
	else {
		$errmsg = "Non-floating-point characters";
		$status = 0;
	} # ELSE

	return $status;
} # end of validate_float

######################################################################
#
# Function  : validate_string
#
# Purpose   : Validate the specified string as a "string".
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_string($string);
#
# Notes     : (none)
#
######################################################################

sub validate_string
{
	my ( $string ) = @_;
	my ( $status );

	if ( 1 > length $string ) {
		$errmsg = "Empty string field";
		$status = 0;
	} # IF
	else {
		$status = 1;
	} # ELSE

	return $status;
} # end of validate_string

######################################################################
#
# Function  : validate_timedate
#
# Purpose   : Validate the specified string as a "timedate".
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_timedate($string);
#
# Notes     : (none)
#
######################################################################

sub validate_timedate
{
	my ( $string ) = @_;
	my ( $status , $hours , $mins , $secs , $month , $mday , $year );
	my ( @month_days , @list1);

	$status = 1;
	if ( 1 > length $string ) {
		$errmsg = "Empty timedate field";
		$status = 0;
	} # IF
	else {
		if ( $string =~ m/^(\d{1,2})\:(\d{1,2})\:(\d{1,2})\s+(\d{1,2})\/(\d{1,2})\/(\d{4})$/ ) {
			( $hours , $mins , $secs , $month , $mday , $year ) =  ( $1 , $2 , $3 , $4 , $5 , $6 );
			if ( $hours > 23 || $mins > 59 || $secs > 59 || $month > 12 || $mday > 31 ) {
				$errmsg = "Timedate component out of range";
				return 0;
			} # IF
			@month_days = ( 31 , 28 , 31 , 30 , 31 , 30 , 31 , 31, 30 , 31 , 30 , 31 );
			if ( $year%4 == 0 ) {
				if ( $year%400 || ! $year%100 ) {
					$month_days[1] = 29;
				} # IF
			} # IF
			if ( $mday > $month_days[$month-1] ) {
				$errmsg = "Day-of-month too large";
				return 0;
			} # IF
			$status = 1;
		} # IF
		else {
			$errmsg = "Invalid timedate characters";
			print "$errmsg\n";
			@list1 =  ( $1 , $2 , $3 , $4 , $5 , $6 );
			print join(" , ",@list1),"\n";
			$status = 0;
		} # ELSE
	} # ELSE

	return $status;
} # end of validate_timedate

######################################################################
#
# Function  : validate_date
#
# Purpose   : Validate the specified string as a "date".
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_date($string);
#
# Notes     : (none)
#
######################################################################

sub validate_date
{
	my ( $string ) = @_;
	my ( $status , $month , $mday , $year );
	my ( @month_days , @list1);

	$status = 1;
	if ( 1 > length $string ) {
		$errmsg = "Empty timedate field";
		$status = 0;
	} # IF
	else {
		if ( $string =~ m/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/ ) {
			( $month , $mday , $year ) =  ( $1 , $2 , $3 );
			if ( $month > 12 || $mday > 31 ) {
				$errmsg = "Date component out of range";
				return 0;
			} # IF
			@month_days = ( 31 , 28 , 31 , 30 , 31 , 30 , 31 , 31, 30 , 31 , 30 , 31 );
			if ( $year%4 == 0 ) {
				if ( $year%400 || ! $year%100 ) {
					$month_days[1] = 29;
				} # IF
			} # IF
			if ( $mday > $month_days[$month-1] ) {
				$errmsg = "Day-of-month too large";
				return 0;
			} # IF
			$status = 1;
		} # IF
		else {
			$errmsg = "Invalid date characters";
			print "$errmsg\n";
			@list1 =  ( $1 , $2 , $3 , $4 , $5 , $6 );
			print join(" , ",@list1),"\n";
			$status = 0;
		} # ELSE
	} # ELSE

	return $status;
} # end of validate_date

######################################################################
#
# Function  : validate_time
#
# Purpose   : Validate the specified string as a "time".
#
# Inputs    : $_[0] - the string to be validated
#
# Output    : (nothing)
#
# Returns   : If valid Then 1 Else 0
#
# Example   : $status = validate_time($string);
#
# Notes     : (none)
#
######################################################################

sub validate_time
{
	my ( $string ) = @_;
	my ( $hours , $minutes , $seconds );

	unless ( $string =~ m/^(\d{1,2})\:(\d{1,2})\:(\d{1,2})$/ ) {
		$errmsg = "Invalid characters for TIME value";
		return 0;
	} # UNLESS

	( $hours , $minutes , $seconds ) =  ( $1 , $2 , $3);
	if ( $hours > 23 || $minutes > 59 || $seconds > 59 ) {
		$errmsg = "TIME component out of range";
		return 0;
	} # IF

	return 1;
} # end of validate_time

1;
