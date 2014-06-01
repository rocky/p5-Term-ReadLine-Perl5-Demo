#!/usr/bin/env perl
# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
# The intent here is to have something for folks to play with to show
# off Term::ReadLine::Perl5. Down the line, what would be nice is
# to have a command-line interface for showing/changing readline
# functions.
# use Enbugger 'trepan';
use strict; use warnings;

use Term::ReadLine::Perl5;
use Term::ReadKey;
use Data::Printer;

use rlib '../lib';
use Term::ReadLine::Perl5::Demo::CmdProc;

END{
    print "That's all folks!...\n";
    Term::ReadLine::Perl5::readline::ResetTTY;
}

my $term = new Term::ReadLine::Perl5 'Term::ReadLine::Perl5 shell';
my $attribs = $term->Attribs;

my $cmdproc = Term::ReadLine::Perl5::Demo::CmdProc->new($term);

print "================================================\n";
print "Welcome to the Term::ReadLine::Perl5 demo shell!\n";
print "================================================\n";

# Silence "used only once warnings" inside ReadLine::Term::Perl.
no warnings 'once';
$attribs->{completion_function} = sub($$$$) {
    my ($text, $line, $start, $end) = @_;
    Term::ReadLine::Perl5::Demo::CmdProc::command_completion($cmdproc, $text,
							     $line, $start,
							     $end);
};

print "\nType 'help' for help, and 'exit' to leave.\n";
print "Entered lines are echoed and put into history.\n";

my $initfile = '.inputrc';
if (Term::ReadLine::Perl5::readline::read_an_init_file($initfile)) {
    print "$initfile loaded\n";
};

$Term::ReadLine::Perl5::preput = 0;

my $prompt = 'terps> ';
while ( defined (my $line = $term->readline($prompt)) )
{
    ### FIXME do this in a more general way.
    chomp $line;
    my @args = split(/[ \t]/, $line);
    next unless @args;
    my $cmd_name = $args[0];
    if ($cmd_name eq 'exit') {
	last;
    } else {
	my $cmd = $cmdproc->{commands}{$cmd_name};
	if ($cmd) {
            if ($cmdproc->ok_for_running($cmd, $cmd_name, scalar(@args)-1)) {
		$cmd->run(\@args);
	    }
	} else {
	    print "You typed:\n$line\n";
	}
    }
    no warnings 'once';
    $term->addhistory($line) if $line =~ /\S/
	and !$Term::ReadLine::Perl5::features{autohistory};
    $readline::rl_default_selected = !$readline::rl_default_selected;
}

$Term::ReadLine::Perl5::DEBUG = 0;
