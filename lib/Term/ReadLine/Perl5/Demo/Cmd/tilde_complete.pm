# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Term::ReadLine::Perl5::Demo::Cmd::tilde_complete;
use Data::Printer;
use rlib '../../lib';

use rlib '.';
use if !@ISA, Term::ReadLine::Perl5::Demo::Cmd;
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

B<tilde_complete> I<~var>

Give list of filename completions for I<~var>.

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    my $proc = $self->{proc};
    my $prefix = (@args == 1) ? '~': $args[1];
    if (substr($prefix, 0, 1) ne '~') {
	$proc->errmsg("Tilde expansion expected to start with ~");
    } else {
	$prefix = substr($prefix, 1);
	my @matches =
	    Term::ReadLine::Perl5::readline::tilde_complete($prefix);
	p @matches;
    }
}

unless (caller) {
    my $proc = Term::ReadLine::Perl5::Demo::Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
    print "-" x 30, "\n";
    $cmd->run([$NAME, '~r']);
}

1;
