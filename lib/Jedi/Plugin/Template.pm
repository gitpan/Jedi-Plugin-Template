#
# This file is part of Jedi-Plugin-Template
#
# This software is copyright (c) 2013 by celogeek <me@celogeek.com>.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package Jedi::Plugin::Template;

# ABSTRACT: Jedi Plugin for Template Toolkit

use strict;
use warnings;

our $VERSION = '0.04';    # VERSION

use Import::Into;
use Module::Runtime qw/use_module/;

use B::Hooks::EndOfScope;

sub import {
    my $target = caller;
    on_scope_end {
        $target->can('with')->('Jedi::Plugin::Template::Role');
    };
    return;
}

1;

__END__

=pod

=head1 NAME

Jedi::Plugin::Template - Jedi Plugin for Template Toolkit

=head1 VERSION

version 0.04

=head1 DESCRIPTION

This will add missing route to catch public file if exists.

This will also give a "jedi_template" method to display your template.

To use it in your Jedi app :

	package MyApps;
	use Jedi::App;
	use Jedi::Plugin::Template;

	sub jedi_app {
		...
		$jedi->get('/bla', sub {
			my ($jedi, $request, $response) = @_;
			$response->body($jedi->jedi_template('test.tt'), {hello => 'world'}, 'main.tt');
			return 1;
		})
	}

	1;

Here the structure of your app :

	.
	./bin/app.psgi
	./config.yml
	./environments
	./environments/prod.yml
	./views
	./view/test.tt
	./view/layouts/main.tt
	./public

The main.tt look like

	<html>
	<body>
	This will wrap your content :
	
	[% content %]
	</body>
	</html>

And your test.tt :

	<p>Hello [% hello %]</p>

Take a look here : L<Jedi::Plugin::Template::Role>

=head1 METHODS

=head2 import

This module is equivalent into your package to :

	package MyApps;
	with "Jedi::Plugin::Template::Role";

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://tasks.celogeek.com/projects/perl-modules-jedi

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

celogeek <me@celogeek.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by celogeek <me@celogeek.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
