import excel "STK_LISTEDCOINFOANL.xlsx", sheet("sheet1") firstrow clear
keep 行业代码C 行业名称C 统计截止日期 股票代码 股票简称
rename 股票代码 stock
rename 股票简称 shortname
rename 统计截止日期 accper
rename 行业代码C indcode
rename 行业名称C indname
label variable stock "股票代码"
label variable shortname "股票简称"
label variable accper "原始统计截止日期"
label variable indcode "2012版本行业代码"
label variable indname "2012版本行业名称"
* 证券代码转为数值型
destring stock, replace
* 截取日期前四位，转为数值年份
gen int year = real(substr(accper, 1, 4))
drop if year > 2022
save"公司行业代码"