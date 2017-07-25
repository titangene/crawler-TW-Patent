require_relative 'common'
require 'capybara/dsl'
require 'pry-byebug'
include Capybara::DSL

Capybara.javascript_driver = :selenium
Capybara.current_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

client = Mysql2::Client.new(OPTIONS)
SQL = "insert into crawler(id, name, application_date, IPC, LOC, 
inventor, applicant, reference, patent_start_date, patent_stop_date) 
values(?, ?, ?, ?, ?, ?, ?, ?, null, null)"
@db_insert = client.prepare(SQL)

print_pages = ARGV[0]   # 爬取頁數
print_pages ||= 1
print_pages = print_pages.to_i

@items_per_page = ARGV[1]   # 每頁顯示筆數
@items_per_page ||= 10
@items_per_page = @items_per_page.to_i

@start_page = ARGV[2]  # 起始爬取頁面
@start_page ||= 1
@start_page = @start_page.to_i

if @items_per_page != 10 && @items_per_page != 20 && @items_per_page != 30 &&
   @items_per_page != 40 && @items_per_page != 50 && @items_per_page != 100
  puts "value 2: Please input items per page (10/20/30/40/50/100), Default: 10"
  exit
end

if print_pages == 1 || @start_page == 1
  puts "value 1: Please input the number of pages printed (optional), Default: 1"
  puts "value 2: Please input items per page (10/20/30/40/50/100), Default: 10"
  puts "value 2: Please input start crawling the page (optional), Default: 1"
end

# 中華民國專利資訊檢索系統 首頁
url = "http://twpat2.tipo.gov.tw/tipotwoc/tipotwkm"
visit(url)

# 進入 簡易檢索 頁面
find('ul#css3menu1 li.topmenu:nth-child(3) a').click
_sleep(3, 21, 'table.TERM_0_11_S')

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
find_field('_0_7_o_1').find("option[value='#{@items_per_page}']").click
# 開始搜尋
page.execute_script("document.getElementsByName('_IMG_檢索2%m')[0].click()")
_sleep(3, 21, 'tr.sumtr1')

def print_Patents()
  # 列印所有專利資料
  patents = all('tr.sumtr1')
  patents.each_with_index do |patent, index|
    _no = index + 1 + (@p_page - 1) * @items_per_page
    _no = "%04d" % _no
    if @start_page <= _no.to_i
      id = patent.find('td.sumtd2_PN a').text
      name = patent.find('td.sumtd2_TI').text
      application_date = patent.find('td.sumtd2_AD').text
      ipc = patent.find('td.sumtd2_IC').text
      loc = patent.find('td.sumtd2_IQ').text
      inventor = patent.find('td.sumtd2_IV').text
      applicant = patent.find('td.sumtd2_PA').text
      reference = patent.find('td.sumtd2_CI').text

      puts "No.#{_no}: #{id}"  # 專利編號

      @db_insert.execute(id, name, application_date, ipc, loc, inventor, 
        applicant, reference)
      
      # puts "專利名稱：" + name
      # puts "申請日：" + application_date
      # puts "國際分類號/IPC：" + IPC
      # puts "設計分類號/LOC：" + LOC
      # puts "發明人：" + inventor
      # puts "申請人：" + applicant
      # puts "參考文獻：" + reference
      # puts "專利權始日：" + patent.find('td.sum').text
      # puts "專利權止日：" + patent.find('td.sum').text
    end
  end
end

def get_CurrentPage()
  # 抓取到的內容："1/12462"，使用 Regex 可分為 目前頁數 / 總頁數
  pages = find("td.content font[style='color:red']:nth-child(3)").text.split("/")
  current_page = pages[0]
  puts "============ 第 #{current_page} 頁 ============="
end

# 設定起始爬取頁面
if @start_page == 1
  _start_page = 1
  @p_page = 1
else
  _page_quotient = @start_page / 100
  _page_remainder = @start_page % 100

  _start_page = (_page_remainder != 0 && _page_remainder < 100) ? 
    _page_quotient + 1 : _page_quotient
  @p_page = _start_page
  # 跳頁
  find('input.jpage').set(_start_page)
  find("td[valign='bottom'] input[title='顯示結果']").click
  sleep(3)
end

# 抓取到的內容："1/12462"，使用 Regex 可分為 目前頁數 / 總頁數
pages = find("td.content font[style='color:red']:nth-child(3)").text.split("/")
all_page = pages[1]
puts "------------ 共 #{all_page} 頁 ------------"

i = _start_page
while i <= print_pages do
# while i < all_page - 1 do
  get_CurrentPage()
  if _start_page <= i
    print_Patents()
  end
  # 下一頁
  @p_page += 1
  page.execute_script("document.getElementsByName('_IMG_次頁')[0].click()")
  sleep(3)
  i += 1
end