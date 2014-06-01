# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Term::ReadLine::Perl5::Demo::Cmd::rl_read_init_file;
use Data::Printer;
use rlib '../lib';
use Term::ReadLine::Perl5::Demo::Cmd;
use Term::ReadLine::Perl5::Demo::CmdProc qw(filename_list);

unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 1;  # Need at least this many
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

B<rl_read_init_file> I<filename>

Read key bindings and variable assignments from filename.

Runs L<Term::ReadLine::Perl5::read_init_file>.
=cut
HELP

sub complete($$)
{
    my ($self, $prefix) = @_;
    filename_list($prefix);
}

sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $filename = $args->[1];

    if (Term::ReadLine::Perl5::readline::rl_read_init_file($filename)) {
	$proc->msg("Filename $filename read");
    } else {
	$proc->msg("Problem reading $filename");
    };
}

unless (caller) {
    my $proc = Term::ReadLine::Perl5::Demo::Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    if (@ARGV && -r $ARGV[0]) {
	$cmd->run([$NAME, $ARGV[0]]);
    }
}

1;
