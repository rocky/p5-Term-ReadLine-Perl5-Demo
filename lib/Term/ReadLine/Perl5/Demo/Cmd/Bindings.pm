# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Term::ReadLine::Perl5::readline;
package Term::ReadLine::Perl5::Demo::Cmd::Bindings;
use Data::Printer;
use rlib '../lib';

use Term::ReadLine::Perl5::Demo::Cmd;
use Term::ReadLine::Perl5::Demo::CmdProc qw(complete_token);
use constant MIN_ARGS  => 1;  # Need at least this many
use constant MAX_ARGS  => 1;  # Need at most this many

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<Bindings> {B<emacs>|B<vi>|B<vicmd>|B<vipos>|B<visearch>}

Show current key bindings for the given keymap.

=cut
HELP

sub complete($$)
{
    my ($self, $prefix) = @_;
    my @completions = qw(emacs vi vicmd vipos visearch);
    complete_token(\@completions, $prefix);
}

sub classify($) {
    my $ord = shift;
    return 'Ctrl-' . chr($ord+64) if $ord <= 26;
    return chr($ord) if $ord >= 33 && $ord < 127;
    return 'DEL' if $ord == 127;
    return "' '" if $ord == 32;
    return $ord;
}

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    my $proc = $self->{proc};
    my $term = $proc->{term};
    my @keymap;
    my $keymap_name = $args[1];
    my ($default, $name);
    # FIXME: DRY me.
    if ($keymap_name eq 'emacs') {
	@keymap = @Term::ReadLine::Perl5::readline::emacs_keymap;
	$default = $Term::ReadLine::Perl5::readline::emacs_keymap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::emacs_keymap{'name'};
    } elsif ($keymap_name eq 'vi') {
	@keymap = @Term::ReadLine::Perl5::readline::vi_keymap;
	$default = $Term::ReadLine::Perl5::readline::vi_keymap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::vi_keymap{'name'};
    } elsif ($keymap_name eq 'vicmd') {
	@keymap = @Term::ReadLine::Perl5::readline::vicmd_keymap;
	$default = $Term::ReadLine::Perl5::readline::vicmd_keymap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::vicmd_keymap{'name'};
    } elsif ($keymap_name eq 'vipos') {
	print "GOTIT\n";
	@keymap = @Term::ReadLine::Perl5::readline::vipos_keymap;
	$default = $Term::ReadLine::Perl5::readline::vipos_keymap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::vipos_keymap{'name'};
    } elsif ($keymap_name eq 'visearch') {
	@keymap = @Term::ReadLine::Perl5::readline::visearch_keymap;
	$default = $Term::ReadLine::Perl5::readline::visearch_keymap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::visearch_keymap{'name'};
    } else {
	$self->errmsg("Was expecting arg to be either: emacs, vi, vicmd, vipos, or visearch");
	return;
    }

    $self->section(sprintf "Keymap: %s, Default binding: %s",
		   $name, $default);
    $self->section("Key\tBinding");
    for (my $i=0; $i<=127; $i++) {
	my $action = $keymap[$i];
	next unless defined($action);
	printf("%s:\t%s\n", classify($i), $action);
    }
}

unless (caller) {
    require Term::ReadLine::Perl5::Demo::CmdProc;
    require Term::ReadLine::Perl5;
    my $term = new Term::ReadLine::Perl5 'Keymap test';
    my $proc = Term::ReadLine::Perl5::Demo::CmdProc->new($term);
    $proc->{num_cols} = 30;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, 'emacs']);
    print '=' x 30, "\n";
    $cmd->run([$NAME, 'vipos']);
}

1;
