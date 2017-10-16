-- author_ = panying
-- 模块目的：对线上消费者情况进行全景扫描
-- 最后编辑时间："2017-10-16"

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
 CONCAT(LEFT(tt.年月,4),"-",RIGHT(tt.年月,2),"-01") AS year_mon,
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
 CONCAT(LEFT(tt.年月,4),"-",RIGHT(tt.年月,2),"-01") AS year_mon,
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
