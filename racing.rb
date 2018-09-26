# config
def supports_emoji? 
  true
end
#end config

class Racer
  attr_reader :acceleration, :top_speed, :current_speed, :distance_traveled

  def initialize(acceleration, top_speed)
    @acceleration = acceleration.to_f
    @top_speed = top_speed.to_f
    @current_speed = 0.0
    @distance_traveled = 0.0
  end

  def move(time)
    # vf = vi + a * t
    # t = (vf - vi) / a
    time_to_top_speed = (@top_speed - @current_speed) / @acceleration
    # split time between time with constant acceleration and time with constant speed
    if time_to_top_speed < time
      top_speed_time = time - time_to_top_speed
      acc_time = time_to_top_speed
      @current_speed = @top_speed
    else
      top_speed_time = 0
      acc_time = time
      # vf = vi + a * t
      @current_speed += (acceleration * acc_time)
    end
    # d = vi * t + 0.5 * a * t**2
    @distance_traveled += (@current_speed * acc_time) + (0.5 * @acceleration * acc_time**2)
    @distance_traveled += @top_speed * top_speed_time
  end
end

def clear
  puts "\e[H\e[2J"
end

def race(racers, term_width=80, finish_char="|")
  scale = 200
  finish_line_chars = term_width - 4
  finish_line = finish_line_chars * scale
  tick = 0
  until racers.any?{|_,racer| racer.distance_traveled >= finish_line} do
    #clear terminal
    puts "\e[H\e[2J"
    racers.each do |name, racer|
      if tick >= 10
        racer.move(1)
      end
      distance_chars = (racer.distance_traveled.to_i / scale)
      print " " * distance_chars
      print name
      if distance_chars < finish_line_chars
        print " " * (finish_line_chars - distance_chars)
        print finish_char
      end
      puts
    end
    if tick < 10
      tick += 1
      print "Place your bets..."
      puts 11 - tick
      sleep 1
    end
    sleep 0.1
  end
  return racers.max_by{|_,r| r.distance_traveled}[0]
end

if supports_emoji?
  entrants = ["🐌","🐢","🐇","🐖","🐕","🐈","🐒","🐎","🐪","🐘"]
  finish_line = "🏁"
else
  entrants = ["a","b","c","d","e","f","g","h","i","j"]
  finish_line = "|"
end

racers = entrants.map { |r|
  [r, Racer.new(rand(5..25), rand(300..600))]
}.to_h

winner = race(racers, 80, finish_line)

puts "The winner is #{winner}"
  