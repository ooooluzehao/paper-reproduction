version 18.0
clear all
set more off

* 从12添加市场化指数目录整体运行。
* 第一步省份年度指数，第二步公司年度指数。
do "01构建省份年度指数.do"
do "02补充公司省份并匹配指数.do"
