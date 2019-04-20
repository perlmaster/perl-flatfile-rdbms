#!/usr/local/bin/perl -w

######################################################################
#
# File      : time_date.pl
#
# Author    : Barry Kimelman
#
# Created   : December 2, 2003
#
# Purpose   : Functions to manipulate time date values.
#
######################################################################

my @months = ( "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" ,
              "Sep" , "Oct" , "Nov" , "Dec" );

######################################################################
#
# Function  : format_time_date
#
# Purpose   : Format a binary time value into a printable ASCII string.
#
# Inputs    : $_[0] - the binary time value
#
# Output    : (none)
#
# Returns   : formatted ASCII time/date value
#
# Example   : $today = format_time_date(time);
#
# Notes     : (none)
#
######################################################################

sub format_time_date
{
  my ( $clock ) = @_;
  my ( $sec , $min , $hour , $mday , $mon , $year , $wday , $yday , $isdst );
  my ( $buffer , $am_pm );

  ( $sec , $min , $hour , $mday , $mon , $year , $wday , $yday , $isdst ) =
              localtime($clock);
  if ( $hour < 12 ) {
	$am_pm = "am";
	if ( $hour == 0 ) {
		$hour = 12;
	} # IF
  } # IF
  else {
	$am_pm = "pm";
	if ( $hour > 12 ) {
		$hour -= 12;
	} # IF
  } # ELSE
  $buffer = sprintf "%02d:%02d:%02d %s  %s %02d, %d",$hour,$min,$sec,$am_pm,
                    $months[$mon],$mday,1900+$year;
  return $buffer;
} # end of format_time_date

######################################################################
#
# Function  : get_time_date_stamp
#
# Purpose   : Construct a timedate-stamp value suitable for a
#             TIMEDATE database column.
#
# Inputs    : (none)
#
# Output    : (none)
#
# Returns   : formatted ASCII time/date value
#
# Example   : $today = get_time_date_stamp(time);
#
# Notes     : (none)
#
######################################################################

sub get_time_date_stamp
{
  my ( $clock );
  my ( $sec , $min , $hour , $mday , $mon , $year , $wday , $yday , $isdst );
  my ( @months , $buffer );

  ( $sec , $min , $hour , $mday , $mon , $year , $wday , $yday , $isdst ) =
              localtime(time);
  $buffer = sprintf "%02d:%02d:%02d %02d/%02d/%02d",$hour,$min,$sec,
                    1+$mon,$mday,$year+1900;
  return $buffer;
} # end of get_time_date_stamp

1;
