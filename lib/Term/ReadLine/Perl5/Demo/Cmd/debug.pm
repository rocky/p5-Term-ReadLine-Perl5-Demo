# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Term::ReadLine::Perl5::Demo::Cmd::debug;

use rlib '../lib';
use Term::ReadLine::Perl5::Demo::Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 0;  # Need at least this many
use constant MAX_ARGS  => 1;  # Need at most this many
EOE
}

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<debug> [B<on>|B<off>]

debug turn on or off $Term::ReadLine::Perl5::Debug (debugging).

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    my $on_off = 1;
    if (@args == 2) {
	$on_off = $self->{proc}->get_onoff($args[1]);
	return unless defined($on_off);
    }
    $Term::ReadLine::Perl5::readline::DEBUG = $on_off;
}

unless (caller) {
    require Term::ReadLine::Perl5::Demo::CmdProc;
    require Term::ReadLine::Perl5;
    my $term = new Term::ReadLine::Perl5 'Keymap test';
    my $proc = Term::ReadLine::Perl5::Demo::CmdProc->new($term);
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, 'off']);
}

1;
