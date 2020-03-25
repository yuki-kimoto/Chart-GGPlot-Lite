use strict;
use warnings;

use Imager;
use Imager::Color;
use Math::Spline;
use Math::Trig 'pi';
use FindBin;

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
  
  # Create canvas
  my $image_width = 1400;
  my $image_height = 600;
  my $img = Imager->new(xsize => $image_width, ysize => $image_height, channels => 4);
  
  # Drow white background
  my $color_white = Imager::Color->new(255, 255, 255);
  $img->box(color => $color_white, xmin => 0, ymin => 0, xmax => $image_width, ymax => $image_height, filled => 1);
  
  my $x_unit = $image_width / 100;
  my $y_unit = $image_height / 100;
  
  my $axis_min_x = $x_unit * 5;
  my $axis_min_y = ($image_height - $y_unit * 10);
  my $axis_max_x = ($image_width - $x_unit * 20);
  my $axis_max_y = $y_unit * 5;
  
  my $jiku_color = Imager::Color->new('#ccc');
  
  $img->polyline(points=>[[$axis_min_x, $axis_min_y], [$axis_min_x, $axis_max_y], [$axis_max_x, $axis_max_y], [$axis_max_x, $axis_min_y], [$axis_min_x, $axis_min_y]], color => $jiku_color);

  $img->polyline(points=>[[$axis_min_x + $x_unit * 5, $axis_min_y], [$axis_min_x + $x_unit * 5, $axis_max_y]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x + $x_unit * 10, $axis_min_y], [$axis_min_x + $x_unit * 10, $axis_max_y]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x + $x_unit * 15, $axis_min_y], [$axis_min_x + $x_unit * 15, $axis_max_y]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x + $x_unit * 20, $axis_min_y], [$axis_min_x + $x_unit * 20, $axis_max_y]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x + $x_unit * 25, $axis_min_y], [$axis_min_x + $x_unit * 25, $axis_max_y]], color => $jiku_color);

  $img->polyline(points=>[[$axis_min_x, $axis_min_y - $y_unit * 5], [$axis_max_x, $axis_min_y - $y_unit * 5]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x, $axis_min_y - $y_unit * 10], [$axis_max_x, $axis_min_y - $y_unit * 10]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x, $axis_min_y - $y_unit * 15], [$axis_max_x, $axis_min_y - $y_unit * 15]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x, $axis_min_y - $y_unit * 20], [$axis_max_x, $axis_min_y - $y_unit * 20]], color => $jiku_color);
  $img->polyline(points=>[[$axis_min_x, $axis_min_y - $y_unit * 25], [$axis_max_x, $axis_min_y - $y_unit * 25]], color => $jiku_color);
  
  # add circle
  my $point_color = Imager::Color->new('#70aeff');
  
  my $rows = [
    {x => 101, y => 201},
    {x => 131, y => 205},
    {x => 121, y => 210},
    {x => 131, y => 215},
    {x => 141, y => 221},
    {x => 151, y => 215},
    {x => 161, y => 231},
    {x => 171, y => 240},
  ];
  
  my $memori_range = 2;
  
  my $x_max;
  my $x_min;
  my $y_max;
  my $y_min;
  
  for my $row (@$rows) {
    my $x = $row->{x};
    my $y = $row->{y};
    
    if (!defined $x_max || $x > $x_max) {
      $x_max = $x;
    }
    if (!defined $x_min || $x < $x_min) {
      $x_min = $x;
    }
    if (!defined $y_max || $y > $y_max) {
      $y_max = $y;
    }
    if (!defined $y_min || $y < $y_min) {
      $y_min = $y;
    }
  }
  my $x_range = $x_max - $x_min;
  my $y_range = $y_max - $y_min;
  
  use POSIX();

  sub log10 {
    my $x = shift;
    return log($x) / log(10);
  }
  
  sub GetAxisStep
  {
    my ($value) = @_;
    
    my $exponent = 10 ** POSIX::floor(log10($value));
    my $significand = $value / $exponent;

    my $axisStep;
    if ($significand < 1.5)
    {
        $axisStep = 0.2 * $exponent;
    }
    elsif ($significand < 3.5)
    {
        $axisStep = 0.5 * $exponent;
    }
    elsif ($significand <= 5.0)
    {
        $axisStep = 1.0 * $exponent;
    }
    else
    {
        $axisStep = 2.0 * $exponent;
    }
    return $axisStep;
  }

=pod
目盛り間隔は 
1
,
2
,
5
 の3通り、あるいはその 
10
 倍や 
100
 倍、
1
/
10
 倍や 
1
/
100
 倍などだけである。（3刻みや7刻みで数字が増えていく目盛りは（ほとんど）存在しない。）
 
 数値を伴った目盛りは最低でも2つ必要である。（もし数字の添えられた目盛りが1つまたは0であると、グラフの描かれた範囲がどれくらいの大きさであるのか判断できなくなってしまうので）
 
=cut

  for my $row (@$rows) {
    my $x = $row->{x};
    my $y = $row->{y};
    $img->circle(color => $point_color, r => 4, x => $x, y => $y, aa => 1);
  }
  
  my $font_file = "$FindBin::Bin/DejaVuSans.ttf";
  my $font = Imager::Font->new(file => $font_file) or die;

  # 軸目盛を書き込み
  $img->string(
      x => 130,
      y => 560,
      string => "0.2",
      utf8 => 1,
      font => $font,
      size => 15,
      aa => 1,
      color => '#333',
  ) or die;
  $img->string(
      x => 200,
      y => 560,
      string => "0.4",
      utf8 => 1,
      font => $font,
      size => 15,
      aa => 1,
      color => '#333',
  ) or die;

  $img->string(
      x => 40,
      y => 515,
      string => "300",
      utf8 => 1,
      font => $font,
      size => 15,
      aa => 1,
      color => '#333',
  ) or die;

  $img->string(
      x => 40,
      y => 485,
      string => "350",
      utf8 => 1,
      font => $font,
      size => 15,
      aa => 1,
      color => '#333',
  ) or die;

  $img->string(
      x => 500,
      y => 23,
      string => "Sanpuzu",
      utf8 => 1,
      font => $font,
      size => 28,
      aa => 1,
      color => '#333',
  ) or die;
  
  my $axis_separate_count = 7;
  
  my $step = GetAxisStep($x_range);

  my $x_min_axis = $step * int($x_min / $step) - $step;
  my $x_max_axis = $step * int($x_max / $step) + $step * 2;
  
  my $x_axis_sep_count = $x_max_axis - $x_min_axis;
  
  use D;du [$x_min_axis, $x_max_axis, $x_min, $x_max, $step];

  $self->{imager} = $img;
}

sub save {
  my ($self) = @_;
  
  my $img = $self->{imager};
  
  $img->write( file => 'public/a.png', jpegquality => 90 )
    or die $img->errstr;
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
