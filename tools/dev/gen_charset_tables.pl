#! perl
use strict;
use warnings;
use POSIX qw(locale_h);
use locale;
use File::Spec;


=head1 NAME

tools/dev/gen_charset_tables.pl -- generate charset tables

=head1 SYNOPSIS

	perl tools/dev/gen_charset_tables.pl

=head1 DESCRIPTION

Generate character set tables.

=cut

my ($svnid)
  = '$Id$' 
  =~ /^\$[iI][dD]:\s(.*)\$$/;
my $fileid = '$'.'id $';
my $charset_dir = File::Spec->catdir(qw/ src charset /);

#
# charset tables to create
#
my %table = (
    "en_US.iso88591" => "Parrot_iso_8859_1_typetable",
#    "en_US.iso885915" => "Parrot_iso_8859_15_typetable",
    "POSIX" => "Parrot_ascii_typetable",
);

my $header = <<"HEADER";
/* $fileid
 * Copyright (C) 2005, The Perl Foundation.
 *
 * DO NOT EDIT THIS FILE DIRECTLY!
 * please update the $0 script instead.
 *
 * Created by $svnid
 *  Overview:
 *     This file contains various charset tables.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */
HEADER

=over

=item B<classify>( $chr )

Character classification

=cut

sub classify {
    my ($chr) = @_;
    my $ret = 0;
    
    $chr = chr($chr);
    $ret |= 0x0001 if $chr =~ /^[[:upper:]]$/;  # CCLASS_UPPERCASE
    $ret |= 0x0002 if $chr =~ /^[[:lower:]]$/;  # CCLASS_LOWERCASE
    $ret |= 0x0004 if $chr =~ /^[[:alpha:]]$/;  # CCLASS_ALPHABETIC
    $ret |= 0x0008 if $chr =~ /^[[:digit:]]$/;  # CCLASS_NUMERIC        
    $ret |= 0x0010 if $chr =~ /^[[:xdigit:]]$/; # CCLASS_HEXADECIMAL    
    $ret |= 0x0020 if $chr =~ /^[[:space:]\x85\xa0]$/;  # CCLASS_WHITESPACE     
    $ret |= 0x0040 if $chr =~ /^[[:print:]]$/;  # CCLASS_PRINTING       
    $ret |= 0x0080 if $chr =~ /^[[:graph:]]$/;  # CCLASS_GRAPHICAL      
    $ret |= 0x0100 if $chr =~ /^[[:blank:]]$/;  # CCLASS_BLANK  
    $ret |= 0x0200 if $chr =~ /^[[:cntrl:]]$/;  # CCLASS_CONTROL        
    $ret |= 0x0400 if $chr =~ /^[[:punct:]]$/;  # CCLASS_PUNCTUATION    
    $ret |= 0x0800 if $chr =~ /^[[:alnum:]]$/;  # CCLASS_ALPHANUMERIC   
    $ret |= 0x1000 if $chr =~ /^[\n\r\f\x85]$/; # CCLASS_NEWLINE
    $ret |= 0x2000 if $chr =~ /^[[:alnum:]_]$/; # CCLASS_WORD

    return $ret;
}


=item B<create_table>( $name )

Create a whole character table

=back

=cut

sub create_table {
    my ($name) = @_;
    my $len = 8;

    print "const PARROT_CCLASS_FLAGS ${name}[256] = {\n";
    foreach my $char (0..255) {
        printf "0x%.4x, ", classify($char);
        print "/* @{[$char-$len+1]}-$char */\n" if $char % $len == $len-1;
    }
    print "};\n";
}



#
# create 'src/charset/tables.c'
#
###########################################################################
my $c_file= File::Spec->catfile($charset_dir, 'tables.c');
open STDOUT, '>', $c_file
    or die "can not open '$c_file': $!\n";
print <<"END";
$header
#include "tables.h"
END
foreach my $name ( sort keys %table ) {
    print STDERR "creating table: '$table{$name}' (charset: $name)\n";
    setlocale(LC_CTYPE, $name);
    create_table($table{$name});
}
close STDOUT;



#
# create 'src/charset/tables.h'
#
###########################################################################
my $h_file= File::Spec->catfile($charset_dir, 'tables.h');
open STDOUT, '>', $h_file
    or die "can not open '$h_file': $!\n";
print <<"END";
$header
#if !defined(PARROT_CHARSET_TABLES_H_GUARD)
#define PARROT_CHARSET_TABLES_H_GUARD
#include "parrot/cclass.h"
#define WHITESPACE  enum_cclass_whitespace
#define WORDCHAR    enum_cclass_word
#define PUNCTUATION enum_cclass_punctuation
#define DIGIT       enum_cclass_numeric
END
foreach my $name ( sort keys %table ) {
    print "extern const PARROT_CCLASS_FLAGS ${table{$name}}[256];\n";
}
print "#endif /* PARROT_CHARSET_TABLES_H_GUARD */\n";
close STDOUT;

# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
