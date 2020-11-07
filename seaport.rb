#!/usr/bin/env ruby

require 'tk'
=begin
 For Ubuntu 20.04
 sudo apt install tk-dev
 sudo gem install tk -- --with-tcltkversion=8.6 \
 --with-tcl-lib=/usr/lib/x86_64-linux-gnu \
 --with-tk-lib=/usr/lib/x86_64-linux-gnu \
 --with-tcl-include=/usr/include/tcl8.6 \
 --with-tk-include=/usr/include/tcl8.6 \
 --enable-pthread
=end

$root = TkRoot.new { title 'seaport (aswd, space to reset, esc to quit)'  }
$root.bind("Key", proc{|e| on_key(e) })
$canvas = TkCanvas.new($root,
                      'width'=>800, 'height'=>600, 
                      'background'=>'blue') {
    pack  { }
}
$vector_forward = TkcLine.new($canvas, 0, 115, 100, 115, 'width' => 2, 'arrow' => "last")
$vector_backward = TkcLine.new($canvas, 0, 105, 100, 105, 'width' => 2, 'arrow' => "last")
$seaport = TkcPolygon.new($canvas,100,100, 130,100, 140,110, 130,120, 100,120,'outline'=>'black','width'=>1,:fill=>'blue')
$thrust_display = TkcRectangle.new($canvas, 0,0,18,100)
$rudder_display = TkcRectangle.new($canvas, 20,0,38,100)
$thrust_middle = TkcLine.new($canvas, 0, 50, 18, 50)
$rudder_middle = TkcLine.new($canvas, 20, 50, 38, 50)
$thrust_indicator = TkcLine.new($canvas, 0, 50, 12, 50, 'arrow' => "last")
$rudder_indicator = TkcLine.new($canvas, 20, 50, 32, 50, 'arrow' => "last")


=begin

An implementation of a boat model with drag and thrust (forward/reverse)
and rudder, similar to Ports of Call.

The velocity vector is divided into v_f (in the forward direction)
and v_b (the backward direction). v = v_f + v_b

The seaport can of course turn, but to simplify the calculations the
vector doesn't turn. Instead we keep track of the angle the seaport
is turning separately in angle.

=end

$go = true
$step = false

# The boat position
$x = 400
$y = 300
$angle = 0.0
$cosa=1
$sina=0
# The velocity vector
$v_f = 0
$v_b = 0
# Drag
$drag_k = 0.01
# Thrust
$thrust = 0
# Rudder
$rudder = 0

def update_seaport
    # we only update if go or step mode
    return if !$go && !$step
    $step = false

    # decode thrust control (divide into forward/backward thrust)
    thrust_f = ($thrust > 0 ? $thrust : 0)
    thrust_b = ($thrust < 0 ? -$thrust : 0)

    # calculate new forward velocity
    if thrust_f > 0 or $v_f > 0 then
        drag = -$drag_k*$v_f*$v_f
        acc = thrust_f + drag
        $v_f = $v_f + acc
        $v_f = 0 if $v_f < 0.9
    end

    # calculate new backward velocity
    if thrust_b > 0 or $v_b > 0 then
        drag = -$drag_k*$v_b*$v_b
        acc = thrust_b + drag
        $v_b = $v_b + acc
        $v_b = 0 if $v_b < 0.9
    end

    # the total velocity
    v = $v_f - $v_b

    # update position using the angle the velocity
    $x = $x + $cosa*v
    $y = $y - $sina*v

    # update angle using rudder position + velocity
    if $rudder != 0 then
        a = ($rudder * v) / 1000
        $angle += a

        # normalize the angles
        $angle = $angle + 6.28 if $angle < -6.28
        $angle = $angle - 6.28 if $angle > 6.28

        # precalculate the trig values
        $cosa = Math.cos($angle)
        $sina = Math.sin($angle)
    end

    # draw seaport and controls
    draw_seaport
end

def on_key(event)
    case event.keysym
    when '1'
        $x = 400
        $y = 300
        $v_f = 0
        $v_b = 0
        $angle=0
        $rudder=0
        $thrust=0
        $go = true
    when '2'
        $x = 400
        $y = 300
        $v_f = 0
        $v_b = 0
        $rudder=0
        $thrust=0
        $angle=0.78
        $go = true
    when '3'
        $x = 400
        $y = 300
        $v_f = 0
        $v_b = 0
        $rudder=0
        $thrust=0
        $angle=1.57
        $go = true
    when 'g'
        $go = !$go
        puts $go
    when 'z'
        $go = false
        $step = true
    when 'a'
        $thrust = $thrust - 1 if $thrust > -10
    when 'd'
        $thrust = $thrust + 1 if $thrust < 10
    when 'w'
        $rudder = $rudder + 1 if $rudder < 10
    when 's'
        $rudder = $rudder - 1 if $rudder > -10
    when 'space'
        $thrust = 0
        $rudder = 0
    when 'Escape'
        exit 0
    end
end

def rotate(x,y)
    # around 0,0, then translate to $x,$y
    #a = ((((24*$angle.abs)/6.28).to_i)/24.0)*6.28
    #_x = x * Math.cos(a) + y * Math.sin(a)
    #_y = y * Math.cos(a) - x * Math.sin(a)
    _x = x * $cosa + y * $sina
    _y = y * $cosa - x * $sina
    return [_x + $x, _y + $y]
end

def draw_seaport
    # Draw seaport
    c = rotate(-20,-10)+rotate(10,-10)+rotate(20,0)+rotate(10,10)+rotate(-20,10)
    $canvas.coords($seaport, c)

    # Draw velocity vectors
    s = 5 # vector scaling
    $canvas.coords($vector_forward, [$x,$y,$x+s*$cosa*$v_f,$y-s*$sina*$v_f])
    $canvas.coords($vector_backward, [$x,$y,$x-s*$cosa*$v_b,$y+s*$sina*$v_b])

    # draw thrust display
    y = 50- 5 * $thrust
    $canvas.coords($thrust_indicator, [0, y, 12, y])

    # draw rudder display
    y = 50 + 5 * $rudder
    $canvas.coords($rudder_indicator, [20, y, 32, y])
end


my_timer = TkTimer.new(200, -1, proc {update_seaport})
my_timer.start
Tk.mainloop
