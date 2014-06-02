#!/usr/bin/env perl
#  Copyright (C) 2013-2014 Rocky Bernstein <rocky@cpan.org>
#

use strict;
use warnings;
use Module::Build;
use Config;
use File::Basename;
use File::Spec;

my $min_file_homedir_version = '0.81';
my $min_perl_version         = '5.006002';

my $lib = File::Spec->catfile(dirname(__FILE__), 'lib');
unshift @INC, $lib;
my $release_status = 'stable'; # or 'testing';
my $builder = Module::Build->new(
    module_name         => 'Term::ReadLine::Perl5::Demo',
    add_to_cleanup      => ['Term-ReadLine-Perl5*', 'tmp*', '.history.text',
			    'pod2htm*.tmp'],
    create_makefile_pl  => 'passthrough',
    dist_abstract       => 'Shell for Term::ReadLine::Perl5',
    dist_author         => 'Rocky Bernstein <rocky@cpan.org>',
    dist_version_from   => 'lib/Term/ReadLine/Perl5/Demo/Cmd.pm',
    license             => 'perl',
    needs_compiler      => 0,
    release_status      => $release_status,

    meta_merge => {
	resources => {
	    bugtracker  => 'https://github.com/rocky/p5-Term-ReadLine-Perl5-Demo/issues',
	    repository  => 'http://github.com/rocky/p5-Term-ReadLine-Perl5-Demo'
	}
    },

    test_requires => {
        'Test::Pod'               => '1.44',
    },
    configure_requires => {
        'rlib'                    => '0.02',
	'Module::Build'           => '0.4004',  # Min "test_requires"
	'perl'                    => $min_perl_version,
    },
    requires => {
        'perl'                    => $min_perl_version,
        'Array::Columnize'        => '1.04',
        'rlib'                    => '0.02',
        'version'                 => 0,
        'Term::ReadLine::Perl5'   => '1.33',
        'Pod::Text::Color'        => '2.06',
    },
    sign                => ($ENV{PERL_MB_NOSIGN} ? 0 : 1),
    );

$builder->create_build_script();
