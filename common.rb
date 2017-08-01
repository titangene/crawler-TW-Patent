require 'capybara'
require 'mysql2'

OPTIONS = {
  :host     => 'localhost', # 主機
  :username => 'root',      # 使用者名稱
  :password => 'titan',     # 密碼
  :database => 'tw_patent', # 資料庫
  :encoding => 'utf8'       # 編碼
}

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