# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
# A command processor. This includes is a manager for the commands
use strict; use warnings;
use Exporter;
use Array::Columnize;
use File::Basename;
use Term::ReadKey;

package Term::ReadLine::Perl5::Demo::CmdProc;
use Data::Printer;

use English qw( -no_match_vars );

use Term::ReadLine::Perl5;
use rlib '../lib';
use Term::ReadLine::Perl5::Demo::Cmd;
use Term::ReadLine::Perl5::Demo::Complete;
use Term::ReadLine::Perl5::Demo::Load;

my ($num_cols,$num_rows) =  Term::ReadKey::GetTerminalSize(\*STDOUT);

# Return true if arg is 'on' or 1 and false arg is 'off' or 0.
# Any other value is returns undef.
sub get_onoff($$;$$)
{
    my ($self, $arg, $default, $print_error) = @_;
    $print_error = 1 unless defined $print_error;
    unless (defined $arg) {
        unless (defined $default) {
            if ($print_error) {
                $self->errmsg("Expecting 'on', 1, 'off', or 0. Got nothing.");
                return undef;
            }
        }
        return $default
    }
    my $darg = lc $arg;
    return 1 if ($arg eq '1') || ($darg eq 'on');
    return 0 if ($arg eq '0') || ($darg eq'off');

    $self->errmsg("Expecting 'on', 1, 'off', or 0. Got: ${arg}.") if
        $print_error;
    return undef;
}

# Check that we meet the criteria that cmd specifies it needs
sub ok_for_running ($$$$) {
    my ($self, $cmd, $name, $nargs) = @_;
    # TODO check execution_set against execution status.
    # Check we have frame is not null
    my $min_args = eval { $cmd->MIN_ARGS } || 0;
    if ($nargs < $min_args) {
        my $msg =
            sprintf("Command '%s' needs at least %d argument(s); " .
                    "got %d.", $name, $min_args, $nargs);
        $self->errmsg($msg);
        return 0;
    }
    my $max_args = eval { $cmd->MAX_ARGS };
    if (defined($max_args) && $nargs > $max_args) {
        my $mess =
            sprintf("Command '%s' needs at most %d argument(s); " .
                    "got %d.", $name, $max_args, $nargs);
        self->errmsg($mess);
        return 0;
    }

    return 1;
}

sub new($$) {
    my($class, $term)  = @_;
    my $self = {
	num_cols => $num_cols,
        class    => $class,
	term     => $term,
    };
    bless $self, $class;
    $self->load_cmds_initialize;
    my @command_list = sort keys %{$self->{commands}};
    $self->{command_list} = \@command_list;
    $self;
}

sub msg($$) {
    my ($self, $msg) = @_;
    print "$msg\n";
}

sub errmsg($$) {
    my ($self, $msg) = @_;
    print "** $msg\n";
}

sub section($$) {
    my ($self, $msg) = @_;
    print "$msg\n";
}

1;
