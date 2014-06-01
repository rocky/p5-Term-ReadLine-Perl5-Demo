# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Array::Columnize;
use Pod::Text::Color;

package Term::ReadLine::Perl5::Demo::Cmd::help;

use rlib '../lib';
use Term::ReadLine::Perl5::Demo::Cmd;
use Term::ReadLine::Perl5::Demo::CmdProc qw(complete_token);

unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 0;      # Need at least this many
use constant MAX_ARGS  => undef;  # Need at most this many - undef -> unlimited.
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

B<help> [I<command|regular-expression> | *]

=head2 Examples:

    help help  # Run help on the help command (this output)
    help       # Give basic help instructions
    help *     # Give a list of commands
    help re.*  # list all comands that start re

=cut
HELP

sub complete($$)
{
    my ($self, $prefix) = @_;
    my $proc = $self->{proc};
    my @candidates = ('*', $self->command_names());
    my @matches = complete_token(\@candidates, $prefix);
    sort @matches;
}

sub command_names($)
{
    my ($self) = @_;
    my $proc = $self->{proc};
    my %cmd_hash = %{$proc->{commands}};
    my @commands = sort keys %cmd_hash;
    return @commands;
}

sub help2podstring($)
{
    my ($input_string) = @_;
    my $width = ($ENV{'COLUMNS'} || 80);

    my $p2t = Pod::Text::Color->new(width => $width, indent => 2, utf8=>1);
    my $output_string;
    open(my $out_fh, '>', \$output_string);
    open(my $in_fh, '<', \$input_string);

    $input_string = "=pod\n\n$input_string" unless
        "=pod\n" eq substr($input_string, 0, 4);
    $input_string .= "\n=cut\n" unless
        "\n=cut\n" eq substr($input_string, -6);
    $p2t->parse_from_file($in_fh, $out_fh);
    return $output_string;
}

sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $cmd_name = $args->[1];
    if (scalar(@$args) > 1) {
        my $real_name;
        if ($cmd_name eq '*') {
            $proc->section("All currently valid command names:");
            my @cmds = $self->command_names();
	    $proc->msg(Array::Columnize::columnize(\@cmds,
						   {displaywidth => $proc->{num_cols},
						    colsep => '  ',
						   }));
        } else {
            my $cmd_obj = $proc->{commands}{$cmd_name};
	    if ($cmd_obj) {
		my $help_text =
		    $cmd_obj->can('help') ? $cmd_obj->help($args)
		    : $cmd_obj->{help};
		if ($help_text) {
		    $help_text = help2podstring($help_text);
		    chomp $help_text; chomp $help_text;
		    print $help_text, "\n";
		}
	    } else {
		my @cmds = $self->command_names();
		my @matches = grep(/^${cmd_name}/, @cmds);
		if (!scalar @matches) {
		    $proc->errmsg("No commands found matching /^${cmd_name}/. Try \"help\".");
		} else {
		    $proc->msg("Command names matching /^${cmd_name}/:");
		    $proc->msg(Array::Columnize::columnize(\@matches,
							   {displaywidth => $proc->{num_cols},
							    colsep => '  ',
							   }));
		}
	    }
        }
    } else {
        $proc->msg("Enter help * for a list of commands");
	$proc->msg("or help <command> for help on a particular command.");
    }
}

unless (caller) {
    require Term::ReadLine::Perl5::Demo::CmdProc;
    my $proc = Term::ReadLine::Perl5::Demo::CmdProc->new;
    $proc->{num_cols} = 30;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
    print '-' x 30, "\n";
    $cmd->run([$NAME, '*']);
    print '-' x 30, "\n";
    $cmd->run([$NAME, 'help']);
}

1;
