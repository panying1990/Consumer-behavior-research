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
conn1<-dbConnect(MySQL(),dbname="data_check",host="8888888888888888",username="88888",password="888888888")
dbSendQuery(conn1,"SET NAMES gbk")

# 处理1药网数据
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


# 用户-地域分布-消费者渗透
dbSendQuery(conn1,"SET NAMES gbk")
user_province_read<-dbSendQuery(conn1, "SELECT * from user_province_test")
user_province_test<-dbFetch(user_province_read,-1)

# 用户-地域分布-区域分布
dbSendQuery(conn1,"SET NAMES gbk")
shop_province_read<-dbSendQuery(conn1, "SELECT * from user_province_shop")
shop_province_test<-dbFetch(shop_province_read,-1)

# 用户-地域分布-客单价分布
dbSendQuery(conn1,"SET NAMES gbk")
price_province_read<-dbSendQuery(conn1, "SELECT * from user_province_price")
price_province_test<-dbFetch(price_province_read,-1)

# 三茶-地域分布-消费者渗透
dbSendQuery(conn1,"SET NAMES gbk")
santea_province_read<-dbSendQuery(conn1, "SELECT * from santea_user_province")
santea_user_province<-dbFetch(santea_province_read,-1)

# 三茶-地域分布-区域分布
dbSendQuery(conn1,"SET NAMES gbk")
santea_shop_read<-dbSendQuery(conn1, "SELECT * from santea_province_shop")
santea_province_shop<-dbFetch(santea_shop_read,-1)

# 三茶-地域分布-客单价分布
dbSendQuery(conn1,"SET NAMES gbk")
santea_price_read<-dbSendQuery(conn1, "SELECT * from santea_province_price")
santea_province_price<-dbFetch(santea_price_read,-1)


# 新产品-地域分布-消费者渗透
dbSendQuery(conn1,"SET NAMES gbk")
newproduct_province_read<-dbSendQuery(conn1, "SELECT * from newproduct_user_province")
newproduct_user_province<-dbFetch(newproduct_province_read,-1)

# 新产品-地域分布-区域分布
dbSendQuery(conn1,"SET NAMES gbk")
newproduct_shop_read<-dbSendQuery(conn1, "SELECT * from newproduct_province_shop")
newproduct_province_shop<-dbFetch(newproduct_shop_read,-1)

# 新产品-地域分布-客单价分布
dbSendQuery(conn1,"SET NAMES gbk")
newproduct_price_read<-dbSendQuery(conn1, "SELECT * from newproduct_province_price")
newproduct_province_price<-dbFetch(newproduct_price_read,-1)

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

# 主题设置
theme_province<-get_theme(theme = "Sky", lineColor = "#080808",backgroundColor = "#080808", titleColor = "#080808",
          borderColor = "#080808", regionColor = "#080808")


# 获得现有全部百度地图中所有城市的经纬度，
zhejiang_city<- mapNames("zhejiang")
zhejiang_city<-get_geo_position(zhejiang_city)


# 碧生源品牌地域机会-消费者渗透：	0,100,0
province_user <- data.frame(user_province_test[,1],user_province_test[,5])
names(province_user)<-c("province","user_per")
province_user$user_per[province_user$user_per>70]<-61
remapC(province_user,color=c("#006400"),theme = theme_province,title="2016年01月-2017年09月全国分省用户数分布",subtitle="用户数(人)/十万人",mindata = 12,maxdata=61)

# 碧生源品牌地域机会-区域分布：255,69,0
shop_province <- data.frame(shop_province_test[,1],shop_province_test[,5])
names(shop_province)<-c("province","user_per_shop")
shop_province$user_per_shop[shop_province$user_per_shop<1]<-0
remapC(shop_province,color=c("#FF4500"),theme = theme_province,title="2016年01月-2017年09月全国分省用户数分布",subtitle="单店覆盖用户数(人)/店",mindata = 0,maxdata=18)

