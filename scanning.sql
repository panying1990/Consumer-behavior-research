-- author_ = panying
-- 模块目的：对线上消费者情况进行全景扫描
-- 最后编辑时间："2017-10-17"

-- 全景扫描-外部市场-品牌======================================
USE data_check;
DROP TABLE
IF EXISTS mkt_scan_brand;
CREATE TABLE mkt_scan_brand AS
SELECT
 tt.year_mon,
 tt.channel_name,
 tt.brand_name,
 tt.chan_bran_num,
 tt.chan_bran_sale,
 tt.price_per,
 tl.industry_sale
FROM
(SELECT
 TRIM(CONCAT(LEFT(tt.年月,4),"-",RIGHT(tt.年月,2),"-01")) AS year_mon,
 tt.`渠道` AS channel_name,
 tt.品牌名称 AS brand_name,
 SUM(tt.`销售额`) AS chan_bran_sale,
 SUM(tt.`销量`) AS chan_bran_num,
 ROUND(SUM(tt.`销售额`)/SUM(tt.`销量`),1) AS price_per
FROM
master_data.monitor_industry_data tt
GROUP BY
 year_mon,
 channel_name,
 brand_name
HAVING
 ROUND(LEFT(year_mon,4),0)>2015
ORDER BY
 year_mon DESC,
 channel_name,
 chan_bran_sale)tt
LEFT JOIN
(SELECT -- 保健食品行业销售额
 TRIM(CONCAT(LEFT(tt.年月,4),"-",RIGHT(tt.年月,2),"-01")) AS year_mon,
 tt.`渠道` AS channel_name,
 tt.品牌名称 AS brand_name,
 tt.销售额 AS brand_sale,
 ROUND(LEFT(tt.销售额行业占比,4),2) AS brand_sale_ratio,
 ROUND(100*ROUND(tt.销售额)/ROUND(LEFT(tt.销售额行业占比,4),2),1) AS industry_sale
 FROM
 master_data.monitor_industry_data tt
 WHERE
 tt.品牌名称="BY－HEALTH/汤臣倍健"
 AND
 LEFT(tt.年月,4)>2015)tl
ON CONCAT(tt.year_mon,tt.channel_name)=CONCAT(tl.year_mon,tl.channel_name);

-- 全景扫描-内部市场-品牌======================================




-- 全景扫描-地域分布-基础数据
USE data_check;
SET @sys_customer_index = ROUND((SELECT MAX(sys_customer_id) FROM crm_kd.kd_customer),0);
DROP TABLE 
IF EXISTS customer_data_city;
CREATE TABLE customer_data_city AS
SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount
FROM
(
(SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.develop_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-01"
ORDER BY
 tt.develop_time DESC)
UNION
(SELECT
 @sys_customer_index:= @sys_customer_index+1 AS sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 MIN(tt.develop_time) AS develop_time,
 MIN(tt.order_pay_time) AS first_pay_time,
 MAX(tt.order_pay_time) AS last_pay_time,
 COUNT(DISTINCT order_id) AS pay_times,
 SUM(tt.order_pay_amount) AS pay_amount
FROM
(SELECT
 tt.`用户名` AS out_nick,
 tt.`订单ID辅助列` AS order_id,
 tt.`收货人` AS customer_name,
 tt.`收货人电话` AS mobile,
 tt.`收货省份` AS province,
 tt.`收货城市` AS city,
 DATE_FORMAT(tt.`下单时间`,"%Y-%m-%d %h:%m:%s") AS develop_time,
 DATE_FORMAT(tt.`付款时间`,"%Y-%m-%d %h:%m:%s") AS order_pay_time,
 ROUND(tt.GMV,1) AS order_pay_amount,
 "46" AS plat_from_type
FROM
 master_data.mas_fristdrug_data2 tt
WHERE 
 tt.`用户名`<> 'N')tt
GROUP BY
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type
ORDER BY
 pay_times DESC))tt;

-- 地域分布


-- 消费者行为研究$产品偏好度-文本分析


SELECT
 t1.sys_customer_id,
 t1.address,
 t1.develop_time,
 t2.shop_name
FROM
 crm_kd.kd_customer t1,crm_kd.kd_customer_ext  t2
WHERE
 t1.sys_customer_id = t2.sys_customer_id
AND t1.sys_customer_id IN
(SELECT
 tt.sys_customer_id
FROM
 crm_kd.kd_customer tt
WHERE
 tt.plat_from_type = 40 
AND MONTH(tt.develop_time)>7);




-- 消费者行为研究$购物篮分析-关联规则

SELECT
 t1.sys_customer_id,
 t1.address,
 t1.develop_time,
 t2.shop_name
FROM
 crm_kd.kd_customer t1,crm_kd.kd_customer_ext  t2
WHERE
 t1.sys_customer_id = t2.sys_customer_id
AND t1.sys_customer_id IN
(SELECT
 tt.sys_customer_id
FROM
 crm_kd.kd_customer tt
WHERE
 tt.plat_from_type = 40 
AND MONTH(tt.develop_time)>7);
