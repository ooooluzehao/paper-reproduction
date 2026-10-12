version 18.0
clear all
set more off
* 运行前请cd到本阶段目录。

* 使用已经查询保存的数据库ROE A，全年净利润/年末总权益。
use "累计ROE_数据库.dta", clear
keep if month(report_date) == 12 & day(report_date) == 31
gen int year = year(report_date)
keep if inrange(year, 2007, 2018)
rename ROE_cum_db ROE
keep stock year ROE
label variable ROE "年度ROE A：全年合并净利润/年末合并总权益"
isid stock year
save "ROE_公司年度.dta", replace

* 含ROEGROWTH的主表继续保留所有记录及原字段。
use "添加ROEGROWTH.dta", clear
local master_N = _N
isid stock year
merge 1:1 stock year using "ROE_公司年度.dta", ///
    keep(master match) keepusing(ROE) gen(ROE_merge)
assert _N == `master_N'
isid stock year
count if missing(ROE)
save "添加ROE与ROEGROWTH.dta", replace