# 碧生源品牌地域机会-客单价：	0,191,255
price_province <- data.frame(price_province_test[,1],price_province_test[,5])
names(price_province)<-c("province","user_price")
price_province$user_price[price_province$user_price>205|price_province$user_price<140]<-0
remapC(price_province,color=c("#00BFFF"),theme = theme_province,title="2016年01月-2017年09月全国分省用户数分布",subtitle="用户平均付款总额",mindata = 149,maxdata=200)

# 三茶地域机会-消费者渗透：	0,100,0
santea_province<- data.frame(santea_user_province[,1],santea_user_province[,5])
names(santea_province)<-c("province","user_per")
santea_province$user_per[santea_province$user_per>100]<-100
remapC(santea_province,color=c("#006400"),theme = theme_province,title="2016年01月-2017年09月全国分省三茶用户分布",subtitle="三茶用户占比（%）",mindata = 77,maxdata=91)


# 三茶地域机会-区域分布：255,69,0
santea_shop<- data.frame(santea_province_shop[,1],santea_province_shop[,5])
names(santea_shop)<-c("province","user_per_shop")
santea_shop$user_per_shop[santea_shop$user_per_shop<1]<-0
remapC(santea_shop,color=c("#FF4500"),theme = theme_province,title="2016年01月-2017年09月全国分省三茶用户数分布",subtitle="单店覆盖用户数(人)/店",mindata = 0,maxdata=15)

# 三茶地域机会-客单价：	0,191,255
santea_price <- data.frame(santea_province_price[,1],santea_province_price[,5])
names(santea_price)<-c("province","user_price")
santea_price$user_price[santea_price$user_price>230|santea_price$user_price<160]<-0
remapC(santea_price,color=c("#00BFFF"),theme = theme_province,title="2016年01月-2017年09月全国分省三茶用户数分布",subtitle="用户平均付款总额",mindata = 167,maxdata=227)


# 新产品地域机会-消费者渗透：	0,100,0
newproduct_user <- data.frame(newproduct_user_province[,1],newproduct_user_province[,5])
names(newproduct_user)<-c("province","user_per")
newproduct_user$user_per[newproduct_user$user_per>70]<-70
remapC(newproduct_user,color=c("#006400"),theme = theme_province,title="2016年01月-2017年09月全国分省新产品用户数分布",subtitle="用户数(人)/十万人",mindata = 0,maxdata=25)


# 新产品地域机会-区域分布：255,69,0
newproduct_shop<- data.frame(newproduct_province_shop[,1],newproduct_province_shop[,5])
names(newproduct_shop)<-c("province","user_per_shop")
newproduct_shop$user_per_shop[newproduct_shop$user_per_shop<1]<-0
remapC(newproduct_shop,color=c("#FF4500"),theme = theme_province,title="2016年01月-2017年09月全国分省新产品用户数分布",subtitle="单店覆盖用户数(人)/店",mindata = 0,maxdata=13)

# 新产品地域机会-客单价：	0,191,255
newproduct_price <- data.frame(newproduct_province_price[,1],newproduct_province_price[,5])
names(newproduct_price)<-c("province","user_price")
newproduct_price$user_price[newproduct_price$user_price>240|newproduct_price$user_price<110]<-0
remapC(newproduct_price,color=c("#00BFFF"),theme = theme_province,title="2016年01月-2017年09月全国分省新产品用户数分布",subtitle="用户平均付款总额",mindata = 110,maxdata=240)



# 各区域情况
# 用户-浙江分布-消费者渗透
dbSendQuery(conn1,"SET NAMES gbk")
zhejiang_read<-dbSendQuery(conn1, "SELECT * from user_zhejiang_test")
user_zhejiang_test<-dbFetch(zhejiang_read,-1)

