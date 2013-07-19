#!perl
use Test::Most;
use utf8;

use lib qw(t/lib);
use ZapziTestDatabase;

use App::Zapzi;
use App::Zapzi::FetchArticle;
use App::Zapzi::Transform;

test_can();

my ($test_dir, $app) = ZapziTestDatabase::get_test_app();

test_text();
test_html();
done_testing();

sub test_can
{
    can_ok( 'App::Zapzi::Transform',
            qw(raw_article to_readable readable_text) );
}

sub test_text
{
    my $f = App::Zapzi::FetchArticle->new(source => 't/testfiles/sample.txt');
    ok( $f->fetch, 'Fetch text' );
    my $tx = App::Zapzi::Transform->new(raw_article => $f);
    isa_ok( $tx, 'App::Zapzi::Transform' );
    ok( $tx->to_readable, 'Transform sample text file' );
    like( $tx->readable_text, qr/<p>No special formatting/,
          'Contents of text file OK' );
    like( $tx->title, qr/This is a sample text file/, 'Title of text file OK' );
}

sub test_html
{
    my $f = App::Zapzi::FetchArticle->new(source => 't/testfiles/sample.html');
    ok( $f->fetch, 'Fetch HTML' );
    my $tx = App::Zapzi::Transform->new(raw_article => $f);
    isa_ok( $tx, 'App::Zapzi::Transform' );
    ok( $tx->to_readable, 'Transform sample HTML file' );
    like( $tx->readable_text, qr/<h1>Lorem/, 'Contents of HTML file OK' );
    unlike( $tx->readable_text, qr/<script>/,
            'Javascript stripped from HTML file' );
    is( $tx->title, 'Sample “HTML” Document',
        'Title of HTML file OK with entity decoding' );

    # Try an HTML file with no <title>
    $f = App::Zapzi::FetchArticle->new(
        source => 't/testfiles/html-no-title.html');
    ok( $f->fetch, 'Fetch HTML' );
    $tx = App::Zapzi::Transform->new(raw_article => $f);
    isa_ok( $tx, 'App::Zapzi::Transform' );
    ok( $tx->to_readable, 'Transform sample HTML file' );
    like( $tx->title, qr/html-no-title/,
          'Title set for HTML file without <title>' );

    # Try an HTML file with two titles and leading/trailing whitespace
    $f = App::Zapzi::FetchArticle->new(
        source => 't/testfiles/html-two-titles.html');
    ok( $f->fetch, 'Fetch HTML with two title tags' );
    $tx = App::Zapzi::Transform->new(raw_article => $f);
    isa_ok( $tx, 'App::Zapzi::Transform' );
    ok( $tx->to_readable, 'Transform sample HTML file' );
    is( $tx->title, 'Title 1',
        'Title selected from HTML extract with two title tags');
}
