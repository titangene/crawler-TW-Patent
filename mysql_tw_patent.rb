require 'mysql2'

MYSQL_OPTIONS = {
  :host     => 'localhost', # 主機
  :username => 'root',      # 使用者名稱
  :password => 'titan',     # 密碼
  :database => 'tw_patent', # 資料庫
  :encoding => 'utf8'       # 編碼
}

@insertSQL = "insert into crawler(id, name, application_date, 
announcement_date, application_id, IPC, LOC, bulletin_period, inventor, applicant, 
agent, priority, reference, summary, patent_start_date, patent_stop_date) 
values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, null, null)"

@selectSQL = "select id from crawler where id=?"

@updateSQL = "update crawler set name=? ,application_date=? ,announcement_date=? 
,application_id=? ,IPC=? ,LOC=? ,bulletin_period=? ,inventor=? ,applicant=? ,agent=? 
,priority=? ,reference=? ,summary=? where id=?"

def mySQL_Prepare()
  mysql_db = Mysql2::Client.new(MYSQL_OPTIONS)

  @db_insert = mysql_db.prepare(@insertSQL)
  @db_select = mysql_db.prepare(@selectSQL)
  @db_update = mysql_db.prepare(@updateSQL)
end