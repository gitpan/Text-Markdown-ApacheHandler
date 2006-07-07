package Text::Markdown::ApacheHandler;

use strict;
use warnings;

=head1 NAME

Text::Markdown::ApacheHandler - Processes files with Markdown syntax for Apache

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Apache::Constants qw(:common);
use Apache::File ();
use CGI qw(:standard);
use Text::Markdown 'markdown';

=head1 SYNOPSIS

Processes files containing Markdown syntax into HTML files and serves them.

	AddHandler text/markdown .markdown
	AddHandler text/markdown .md
	AddHandler text/markdown .mhtml
	<Files ~ "\.(markdown|md|mhtml)$">
		SetHandler perl-script
		PerlHandler Text::Markdown::ApacheHandler
	</Files>

=head1 METHODS

=over 4

=item handler

Standard Apache module entry point

=cut

sub handler {
	my $r = shift;
	$r->send_http_header;
	my $file = $r->filename;

	unless (-e $r->finfo) {
		$r->log_error("File does not exist: $file");    
		return NOT_FOUND;
	}
	unless (-r _) {
		$r->log_error("File permissions deny access: $file");
		return FORBIDDEN;
	}

	my $modtime = localtime((stat _)[9]);

	my $fh;
	unless ($fh = Apache::File->new($file)) {
		$r->log_error("Couldn't open $file for reading: $!");
		return SERVER_ERROR;
	}
	my $content = do { local $/; <$fh> };
	my ($title) = $file =~ m#/([^/]+?)(?:\.[^./]+)?$#;
	$r->print(
		start_html($title),
		markdown($content),
		end_html
		);
	return OK;
}

=back

=head1 AUTHOR

Darren Kulp, C<< <darren at kulp.ch> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-text-markdown-apachehandler at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Markdown-ApacheHandler>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Markdown::ApacheHandler

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Markdown-ApacheHandler>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Markdown-ApacheHandler>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Markdown-ApacheHandler>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Markdown-ApacheHandler>

=back

=head1 TODO

Tests. I haven't yet looked into how to do tests for an Apache module like
this; I want to do them more for the experience than the necessity, since there
is practically nothing in this module.

=head1 ACKNOWLEDGEMENTS

The excellent L<Text::Markdown> module and its author, and "Writing Apache
Modules with Perl and C" by Lincoln Stein and Doug MacEachern.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Darren Kulp, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Text::Markdown::ApacheHandler

__END__

