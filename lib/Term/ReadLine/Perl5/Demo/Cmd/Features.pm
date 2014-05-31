# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Array::Columnize;
package Term::ReadLine::Perl5::Demo::Cmd::Features;
use rlib '../lib';

use Term::ReadLine::Perl5::Demo::Cmd;
use constant MIN_ARGS  => 0;  # Need at least this many
use constant MAX_ARGS  => 0;  # Need at most this many

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<Features>

Show Readline terminal capabilities or "features".

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $term = $proc->{term};
    my @features = sort keys %{ $term->Features; };
    $self->section("Features:");
    $self->msg(Array::Columnize::columnize(\@features,
					   {displaywidth => $proc->{num_cols},
					    colsep => ' ',
					    lineprefix => '  '}));
	}

unless (caller) {
    require Term::ReadLine::Perl5::Demo::CmdProc;
    require Term::ReadLine::Perl5;
    my $term = new Term::ReadLine::Perl5 'Feature test';
    my $proc = Term::ReadLine::Perl5::Demo::CmdProc->new($term);
    $proc->{num_cols} = 30;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
}

1;
