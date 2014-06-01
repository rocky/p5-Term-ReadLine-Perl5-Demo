# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Term::ReadLine::Perl5::readline;
package Term::ReadLine::Perl5::Demo::Cmd::Bindings;
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

B<Bindings> [B<emacs>|B<vi>|B<vicmd>|B<vipos>|B<visearch>]

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
    return 'C-' . chr($ord+96) if $ord <= 26;
    return chr($ord) if $ord >= 33 && $ord < 127;
    return 'DEL' if $ord == 127;
    return "' '" if $ord == 32;
    return "ESC" if $ord == 27;
    return $ord;
}

sub print_keymap($$) {
    my($prefix, $keymap_ary) = @_;
    my @keymap = @$keymap_ary;
    my @continue = ();
    for (my $i=0; $i<=127; $i++) {
	my $action = $keymap[$i];
	next unless defined($action);
	printf("%s%s:\t%s\n", $prefix, classify($i), $action);
	push @continue, $i if $action eq 'F_PrefixMeta';
    }
    return @continue;
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
	@keymap = @Term::ReadLine::Perl5::readline::KeyMap;
	$default = $Term::ReadLine::Perl5::readline::KeyMap{'default'};
	$name    = $Term::ReadLine::Perl5::readline::KeyMap{'name'};
	$keymap_name = 'current';
    } else {
	# FIXME: DRY me.
	$keymap_name = $args[1];
	if ($keymap_name eq 'emacs') {
	    @keymap = @Term::ReadLine::Perl5::readline::emacs_keymap;
	    $default = $Term::ReadLine::Perl5::readline::emacs_keymap{'default'};
	    $name    = 'emacs_keymap';
	} elsif ($keymap_name eq 'vi') {
	    @keymap = @Term::ReadLine::Perl5::readline::vi_keymap;
	    $default = $Term::ReadLine::Perl5::readline::vi_keymap{'default'};
	    $name    = 'vi_keymap';
	} elsif ($keymap_name eq 'vicmd') {
	    @keymap = @Term::ReadLine::Perl5::readline::vicmd_keymap;
	    $default = $Term::ReadLine::Perl5::readline::vicmd_keymap{'default'};
	    $name    = $Term::ReadLine::Perl5::readline::vicmd_keymap{'name'};
	} elsif ($keymap_name eq 'vipos') {
	    @keymap = @Term::ReadLine::Perl5::readline::vipos_keymap;
	    $default = $Term::ReadLine::Perl5::readline::vipos_keymap{'default'};
	    $name    = 'vipos_keymap';
	} elsif ($keymap_name eq 'visearch') {
	    @keymap = @Term::ReadLine::Perl5::readline::visearch_keymap;
	    $default = $Term::ReadLine::Perl5::readline::visearch_keymap{'default'};
	    $name    = 'visearch_keymap'
	} else {
	    $self->errmsg("Was expecting arg to be either: emacs, vi, vicmd, vipos, or visearch");
	    return;
	}
    }

    my @keymaps = ();
    $self->section(sprintf "Keymap: %s, Default binding: %s",
		   $name, $default);
    $self->section("Key\tBinding");
    my @continue = print_keymap('', \@keymap);
    foreach my $keycode (@continue) {
     	my $keymap_name = "Term::ReadLine::Perl5::readline::" .
     	    "${name}_$keycode";
     	    # "$Term::ReadLine::Perl5::readline::KeyMap{'name'}_$keycode";
	my $prefix = classify($keycode) . " ";
	no strict 'refs';
	my @keymap = @$keymap_name;
	print_keymap($prefix, \@keymap);
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
