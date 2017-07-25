require 'capybara'
require 'capybara/dsl'
include Capybara::DSL

Capybara.javascript_driver = :selenium
Capybara.current_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

# 中華民國專利資訊檢索系統 首頁
url = "http://twpat2.tipo.gov.tw/tipotwoc/tipotwkm"
visit(url)

# 進入 簡易檢索 頁面
find('ul#css3menu1 li.topmenu:nth-child(3) a').click
sleep(3)

# 找出專利公開日在 2016/1/1~2017/1/1 之間的所有專利
# 年：1950 ~ 2017
y_min, m_min, d_min = '2016', '01', '01'
y_max, m_max, d_max = '2017', '01', '01'
find_field('_1_2_r_0_4').find("option[value='#{y_min}']").click
find_field('_1_2_r_4_2').find("option[value='#{m_min}']").click
find_field('_1_2_r_6_2').find("option[value='#{d_min}']").click
find_field('_1_2_r_8_4').find("option[value='#{y_max}']").click
find_field('_1_2_r_12_2').find("option[value='#{m_max}']").click
find_field('_1_2_r_14_2').find("option[value='#{d_max}']").click
# 將所有 專利欄位 打勾
patent_fields = all('table.TERM_0_11_S input')
patent_fields.each do |patent_field|
  patent_field.set(true)
end
# 每頁顯示筆數：10/20/30/40/50/100
@items_per_page = 20
find_field('_0_7_o_1').find("option[value='#{@items_per_page}']").click
# 開始搜尋
page.execute_script("document.getElementsByName('_IMG_檢索2%m')[0].click()")
sleep(3)

def print_Patents()
  # 列印所有專利資料
  patents = all('tr.sumtr1')
  patents.each_with_index do |patent, index|
    _no = index + 1 + (@p_page - 1) * @items_per_page
    puts "-- No. #{_no} ------------------------"
    puts "專利編號：" + patent.find('td.sumtd2_PN a').text
    # puts "專利名稱：" + patent.find('td.sumtd2_TI').text
    # puts "申請日：" + patent.find('td.sumtd2_AD').text
    # puts "國際分類號/IPC：" + patent.find('td.sumtd2_IC').text
    # puts "設計分類號/LOC：" + patent.find('td.sumtd2_IQ').text
    # puts "發明人：" + patent.find('td.sumtd2_IV').text
    # puts "申請人：" + patent.find('td.sumtd2_PA').text
    # puts "參考文獻：" + patent.find('td.sumtd2_CI').text
    # puts "專利權始日：" + patent.find('td.sumtd2_ID').text
    # puts "專利權止日：" + patent.find('td.sumtd2_ID').text
  end
end

def get_CurrentPage()
  # 抓取到的內容："1/12462"，使用 Regex 可分為 目前頁數 / 總頁數
  pages = find("td.content font[style='color:red']:nth-child(3)").text
  current_page = pages.split("/")[0]
  puts "============ 第 #{current_page} 頁 ============="
end

# 抓取到的內容："1/12462"，使用 Regex 可分為 目前頁數 / 總頁數
pages = find("td.content font[style='color:red']:nth-child(3)").text.split("/")
current_page = pages[0]   # scan()：Regex global
puts "第 #{current_page} 頁"
all_page = pages[1]
puts "共 #{all_page} 頁"

@p_page = 1
print_Patents()

# 爬到各分頁的專利資料
print_pages = 2
print_pages--   # 前面已做一次，所以要先 -1
i = 1
while i < print_pages do
# while i < all_page - 1 do
  page.execute_script("document.getElementsByName('_IMG_次頁')[0].click()")
  sleep(2)
  get_CurrentPage()
  @p_page += 1
  print_Patents()
  i += 1
end
