#!perl
use Test::Most;
use Test::Output;

use lib qw(t/lib);
use ZapziTestDatabase;

use App::Zapzi;

test_init();

my ($test_dir, $app) = ZapziTestDatabase::get_test_app();

test_list();
test_list_folders();
test_make_folder();
test_delete_folder();
test_show();
test_add();
test_delete_article();
test_publish();
test_help_version();

done_testing();

sub get_test_app
{
    my $dir = $app->zapzi_dir;

    my $clean_app = App::Zapzi->new(zapzi_dir => $dir, test_database => 1);
    return $clean_app;
}

sub test_init
{
    ZapziTestDatabase::test_init();
}

sub test_list
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args('list') }, qr/Inbox/, 'list' );
    ok( ! $app->run, 'list run' );

    stdout_like( sub { $app->process_args(qw(list -f Nonesuch)) },
                 qr/does not exist/, 'list for non-existent folder' );
    ok( $app->run, 'list error run' );
}

sub test_list_folders
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args('list-folders') }, qr/Archive\s+0/,
                 'list-folders' );
    ok( ! $app->run, 'list-folders run' );
}

sub test_make_folder
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args('make-folder') },
                 qr/Need to provide/, 'make-folder with no arg' );
    ok( $app->run, 'make-folder error run' );

    stdout_like( sub { $app->process_args(qw(make-folder Foo)) },
                 qr/Created folder/, 'make-folder one arg' );
    ok( ! $app->run, 'make-folder run' );

    stdout_like( sub { $app->process_args(qw(mkf Bar Baz)) },
                 qr/Baz/, 'mkf two args' );
    ok( ! $app->run, 'mkf run' );

    stdout_like( sub { $app->process_args(qw(md Qux)) },
                 qr/Qux/, 'md' );
    ok( ! $app->run, 'md run' );

    stdout_like( sub { $app->process_args(qw(make-folder Inbox)) },
                 qr/already exists/, 'make-folder for existing folder' );
    ok( ! $app->run, 'make-folder run' );
}

sub test_delete_folder
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args('delete-folder') },
                 qr/Need to provide/, 'delete-folder with no arg' );
    ok( $app->run, 'delete-folder error run' );

    stdout_like( sub { $app->process_args(qw(delete-folder Foo)) },
                 qr/Deleted folder/, 'delete-folder one arg' );
    ok( ! $app->run, 'delete-folder run' );

    stdout_like( sub { $app->process_args(qw(rmf Bar Baz)) },
                 qr/Baz/, 'rmf two args' );
    ok( ! $app->run, 'rmf run' );

    stdout_like( sub { $app->process_args(qw(rd Qux)) },
                 qr/Qux/, 'rd' );
    ok( ! $app->run, 'rd run' );

    stdout_like( sub { $app->process_args(qw(delete-folder Inbox)) },
                 qr/by the system/, 'delete-folder for system folder' );
    ok( ! $app->run, 'delete-folder run' );

    stdout_like( sub { $app->process_args(qw(delete-folder Nonesuch)) },
                 qr/does not exist/, 'delete-folder for non-existent folder' );
    ok( ! $app->run, 'make-folder run' );
}

sub test_show
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args(qw(show 1)) }, qr/Welcome to/,
                 'show' );
    ok( ! $app->run, 'show run' );

    stdout_like( sub { $app->process_args(qw(cat 1)) }, qr/Welcome to/,
                 'cat' );
    ok( ! $app->run, 'cat run' );

    stdout_like( sub { $app->process_args(qw(show)) }, qr/Need to provide/,
                 'show missing article' );
    ok( $app->run, 'show error run' );

    stdout_like( sub { $app->process_args(qw(show 0)) }, qr/Could not/,
                 'show error' );
    ok( $app->run, 'show error run' );
}

sub test_add
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args(qw(add t/testfiles/sample.txt)) },
                 qr/Added article/,
                 'add' );
    ok( ! $app->run, 'add run' );

    stdout_like( sub { $app->process_args(qw(add t/testfiles/sample.html)) },
                 qr/Added article/,
                 'add html' );
    ok( ! $app->run, 'add html run' );

    stdout_like( sub { $app->process_args(qw(add)) },
                 qr/Need to provide/,
                 'add missing article' );
    ok( $app->run, 'add run' );

    stdout_like( sub { $app->process_args(qw(add t/testfiles/nonesuch.txt)) },
                 qr/Could not/,
                 'add error' );
    ok( $app->run, 'add run' );
}

sub test_delete_article
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args(qw(rm 2)) },
                 qr/Deleted article/,
                 'delete article' );
    ok( ! $app->run, 'rm run' );

    stdout_like( sub { $app->process_args(qw(delete)) },
                 qr/Need to provide/,
                 'delete article missing ID' );
    ok( $app->run, 'rm run' );

    stdout_like( sub { $app->process_args(qw(rm 0)) },
                 qr/Could not/,
                 'delete article error' );
    ok( $app->run, 'rm run' );
}

sub test_publish
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args(qw(publish)) },
                 qr/2 articles.*Published/s,
                 'publish' );
    ok( ! $app->run, 'publish run' );

    stdout_like( sub { $app->process_args(qw(publish)) },
                 qr/No articles/,
                 'publish archives OK and rerun gives 0 articles' );
    ok( $app->run, 'publish again run' );

    stdout_like( sub { $app->process_args(qw(publish -f Nonesuch)) },
                 qr/does not exist/,
                 'publish error' );
    ok( $app->run, 'publish error run' );
}

sub test_help_version
{
    my $app = get_test_app();

    stdout_like( sub { $app->process_args(qw(help)) },
                 qr/Shows this help text/s,
                 'help' );

    stdout_like( sub { $app->process_args(qw(version)) },
                 qr/App::Zapzi .* and Perl/s,
                 'version' );

    $app = get_test_app();
    stdout_like( sub { $app->process_args(qw(unknown_command)) },
                 qr/Shows this help text/s,
                 'unknown command shows help' );
}
