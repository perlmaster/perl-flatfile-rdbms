#!/usr/bin/perl -w

######################################################################
#
# File      : ff_widgets.pl
#
# Author    : Barry Kimelman
#
# Created   : January 4, 2004
#
# Purpose   : Various low-level utility routines to use widgets.
#
######################################################################

use strict;
use lib qw(.);
use My::Myglobalvars qw($dialog_font);

my %yes_no = ( "Yes" => 1 , "No" => 0 );

######################################################################
#
# Function  : ask_yes_no_question
#
# Purpose   : Get a Yes or No answer to a specified question.
#
# Inputs    : $_[0] - the question
#             $_[1] - Tk window descriptor
#
# Output    : Dialog box with question.
#
# Returns   : If answer is Yes Then 1 Else 0
#
# Example   : $status = ask_yes_no_question("Are you sure ?",$win2);
#
# Notes     : (none)
#
######################################################################

sub ask_yes_no_question
{
	my ( $question , $win ) = @_;
	my ( $dialog , $answer );

	$dialog = $win->Dialog(-text => $question, -bitmap => 'question',
			-title => 'Yes / No', -default_button => 'Yes',
			-buttons => [qw/Yes No/] , -wraplength => '6i' ,
			-font => $dialog_font );
	$answer = $dialog->Show();

	return $yes_no{$answer};
} # end of ask_yes_no_question

1;
