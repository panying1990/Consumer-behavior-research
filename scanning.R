# _author_ = panying
# 模块目的：对线上消费者情况进行全景扫描
# 最后编辑时间："2017-10-16"
# Sys.Date()

# 数据环境================================================================ 
library(DBI)
library(RMySQL)

# 数据库环境设置
conn1<-dbConnect(MySQL(),dbname="data_check",host="192.168.111.251",username="root",password="P#y20bsy17")
dbSendQuery(conn1,"SET NAMES gbk")
