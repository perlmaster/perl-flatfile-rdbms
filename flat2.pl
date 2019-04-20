#!/usr/perl5/bin/perl -w

use strict;
use lib qw(.);
use My::Myglobalvars qw($backup_extension %system_tables);
use FindBin;
use lib $FindBin::Bin;

require "init_flat2.pl";
require "perform2.pl";

print "Call init_flat2()\n";

init_flat2();

print "backup_extension = $backup_extension\n";
print "system_tables : ",join(" , ",keys %system_tables),"\n";

perform2();
print "backup_extension = $backup_extension\n";

exit 0;
