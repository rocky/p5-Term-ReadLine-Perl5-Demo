# -*- coding: utf-8 -*-
# Copyright (C) 2016 Rocky Bernstein <rocky@cpan.org>
use Term::ReadLine::Perl5::readline;
package Term::ReadLine::Perl5::Demo::Cmd::EditMode;
use Data::Printer;
use rlib '../lib';

use Term::ReadLine::Perl5::Demo::Cmd;
use Term::ReadLine::Perl5::Demo::CmdProc qw(complete_token);
use constant MIN_ARGS  => 0;  # Need at least this many
use constant MAX_ARGS  => 1;  # Need at most this many

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<Editmode> [B<emacs>|B<vi>|B<vicmd>|B<vipos>|B<visearch>]

Set/Show edit mode

=cut
HELP

sub complete($$)
{
    my ($self, $prefix) = @_;
    my @completions = qw(emacs vi vicmd vipos visearch);
    complete_token(\@completions, $prefix);
}

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    my $proc = $self->{proc};
    my $term = $proc->{term};
    my @keymap;
    my $keymap_name;
    my ($default, $name);
    if (@args == 1) {
	my $edit_mode = $Term::ReadLine::Perl5::readline::editMode;
	print("Keymap: $edit_mode\n");
    } else {
	# FIXME: DRY me.
	$keymap_name = $args[1];
	if ($keymap_name eq 'emacs') {
	    @Term::ReadLine::Perl5::KeyMap = @Term::ReadLine::Perl5::readline::emacs_keymap;
	} elsif ($keymap_name eq 'vi') {
	    @Term::ReadLine::Perl5::KeyMap = @Term::ReadLine::Perl5::readline::vi_keymap;
	} elsif ($keymap_name eq 'vicmd') {
	    @Term::ReadLine::Perl5::KeyMap = @Term::ReadLine::Perl5::readline::vicmd_keymap;
	} elsif ($keymap_name eq 'vipos') {
	    @Term::ReadLine::Perl5::KeyMap = @Term::ReadLine::Perl5::readline::vipos_keymap;
	} elsif ($keymap_name eq 'visearch') {
	    @Term::ReadLine::Perl5::KeyMap = @Term::ReadLine::Perl5::readline::visearch_keymap;
	} else {
	    $self->errmsg("Was expecting arg to be either: emacs, vi, vicmd, vipos, or visearch");
	    return;
	}
	$Term::ReadLine::Perl5::readline::editMode = $keymap_name;
	print("Keymap now set to ${keymap_name}\n");
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
