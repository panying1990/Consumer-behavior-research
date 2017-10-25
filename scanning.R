# _author_ = panying
# 模块目的：对线上消费者情况进行全景扫描
# 最后编辑时间："2017-10-25"
# Sys.Date()

# 软件环境================================================================
# 将R语言程序环境更新到最新状态
library(stringr)
library(installr)
updateR()

# 数据环境================================================================ 
# 从分析专用库中读取基础数据
library(DBI)
library(RMySQL)

# 数据库环境设置
conn1<-dbConnect(MySQL(),dbname="data_check",host="192.168.111.251",username="root",password="P#y20bsy17")
dbSendQuery(conn1,"SET NAMES gbk")

# 读取文本数据
dir<-getwd()
setwd(dir)
mas_fristdrug_data2<-read.csv('mas_fristdrug_data2.csv')

names(mas_fristdrug_data2)[1]<-"出库月"


dbSendQuery(conn1,"DROP table mas_fristdrug_data2")
dbListTables(conn1)  
dbWriteTable(conn1,"mas_fristdrug_data2",mas_fristdrug_data2)

# 全景扫描-时间机会========================================================
library("dplyr")
mkt_scan_read<-dbSendQuery(conn1, "SELECT * from mkt_scan_brand")
mkt_scan_brand<-dbFetch(mkt_scan_read,-1)

# 保健食品行业
mkt_scan_tmallsum<-filter(mkt_scan_brand, channel_name == "天猫" & substr(year_mon,1,4) == 2017)
mkt_scan_tmallsum<-mutate(mkt_scan_tmallsum, brand_ratio = round(100*chan_bran_sale/industry_sale,2))

# 碧生源时间机会
mkt_scan_brandsum<-filter(mkt_scan_brand, channel_name == "天猫" & substr(year_mon,1,4) == 2017 & brand_name == "碧生源")
mkt_scan_brandsum<-mutate(mkt_scan_tmallsum, brand_ratio = round(100*chan_bran_sale/industry_sale,2))


# 全景扫描-数据可视化========================================================
library(sp)
library(maptools)
library(ggplot2)
library(plyr)
library(maps)
library(mapdata)
# 传统的地图调用使用google地图，国内比较特殊，故此处调用百度地图完成可视化地图的绘制
library(REmap)
library(baidumap)
set.seed(125)  
out = remap(demoC,title = "REmap",subtitle = "theme:Dark")  
plot(out) 


geoData  = get_geo_position(unique(demoC[demoC==demoC]))  
remapB(markLineData = demoC,geoData = geoData) 

data = data.frame(country = mapNames("world"),  
                  value = 5*sample(178)+200)  
out = remapC(data,maptype = "world",color = 'skyblue')  
plot(out) 

# 绘制热力图
pk_cities <- mapNames("中国")
pk_cities_Geo <- get_geo_position(pk_cities)
percent <- runif(17,min=0.25,max = 0.9)
data_all <- data.frame(pk_cities_Geo[,1:2],percent)
result <- remapH(data_all,
                 maptype = "北京",
                 theme = get_theme("Blue"),
                 blurSize = 35,
                 color = "red",
                 minAlpha = 10,
                 opacity = 1)

# 用户行为========================================
# 其他的图形绘制部分,直接使用Plotly
library(stats)
library(plotly)



# 购物篮分析========================================

# author:panying
# 本代码块用于解决用户关联规则算法 
# 设置工作路径及工作环境
workdir<-getwd()
if(!is.null(workdir))
  setwd(workdir)

library(Matrix)
library(arules)
#通过统一处理将数据转为为交易数据形式
groceries <- read.transactions("groceries.csv", sep = ",") 
#导入数据 data
library(DBI)
library(RMySQL)
conn<-dbConnect(MySQL(),dbname="tag_explore",host="192.168.111.251",username="root",password="P#y20bsy17")
dbSendQuery(conn,"SET NAMES gbk")
# read_data<-dbSendQuery(conn, "SELECT * from kd_trade_brusher180")
# kd_trade_brusher<-dbFetch(read_data,-1)

#检查数据类型
summary(groceries)
inspect(groceries[1:5])

# 检查数据集中各产品的支持度情况
itemFrequency(groceries[, 1:3])

#数据集中不同产品支持度可视化
#1.支持度>0.1的的产品可视化
itemFrequencyPlot(groceries, support = 0.1)
#2.支持度排名前20的可视化
itemFrequencyPlot(groceries, topN = 20)
#3.可视化交易数据-绘制稀疏矩阵
image(groceries[1:25])
#4.随机抽样进行交易数据可视化
image(sample(groceries, 100))

#第三步：基于数据训练模型
apriori(groceries)


# 根据需要调试支持度、置信度、交易包含项
# 支持度support：某产品在交易集中出现的频率；
# 置信度confidence: 类似条件概率
# 交易订单项目：一般设置为>=2;
groceryrules <- apriori(groceries, parameter = list(support = 0.006, confidence = 0.25, minlen = 2))


#第四步：评估规则
summary(groceryrules)
inspect(groceryrules[1:5])

#第五步：提高模型性能
# 根据提升度情况，逐一检查规则的使用性
inspect(sort(groceryrules, by = "lift")[1:5],decreasing=FALSE)
# 将符合某一产品来源的规则进行检查
berryrules <- subset(groceryrules, items %in% "berries")
inspect(berryrules)


# 将规则以CSV格式进行输出
write(groceryrules, file = "groceryrules.csv",sep = ",", quote = TRUE, row.names = FALSE)

# 将规则作为数据框的格式进行输出
groceryrules_df <- as(groceryrules, "data.frame")
str(groceryrules_df)

#将数据写入到目标数据库方便之后做进一步整合
dbListTables(conn)  
dbWriteTable(conn,"groceryrules_df",groceryrules_df)  
dbListTables(conn)
