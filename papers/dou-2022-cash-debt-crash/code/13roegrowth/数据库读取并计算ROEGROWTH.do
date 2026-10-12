version 18.0
clear all
set more off
* 运行前请cd到本阶段目录。

********************1. 读取数据库中的季度末权益********************
* 保留2006年，用于计算2007年第一季度的环比增长率。
* A为合并报表；仅保留四个季度末，排除1月1日等日期。
csmar_get, table(balancesheet) from(2006) to(2018) report(A) ///
    columns(stock_code report_date report_type a003000000) clear
rename stock_code stock
destring stock, replace
rename a003000000 equity_end
keep if (month(report_date) == 3 & day(report_date) == 31) ///
    | (month(report_date) == 6 & day(report_date) == 30) ///
    | (month(report_date) == 9 & day(report_date) == 30) ///
    | (month(report_date) == 12 & day(report_date) == 31)
keep stock report_date equity_end
isid stock report_date
label variable equity_end "季度末所有者权益合计（元）"
save "季度末权益_数据库.dta", replace

********************2. 读取已注册ROE作为核对字段*******************
* f050501b是累计净利润/期末权益，不直接用于单季度环比增长。
csmar_get, table(profitability) from(2006) to(2018) report(A) ///
    columns(stock_code report_date report_type source f050501b) clear
keep if source == 0
rename stock_code stock
destring stock, replace
rename f050501b ROE_cum_db
keep if (month(report_date) == 3 & day(report_date) == 31) ///
    | (month(report_date) == 6 & day(report_date) == 30) ///
    | (month(report_date) == 9 & day(report_date) == 30) ///
    | (month(report_date) == 12 & day(report_date) == 31)
keep stock report_date ROE_cum_db
isid stock report_date
label variable ROE_cum_db "数据库ROE A：累计净利润/期末权益"
save "累计ROE_数据库.dta", replace

********************3. 从累计净利润还原单季度净利润***************
use stock accper report_type net_profit using ///
    "../10添加利润表相关控制变量/利润表_全部整理.dta", clear
keep if report_type == "A"
gen double report_date = daily(accper, "YMD")
format report_date %tdCCYY-NN-DD
gen int year = year(report_date)
keep if inrange(year, 2006, 2018)
keep if (month(report_date) == 3 & day(report_date) == 31) ///
    | (month(report_date) == 6 & day(report_date) == 30) ///
    | (month(report_date) == 9 & day(report_date) == 30) ///
    | (month(report_date) == 12 & day(report_date) == 31)
isid stock report_date
rename net_profit net_profit_cum
gen int qdate = qofd(report_date)
format qdate %tq
gen byte quarter = quarter(report_date)
xtset stock qdate

* 第一季度直接取累计净利润；其他季度减去上季度累计值。
* L.遇到季度缺口返回缺失，避免把不相邻季度相减。
gen double net_profit_q = net_profit_cum if quarter == 1
replace net_profit_q = net_profit_cum - L.net_profit_cum if quarter > 1
label variable net_profit_cum "年初至报告期累计净利润（元）"
label variable net_profit_q "单季度净利润（元）"

merge 1:1 stock report_date using "季度末权益_数据库.dta", ///
    keep(master match) gen(equity_merge)
merge 1:1 stock report_date using "累计ROE_数据库.dta", ///
    keep(master match) gen(roe_source_merge)

********************4. 单季度ROE及相邻季度增长率*******************
* 使用合并净利润与合并期末总权益，金额单位相同，无需乘100。
gen double ROE_q = net_profit_q / equity_end ///
    if equity_end > 0 & !missing(equity_end)
gen double ROE_cum_check = net_profit_cum / equity_end ///
    if equity_end > 0 & !missing(equity_end)
gen double ROE_cum_diff = ROE_cum_check - ROE_cum_db
xtset stock qdate
gen double ROEGROWTH_q = (ROE_q - L.ROE_q) / L.ROE_q ///
    if !missing(ROE_q, L.ROE_q) & L.ROE_q != 0
label variable ROE_q "单季度净利润/季度末总权益"
label variable ROE_cum_diff "累计ROE核对差额：本地利润表计算值减数据库值"
label variable ROEGROWTH_q "相邻季度ROE增长率（保留负基期，零基期缺失）"

* 先完成跨年滞后计算，再截取研究年份。
keep if inrange(year, 2007, 2018)
save "ROEGROWTH_季度明细.dta", replace

********************5. 汇总公司年度ROEGROWTH**********************
* 按用户选择取季度增长率平均；egen mean忽略缺失值。
* 保留有效季度数与完整标记，供之后统一确定样本，不在此剔除。
bysort stock year: egen double ROEGROWTH = mean(ROEGROWTH_q)
bysort stock year: egen byte ROEGROWTH_Nquarter = count(ROEGROWTH_q)
gen byte ROEGROWTH_complete = ROEGROWTH_Nquarter == 4
bysort stock year (qdate): keep if _n == 1
keep stock year ROEGROWTH ROEGROWTH_Nquarter ROEGROWTH_complete
label variable ROEGROWTH "年度季度ROE增长率平均值（有效季度均值）"
label variable ROEGROWTH_Nquarter "年度有效季度ROE增长率数量"
label variable ROEGROWTH_complete "年度四个季度增长率均有效"
isid stock year
save "ROEGROWTH_公司年度.dta", replace

********************6. 合并到已有控制变量主表*********************
use "../12添加市场化指数/添加Index.dta", clear
isid stock year
local master_N = _N
merge 1:1 stock year using "ROEGROWTH_公司年度.dta", ///
    keep(master match) ///
    keepusing(ROEGROWTH ROEGROWTH_Nquarter ROEGROWTH_complete) ///
    gen(ROEGROWTH_merge)
assert _N == `master_N'
isid stock year
tabulate ROEGROWTH_Nquarter, missing
count if missing(ROEGROWTH)
summarize ROEGROWTH, detail
save "添加ROEGROWTH.dta", replace
* 原主表不覆盖；不剔除控制变量缺失记录、不缩尾。
