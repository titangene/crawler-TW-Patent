require 'capybara'
require 'capybara/dsl'
include Capybara::DSL

Capybara.javascript_driver = :selenium
Capybara.current_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

# 中華民國專利資訊檢索系統 首頁
url = "http://twpat2.tipo.gov.tw/tipotwoc/tipotwkm"
visit(url)

# 進入 簡易檢索 頁面
find('ul#css3menu1 li.topmenu:nth-child(3) a').click
sleep(3)