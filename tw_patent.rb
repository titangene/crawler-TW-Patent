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

# 找出專利公開日在 2016/1/1~2017/1/1 之間的所有專利
# 年：1950 ~ 2017
find_field('_1_2_r_0_4').find("option[value='2016']").click
find_field('_1_2_r_4_2').find("option[value='01']").click
find_field('_1_2_r_6_2').find("option[value='01']").click
find_field('_1_2_r_8_4').find("option[value='2017']").click
find_field('_1_2_r_12_2').find("option[value='01']").click
find_field('_1_2_r_14_2').find("option[value='01']").click
# 將所有 專利欄位 打勾
patent_fields = all('table.TERM_0_11_S input')
patent_fields.each do |patent_field|
  patent_field.set(true)
end
# 每頁顯示筆數：10/20/30/40/50/100
find_field('_0_7_o_1').find("option[value='20']").click
# 開始搜尋
page.execute_script("document.getElementsByName('_IMG_檢索2%m')[0].click()")
sleep(3)