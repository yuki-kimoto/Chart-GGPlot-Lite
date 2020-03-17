use Mojolicious::Lite;

system('perl lib/a.pl') == 0
  or die;

app->start;
