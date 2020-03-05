use Mojolicious::Lite;

warn "AAAAAAA";

system('perl lib/a.pl') == 0
  or die;

app->start;
