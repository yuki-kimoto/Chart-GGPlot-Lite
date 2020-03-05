use strict;
use warnings;

use Imager;
use Imager::Color;
use Math::Spline;
use Math::Trig 'pi';

package Chart::GGPlot::Lite;

sub new {
  my ($class, @args) = @_;
  
  my $self = {
    @args,
  };
  
  return bless $self, ref $class || $class;
}

sub draw {
  my ($self) = @_;
  
  my $image_width = 1400;
  my $image_height = 600;
  
  my $x_unit = $image_width / 100;
  my $y_unit = $image_height / 100;
  
  my $axis_min_x = $x_unit * 5;
  my $axis_min_y = ($image_height - $y_unit * 10);
  my $axis_max_x = ($image_width - $x_unit * 20);
  my $axis_max_y = $y_unit * 5;
  
  my $imager = Imager->new(xsize => $image_width, ysize => $image_height, channels => 4);
  
  $imager->box(color => Imager::Color->new(255, 255, 255), xmin => 0, ymin => 0, xmax => $image_width, ymax => $image_height, filled => 1);
  
  my $jiku_color = Imager::Color->new('#ccc');
  
  $imager->polyline(points=>[[$axis_min_x, $axis_min_y], [$axis_min_x, $axis_max_y], [$axis_max_x, $axis_max_y], [$axis_max_x, $axis_min_y], [$axis_min_x, $axis_min_y]], color => $jiku_color);

  $imager->polyline(points=>[[$axis_min_x + $x_unit * 5, $axis_min_y + 10], [$axis_min_x + $x_unit * 5, $axis_max_y]], color => $jiku_color);
  $imager->polyline(points=>[[$axis_min_x + $x_unit * 10, $axis_min_y + 10], [$axis_min_x + $x_unit * 10, $axis_max_y]], color => $jiku_color);
  $imager->polyline(points=>[[$axis_min_x + $x_unit * 15, $axis_min_y + 10], [$axis_min_x + $x_unit * 15, $axis_max_y]], color => $jiku_color);
  $imager->polyline(points=>[[$axis_min_x + $x_unit * 20, $axis_min_y + 10], [$axis_min_x + $x_unit * 20, $axis_max_y]], color => $jiku_color);
  $imager->polyline(points=>[[$axis_min_x + $x_unit * 25, $axis_min_y + 10], [$axis_min_x + $x_unit * 25, $axis_max_y]], color => $jiku_color);

  $self->{imager} = $imager;
}

sub save {
  my ($self) = @_;
  
  my $imager = $self->{imager};
  
  $imager->write( file => 'public/graph.png', jpegquality => 90 )
    or die $imager->errstr;
}

package main;

my $infos = [];
while (my $line = <DATA>) {
  next if $. == 1;
  
  chomp $line;
  my @items = split(/\t/, $line);
  my $info = {
    sepal_length => $items[0],
    sepal_width => $items[1],
    petal_length => $items[2],
    petal_width => $items[3],
    species => $items[4],
  };
  
  push @$infos, $info;
}

=pod
ggplot($infos, [aes(x => sepal_length, y => sepal_width), geom_point, geom_smooth, theme_bw]);

my $ggplot = Chart::GGPlot::List->new(data => $infos);
$ggplot->aes(x => sepal_length, y => sepal_width);
$ggplot->geom_point();
$ggplot->gem_smooth;
$ggplot->theme_bw;

$ggplot->draw;

=cut

use D;du $infos;

#my $x_offset = 250;
#my $y_offset = 250;

my $ggplot = Chart::GGPlot::Lite->new;
$ggplot->draw;
$ggplot->save;

my $scale = 100;

my $min = -pi();
my $max = 2*pi();

my $kannkaku = 0.1;

=pod
my $points = [];
for (my $x = $min; $x < $max; $x += 0.1) {
  my $y = sin($x);
  my $point = [$x * $scale + $x_offset, $y * $scale + $y_offset];
  push @$points, $point;
}
=cut

# my @ys = map { xx($_) } @xs;

# my $spline = Math::Spline->new(\@xs, \@ys);

# my $x = 5;
# my $y = $spline->evaluate($x);

# my $blue = Imager::Color->new( 0, 0, 255 );

# my $fill = Imager::Fill->new(hatch=>'stipple');


# $img->polyline(points => $points, color => $blue, aa => 1);

# $img->flip(dir => 'v');

# Jpeg、画質 90% で保存

__DATA__
Sepal_Length	Sepal_Width	Petal_Length	Petal_Width	Species
5.1	3.5	1.4	0.2	setosa
4.9	3.0	1.4	0.2	setosa
4.7	3.2	1.3	0.2	setosa
7.0	3.2	4.7	1.4	versicolor
6.4	3.2	4.5	1.5	versicolor
6.9	3.1	4.9	1.5	versicolor
6.3	3.3	6.0	2.5	virginica
5.8	2.7	5.1	1.9	virginica
7.1	3.0	5.9	2.1	virginica