# 浙江分布-消费者渗透：	0,100,0
zhejiang_user <- data.frame(user_zhejiang_test[,2],user_zhejiang_test[,5])
names(zhejiang_user)<-c("city","user_per")
zhejiang_user$user_per[zhejiang_user$user_per>70]<-70
remapC(zhejiang_user,maptype = 'zhejiang',color=c("#006400"),theme = theme_province,title="2016年01月-2017年09月浙江省用户分布",subtitle="用户数(人)/十万人",mindata = 0,maxdata=61)

# 用户-浙江分布-药店覆盖率
dbSendQuery(conn1,"SET NAMES gbk")
zhejiang_shop_read<-dbSendQuery(conn1, "SELECT * from user_zhejiang_shop")
user_zhejiang_shop<-dbFetch(zhejiang_shop_read,-1)

# 浙江分布-区域分布：255,69,0
zhejiang_shop<- data.frame(user_zhejiang_shop[,2],user_zhejiang_shop[,5])
names(zhejiang_shop)<-c("city","user_per_shop")
zhejiang_shop$user_per_shop[zhejiang_shop$user_per_shop<1]<-0
remapC(zhejiang_shop,maptype = 'zhejiang',color=c("#FF4500"),theme = theme_province,title="2016年01月-2017年09月浙江省用户分布",subtitle="单店覆盖用户数(人)/店",mindata = 0,maxdata=22)

# 用户-浙江分布-客单价
dbSendQuery(conn1,"SET NAMES gbk")
zhejiang_price_read<-dbSendQuery(conn1, "SELECT * from user_zhejiang_price")
user_zhejiang_price<-dbFetch(zhejiang_price_read,-1)

# 用户-浙江分布-客单价：	0,191,255
zhejiang_price <- data.frame(user_zhejiang_price[,2],user_zhejiang_price[,5])
names(zhejiang_price)<-c("city","user_price")
zhejiang_price$user_price[zhejiang_price$user_price>240|zhejiang_price$user_price<110]<-0
remapC(zhejiang_price,maptype = 'zhejiang',color=c("#00BFFF"),theme = theme_province,title="2016年01月-2017年09月浙江省用户分布",subtitle="用户平均付款总额",mindata = 149,maxdata=200)


# 三茶-浙江分布-客单价
dbSendQuery(conn1,"SET NAMES gbk")
zhejiang_santea_read<-dbSendQuery(conn1, "SELECT * from santea_user_zhejiang")
santea_user_zhejiang<-dbFetch(zhejiang_santea_read,-1)

# 三茶-浙江分布-消费者渗透：	0,100,0
santea_zhejiang<- data.frame(santea_user_zhejiang[,2],santea_user_zhejiang[,5])
names(santea_zhejiang)<-c("city","user_ratio")
santea_zhejiang$user_ratio[santea_zhejiang$user_ratio>100]<-100
remapC(santea_zhejiang,maptype = 'zhejiang',color=c("#006400"),theme = theme_province,title="2016年01月-2017年09月浙江省三茶用户分布",subtitle="三茶用户占比（%）",mindata = 85.6,maxdata=91)

# 三茶-浙江分布-客单价
dbSendQuery(conn1,"SET NAMES gbk")
santea_zjpr_read<-dbSendQuery(conn1, "SELECT * from santea_zhejiang_price")
santea_zhejiang_price<-dbFetch(santea_zjpr_read,-1)

# 三茶-浙江分布-客单价：	0,191,255
santea_zjpr <- data.frame(santea_zhejiang_price[,2],santea_zhejiang_price[,5])
names(santea_zjpr)<-c("city","user_price")
santea_zjpr$user_price[santea_zjpr$user_price>310|santea_zjpr$user_price<110]<-0
remapC(santea_zjpr,maptype = 'zhejiang',color=c("#00BFFF"),theme = theme_province,title="2016年01月-2017年09月浙江省三茶用户分布",subtitle="用户平均付款总额",mindata = 167,maxdata=227)

