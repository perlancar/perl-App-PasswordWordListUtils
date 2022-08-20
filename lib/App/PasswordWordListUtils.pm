package App::PasswordWordListUtils;

use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{exists_in_password_wordlist} = {
    v => 1.1,
    summary => 'Check that string(s) match(es) word in a password wordlist',
    description => <<'_',

Password wordlist is one of WordList::* modules, without the prefix.

Since many password wordlist uses bloom filter, that means there's a possibility
of false positive (e.g. 0.1% chance; see each password wordlist for more
details).

_
    args => {
        wordlist => {
            schema => 'perl::wordlist::modname*',
            cmdline_aliases => {w=>{}},
            default => 'Password::10Million::Top1000000',
        },
        strings => {
            schema => ['array*', of=>'str*', min_len=>1],
            'x.name.is_plural' => 1,
            'x.name.singular' => 'string',
            req => 1,
            pos => 0,
            slurpy => 1,
            cmdline_src => 'stdin_or_args',
        },
        quiet => {
            schema => 'bool*',
            cmdline_aliases => {q=>{}},
        },
    },

    links => [
        {
            url => 'prog:wordlist',
            summary => 'wordlist 0.267+ also has -t option to test words against wordlists, so you can use it directly',
        },
    ],
};
sub exists_in_password_wordlist {
    require WordListUtil::CLI;

    my %args = @_;
    my $strings = $args{strings};

    my $wl = WordListUtil::CLI::instantiate_wordlist($args{wordlist});

    if (@$strings == 1) {
        my $exists = $wl->word_exists($strings->[0]);
        [200, "OK", $exists, {
            'cmdline.exit_code' => $exists ? 0:1,
            'cmdline.result' => $args{quiet} ? '' : "String ".($exists ? "most probably exists" : "DOES NOT EXIST")." in the wordlist",
        }];
    } else {
        my @rows;
        for (@$strings) {
            push @rows, {string=>$_, exists=>$wl->word_exists($_) ? 1:0};
        }
        [200, "OK", \@rows, {'table.fields'=>['string','exists']}];
    }
}

1;
# ABSTRACT: Command-line utilities related to checking string against password wordlists

=for Pod::Coverage .+

=head1 SYNOPSIS

This distribution provides the following command-line utilities:

#INSERT_EXECS_LIST


=head1 DESCRIPTION


=head1 SEE ALSO

C<WordList::Password::*> modules, e.g.
L<WordList::Password::10Million::Top1000000>.

=cut
