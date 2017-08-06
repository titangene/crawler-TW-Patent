require 'capybara'

@time_ary = []
@time_AVG = 0

def _sleep(t, t_max, css)
  time = 0
  while !page.has_selector?(css) do
    sleep(t)
    time += t
    puts "#{css} - Zzz... #{time} sec"
    break if time > t_max
  end

  if time > t_max
    puts "Sleep more than #{t_max} seconds to stop the crawler"
    exit
  end
end

def _sleep_has_content(t, t_max, css, content)
  time = 0
  while !page.has_selector?(css) && find(css).text.include?(content) do
    sleep(t)
    time += t
    puts "#{css} - Zzz... #{time} sec"
    break if time > t_max
  end

  if time > t_max
    puts "Sleep more than #{t_max} seconds to stop the crawler"
    exit
  end
end

def time_diff(start_time, end_time, save)
  _time = (start_time - end_time).abs.floor
  @time_ary << _time if save

  time_format(_time)
end

def time_format(_time)
  minutes, seconds = _time.divmod(60)
  seconds = seconds.floor
  hours, minutes = minutes.divmod(60)
  days, hours = hours.divmod(24)
  months, days = days.divmod(30.4)
  days = days.floor
  weeks, days = days.divmod(7)

  "#{months}M #{weeks}w #{days}d #{hours}h #{minutes}m #{seconds}s"
end

def getCrawler_page_AVG_time()
  @time_ary.each do |_time|
    @time_AVG += _time
  end
  
  _time_AVG = @time_AVG / @time_ary.count
  time_format(_time_AVG)
end