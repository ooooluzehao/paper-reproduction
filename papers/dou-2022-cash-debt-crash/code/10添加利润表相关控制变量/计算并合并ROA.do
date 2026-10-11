clear all
set more off
* 请先cd到本篇code/10添加利润表相关控制变量，再运行此do。

********************1. 提取年度合并报表净利润*********************
use stock year month day report_type net_profit if_correct ///
    using "利润表_全部整理.dta", clear

* A为合并报表；12月31日净利润为全年利润，不是第四季度单季利润。
keep if report_type == "A"
keep if month == 12 & day == 31
keep if inrange(year, 2007, 2018)

* 净利润使用net_profit，不直接替换为归母净利润。
* 保留差错更正标记，暂不根据if_correct删除公司年份。
keep stock year net_profit if_correct
isid stock year
sort stock year
save "净利润_年度合并.dta", replace

********************2. 匹配同年年末总资产，计算ROA****************
use stock year total_assets using ///
    "../05处理资产负债表数据/资产负债表.dta", clear
keep if inrange(year, 2007, 2018)
isid stock year

merge 1:1 stock year using "净利润_年度合并.dta", ///
    keep(master match) keepusing(net_profit if_correct) gen(ROA_profit_merge)
tab ROA_profit_merge, missing

* 依据论文正文：净利润/总资产；此处用同年合并报表年末总资产。
* 不采用平均总资产；单位均为元，无须另乘100或换算。
* 亏损公司ROA可以为负，不删除负净利润；资产非正或缺失则不计算。
gen double ROA = net_profit / total_assets ///
    if !missing(net_profit, total_assets) & total_assets > 0

label variable net_profit "同年合并利润表全年净利润（元）"
label variable ROA "同年合并净利润/年末总资产"
label variable ROA_profit_merge "总资产与净利润匹配结果：1仅资产，3匹配"

isid stock year
sort stock year
count if missing(ROA)
summarize ROA, detail
save "ROA_公司年度.dta", replace

********************3. 合并到已有Size、GROWTH、Ret数据************
use "../09添加控制变量/添加Ret.dta", clear
isid stock year

* 解释变量year匹配解释变量year，不使用下一年risk_year。
* 不改变已有total_assets，不引入同名财务字段覆盖。
* 保留原核心样本，包括暂时缺少ROA的记录，最终统一检查缺失。
merge 1:1 stock year using "ROA_公司年度.dta", ///
    keep(master match) keepusing(ROA net_profit if_correct) gen(ROA_merge)

tab ROA_merge, missing
count if missing(ROA)
summarize Size GROWTH Ret ROA
isid stock year
save "添加ROA.dta", replace
