#!/usr/bin/perl

######################################################################
#
# File      : ff_encrypt.pl
#
# Author    : Barry Kimelman
#
# Created   : December 30, 2003
#
# Purpose   : Perl script for encrypting and decoding data.
#
######################################################################

use strict;


my $baseline_data_string  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-,;:(){}~!%^=*";
my $encryption_key_string = ":!gS3,k8G6xbcd9%Fqnlot27y~Pus-wRvaIZz{(CE;mHXOUV=1WKDA4QTrJjhiN5e)*MB^pf+LY}0";

######################################################################
#
# Function  : encrypt_string
#
# Purpose   : Encrypt the data in the specified string.
#
# Inputs    : $_[0] - the string to be encrypted
#
# Output    : (none)
#
# Returns   : encrypted string
#
# Example   : $encrypted = &encrypt_string($string);
#
# Notes     : (none)
#
######################################################################

sub encrypt_string
{
	my ( $string ) = @_;

	for ( $string ) {
		eval qq{ tr/${baseline_data_string}/${encryption_key_string}/ };
	} # FOR

	return $string;
} # end of encrypt_string

######################################################################
#
# Function  : decrypt_string
#
# Purpose   : Decrypt the encrypted data in the specified string.
#
# Inputs    : $_[0] - the string to be decrypted
#
# Output    : (none)
#
# Returns   : decrypted string
#
# Example   : $string = &decrypt_string($encrypted);
#
# Notes     : (none)
#
######################################################################

sub decrypt_string
{
	my ( $string ) = @_;

	for ( $string ) {
		eval qq{ tr/${encryption_key_string}/${baseline_data_string}/ };
	} # FOR

	return $string;
} # end of decrypt_string

1;