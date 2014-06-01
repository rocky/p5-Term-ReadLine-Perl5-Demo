# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
# Completion routines.
package Term::ReadLine::Perl5::Demo::CmdProc;

use strict; use warnings; use utf8;
use Exporter;

use vars qw(@ISA @EXPORT); @ISA = qw(Exporter);
@EXPORT = qw(complete_token complete_token_with_next filename_list
             next_token);

my ($_last_line, $_last_start, $_last_end, @_last_return, $_last_token);

sub complete_token($$)
{
    my ($complete_ary, $prefix) = @_;
    my @result = ();
    for my $cmd (@$complete_ary) {
	if (0 == index($cmd, $prefix)) {
	    push @result, $cmd ;
	}
    }
    sort @result;
}

sub complete_token_with_next($$;$)
{
    my ($complete_hash, $prefix, $cmd_prefix) = @_;
    $cmd_prefix ='' if scalar(@_) < 3;
    my $cmd_prefix_len = length($cmd_prefix);
    my @result = ();
    while (my ($cmd_name, $cmd_obj) = each %{$complete_hash}) {
        if  (0 == index($cmd_name, $cmd_prefix . $prefix)) {
            push @result, [substr($cmd_name, $cmd_prefix_len), $cmd_obj]
        }
    }
    sort {$a->[0] cmp $b->[0]} @result;
}

=head3 filename_list

I<filename_list> is from I<Term::ReadLine::readline.pm>:

For use in passing to completion_matches(), returns a list of
filenames that begin with the given pattern.  The user of this
package can set I<$rl_completion_function> to 'rl_filename_list' to
restore the default of filename matching if they'd changed it
earlier, either directly or via I<&rl_basic_commands>.

=cut
sub filename_list(;$$)
{
    my ($pattern, $add_suffix) = @_;
    $pattern = '' unless defined $pattern;
    $add_suffix = 0 unless defined $add_suffix;
    # $pattern = glob($pattern) if substr($pattern, 0, 1) = '~';
    my @files = (<$pattern*>);
    if ($add_suffix) {
        foreach (@files) {
            if (-l $_) {
                $_ .= '@';
            } elsif (-d _) {
                $_ .= '/';
            } elsif (-x _) {
                $_ .= '*';
            } elsif (-S _ || -p _) {
                $_ .= '=';
            }
        }
    }
    return @files;
}

sub next_token($$)
{
    my ($str, $start_pos) = @_;
    my $look_at = substr($str, $start_pos);
    my $strlen = length($look_at);
    return (1, '') if 0 == $strlen;
    my $next_nonblank_pos = $start_pos;
    my $next_blank_pos;
    if ($look_at =~ /^(\s*)(\S+)\s*/) {
        $next_nonblank_pos += length($1);
        $next_blank_pos = $next_nonblank_pos+length($2);
    } elsif ($look_at =~ /^(\s+)$/) {
        return ($start_pos + length($1), '');
    } elsif ($look_at =~/^(\S+)\s*/) {
        $next_blank_pos = $next_nonblank_pos + length($1);
    } else {
        die "Something is wrong in next_token";
    }
    my $token_size = $next_blank_pos - $next_nonblank_pos;
    return ($next_blank_pos, substr($str, $next_nonblank_pos, $token_size));
}

sub next_complete($$$$$)
{
    my($self, $str, $next_blank_pos, $cmd, $last_token) = @_;

    my $token;
    ($next_blank_pos, $token) = next_token($str, $next_blank_pos);
    return () if !$token && !$last_token;
    return () unless defined($cmd);
    return @{$cmd} if ref($cmd) eq 'ARRAY';
    return $cmd->($token) if (ref($cmd) eq 'CODE');

    if ($cmd->can("complete_token_with_next")) {
        my @match_pairs = $cmd->complete_token_with_next($token);
        return () unless scalar @match_pairs;
        if ($next_blank_pos >= length($str)) {
            return map {$_->[0]} @match_pairs;
        } else {
            if (scalar @match_pairs == 1) {
                if ($next_blank_pos == length($str)-1
                    && ' ' ne substr($str, length($str)-1)) {
                    return map {$_->[0]} @match_pairs;
                } elsif ($match_pairs[0]->[0] eq $token) {
                    return $self->next_complete($str, $next_blank_pos,
                                                $match_pairs[0]->[1],
                                                $token);
                } else {
                    return ();
                }
            } else {
                # FIXME: figure out what to do here.
                # Matched multiple items in the middle of the string
                # We can't handle this so do nothing.
                return ();
            }
        }
    } elsif ($cmd->can('complete')) {
        my @matches = $cmd->complete($token);
        return () unless scalar @matches;
        if (substr($str, $next_blank_pos) =~ /\s*$/ ) {
            if (1 == scalar(@matches) && $matches[0] eq $token) {
                # Nothing more to complete.
                return ();
            } else {
                return @matches;
            }
        } else {
            # FIXME: figure out what to do here.
            # Matched multiple items in the middle of the string
            # We can't handle this so do nothing.
            return ();
        }
    } else {
        return ();
    }
}

sub command_completion($$$$$) {
  my ($self, $text, $line, $start, $end) = @_;
  $_last_line  = '' unless defined $_last_line;
  $_last_start = -1 unless defined $_last_start;
  $_last_end   = -1 unless defined $_last_end;
  $_last_token = '' unless defined $_last_token;
  $_last_token = '' unless
      $_last_start < length($line) &&
      0 == index(substr($line, $_last_start), $_last_token);
  my $stripped_line;
  ($stripped_line = $line) =~ s/\s*$//;
  ($_last_line, $_last_start, $_last_end) = ($line, $start, $end);

  my ($next_blank_pos, $token) = next_token($line, 0);
  if (!$token && !$_last_token) {
      @_last_return = @{$self->{command_list}};
      $_last_token = $_last_return[0];
      $_last_line = $line . $_last_token;
      $_last_end += length($_last_token);
      $self->{completions} = \@_last_return;
      return grep(/^$text/, @{$self->{command_list}});
  }
  $token ||= $_last_token;
  my @match_pairs = complete_token_with_next($self->{commands}, $token);
  my $match_hash = {};
  for my $pair (@match_pairs) {
      $match_hash->{$pair->[0]} = $pair->[1];
  }
  if ($next_blank_pos >= length($line)) {
      @_last_return = sort map {$_->[0]} @match_pairs;
      $_last_token = $_last_return[0];
      if (defined($_last_token)) {
	  $_last_line = $line . $_last_token;
	  $_last_end += length($_last_token);
      }
      $self->{completions} = \@_last_return;
      return @_last_return;
  }
  if (scalar(@match_pairs) > 1) {
      # FIXME: figure out what to do here.
      # Matched multiple items in the middle of the string
      # We can't handle this so do nothing.
      return ();
      # return match_pairs.map do |name, cmd|
      #   ["#{name} #{args[1..-1].join(' ')}"]
      # }
  }
  # scalar @match_pairs == 1
  @_last_return = $self->next_complete($line, $next_blank_pos,
				       $match_pairs[0]->[1],
				       $token);

  $self->{completions} = \@_last_return;
  return @_last_return;

}

1;
