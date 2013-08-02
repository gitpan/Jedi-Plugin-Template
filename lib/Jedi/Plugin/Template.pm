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

use Moo::Role;
our $VERSION = '0.01';    # VERSION
use Template;
use Path::Class;
use feature 'state';
use MIME::Types qw/by_suffix/;
use Carp qw/croak/;

# This part is for handle the public subdir
# It catch all files from path info and send it if the file exists
# It stop the road trip if a file is found to avoid any other routes to be executed
# They is no cache here, use an engine like nginx to speed up that process.

before 'jedi_app' => sub {
    my ($jedi) = @_;

    $jedi->get( qr{.*}x, $jedi->can('_jedi_dispatch_public_files') );

    return;
};

sub _jedi_dispatch_public_files {
    my ( $jedi, $request, $response ) = @_;
    my $file
        = file( $jedi->jedi_app_root, 'public', $request->env->{PATH_INFO} );
    return 1 if !-f $file;

    my ( $mime_type, $encoding ) = by_suffix($file);
    my $type    = $mime_type . '; charset=' . $encoding;
    my $content = $file->slurp();

    $response->status(200);
    $response->set_header( 'Content-Type', $type );
    $response->body($content);

    return;
}

has '_jedi_template_views' => ( is => 'lazy' );

sub _build__jedi_template_views {
    my ($jedi) = @_;
    return dir( $jedi->jedi_app_root, 'views' );
}

has 'jedi_template_default_layout' => ( is => 'rw' );

sub jedi_template {
    my ( $jedi, $file, $vars, $layout ) = @_;
    $layout //= $jedi->jedi_template_default_layout;
    $layout = 'none' if !defined $layout;

    my $layout_file;
    if ( $layout ne 'none' ) {
        $layout_file
            = file( $jedi->_jedi_template_views, 'layouts', $layout );
        if ( !-f $layout_file ) {
            $layout      = 'none';
            $layout_file = undef;
        }
    }

    state $cache = {};
    if ( !exists $cache->{$layout} ) {
        my @tpl_options = (
            INCLUDE_PATH => [ $jedi->_jedi_template_views ],
            ABSOLUTE     => 1,
        );

        if ( $layout ne 'none' ) {
            push @tpl_options, WRAPPER => $layout_file->stringify;
        }

        $cache->{$layout} = Template->new(@tpl_options);
    }

    my $tpl_engine = $cache->{$layout};
    my $view_file = file( $jedi->_jedi_template_views, $file );

    my $ret = "";
    $tpl_engine->process( $view_file->stringify, $vars, \$ret )
        or croak $tpl_engine->error();

    return $ret;
}

1;

__END__

=pod

=head1 NAME

Jedi::Plugin::Template - Jedi Plugin for Template Toolkit

=head1 VERSION

version 0.01

=head1 DESCRIPTION

This will add missing route to catch public file if exists.

This will also give a "jedi_template" method to display your template.

To use it in your Jedi app :

	package MyApps;
	use Jedi::App;
	with 'Jedi::Plugin::Template';

	sub jedi_app {
		...
		$response->body($jedi->jedi_template('test.tt'));
	}

	1;

=head1 ATTRIBUTES

=head2 jedi_template_default_layout

if you want to set a default layout, use this attribute.

	$jedi->jedi_template_default_layout('main.tt');

=head1 METHODS

=head2 jedi_template

This method will use L<Template> to process your template.

	$jedi->jedi_template($file, $vars);
	$jedi->jedi_template($file, $vars, $layout);

The layout use the jedi_template_default_layout by default.
You can also remove any layout, using the value "none".

The file is a file inside the subdir "views". The subdir "views" is located on the root of your apps, in
the same directory than the "config.*".

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
