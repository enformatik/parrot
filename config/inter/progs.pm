# Copyright (C) 2001-2008, Parrot Foundation.

=head1 NAME

config/inter/progs.pm - C Compiler and Linker

=head1 DESCRIPTION

Asks the user which compiler, linker, shared library builder, C libraries,
lexical analyzer generator and parser generator to use. Also whether debugging
should be enabled.

=cut

package inter::progs;

use strict;
use warnings;

use base qw(Parrot::Configure::Step);

use Parrot::Configure::Utils ':inter', ':auto';


sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determine what C compiler and linker to use};
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $ask = _prepare_for_interactivity($conf);

    _get_programs($conf, $ask);

    my $debug = _get_debug($conf, $ask);

    my $debug_validity = _is_debug_setting_valid($debug);
    return unless defined $debug_validity;

    _set_debug_and_warn($conf, $debug);

    test_compiler($conf);

    return 1;
}

sub _prepare_for_interactivity {
    my $conf = shift;
    my $ask = $conf->options->get('ask');
    if ($ask) {
        print <<'END';


    Okay, I'm going to start by asking you a couple questions about your
    compiler and linker.  Default values are in square brackets; you can
    hit ENTER to accept them.  If you don't understand a question, the
    default will usually work--they've been intuited from your Perl 5
    configuration.

END
    }
    return $ask;
}

sub _get_programs {
    my ($conf, $ask) = @_;
    # Set each variable individually so that hints files can use them as
    # triggers to help pick the correct defaults for later answers.
    my ( $cc, $cxx, $link, $ld, $ccflags, $linkflags, $ldflags, $arflags);
    my ( $libs, $lex, $yacc, $ar );
    $cc = integrate( $conf->data->get('cc'), $conf->options->get('cc') );
    $cc = prompt( "What C compiler do you want to use?", $cc )
        if $ask;
    $conf->data->set( cc => $cc );

    $link = integrate( $conf->data->get('link'), $conf->options->get('link') );
    $link = prompt( "How about your linker?", $link ) if $ask;
    $conf->data->set( link => $link );

    $ld = integrate( $conf->data->get('ld'), $conf->options->get('ld') );
    $ld = prompt( "What program do you want to use to build shared libraries?", $ld ) if $ask;
    $conf->data->set( ld => $ld );

    $ccflags = integrate( $conf->data->get('ccflags'), $conf->options->get('ccflags') );

    # Remove some perl5-isms.
    $ccflags =~ s/-D((PERL|HAVE)_\w+\s*|USE_PERLIO)//g;
    $ccflags =~ s/-fno-strict-aliasing//g;
    $ccflags =~ s/-fnative-struct//g;
    $ccflags = prompt( "What flags should your C compiler receive?", $ccflags )
        if $ask;
    $conf->data->set( ccflags => $ccflags );

    $conf->debug("\nccflags: $ccflags\n");

    $ar = integrate( $conf->data->get('ar'), $conf->options->get('ar') );
    $ar = prompt( "What archiver do you want to use to build static libraries?", $ar ) if $ask;
    $conf->data->set( ar => $ar );

    $arflags = integrate( $conf->data->get('arflags'), $conf->options->get('arflags') );
    $arflags = prompt( "What flags should your archiver receive to create static libraries?",
                $arflags) if $ask;
    $conf->data->set( arflags => $arflags );


    $linkflags = $conf->data->get('linkflags');
    # Remove the path to the Perl library (from Win32 config).
    # See TT #854.
    $linkflags =~ s/-libpath:\S+//g;
    $linkflags = integrate( $linkflags, $conf->options->get('linkflags') );
    $linkflags = prompt( "And flags for your linker?", $linkflags ) if $ask;
    $conf->data->set( linkflags => $linkflags );

    $ldflags = $conf->data->get('ldflags');
    # For substitution below, see comment for $linkflags above.
    $ldflags =~ s/-libpath:\S+//g;
    $ldflags = integrate( $ldflags, $conf->options->get('ldflags') );
    $ldflags = prompt( "And your $ld flags for building shared libraries?", $ldflags )
        if $ask;
    $conf->data->set( ldflags => $ldflags );

    $libs = $conf->data->get('libs');
    $libs = join q{ },
        grep { $conf->data->get('OSNAME_provisional') =~ /VMS|MSWin/ || !/^-l(c|gdbm(_compat)?|dbm|ndbm|db)$/ }
        split( q{ }, $libs );
    $libs = integrate( $libs, $conf->options->get('libs') );
    $libs = prompt( "What libraries should your C compiler use?", $libs )
        if $ask;
    $conf->data->set( libs => $libs );

    $cxx = integrate( $conf->data->get('cxx'), $conf->options->get('cxx') );
    $cxx = prompt( "What C++ compiler do you want to use?", $cxx ) if $ask;
    $conf->data->set( cxx => $cxx );
}

sub _get_debug {
    my ($conf, $ask) = @_;
    my $debug = 'n';
    $debug = 'y' if $conf->options->get('debugging');
    $debug = prompt( "Do you want a debugging build of Parrot?", $debug )
        if $ask;
    return $debug;
}

sub _is_debug_setting_valid {
    my $debug = shift;
    ( $debug =~ /^[yn]$/i ) ? return 1 : return;
}

sub _set_debug_and_warn {
    my ($conf, $debug) = @_;
    if ( $debug =~ /n/i ) {
        $conf->data->set(
            link_debug => '',
            ld_debug   => ''
        );
        # We want to keep -g even if --debugging was not requested.
        # We can strip it easily. -DNDEBUG does the most optimizations.
        if ($conf->data->get('cc_debug') ne '-g') {
            $conf->data->set(cc_debug => '');
        }
    }

    # This one isn't prompted for above.  I don't know why.
    my $ccwarn = integrate( $conf->data->get('ccwarn'), $conf->options->get('ccwarn') );
    $conf->data->set( ccwarn => $ccwarn );
    return $conf;
}

sub test_compiler {
    my ($conf) = @_;
    my ($cc, $link) = $conf->data->get('cc', 'link');

    open( my $out_fh, '>', "test_$$.c" )
        or die "Unable to open 'test_$$.c': $@\n";
    print {$out_fh} <<END_C;
#include <stdio.h>
int main() {
    puts("ok");
    return 0;
}
END_C
    close $out_fh;

    $conf->debug("\ncc=$cc, link=$link\n");
    unless ( eval { $conf->cc_build(); 1 } ) {
        if ($cc eq $link) {
            warn "Compilation failed with '$cc''\n";
        }
        else {
            warn "Compilation failed with '$cc' and '$link'\n";
        }
        exit 1;
    }

    unless ( eval { $conf->cc_run(); 1 } ) {
        warn $@ if $@;
        exit 1;
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
