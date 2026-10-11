

import excel "FS_Combas.xlsx", sheet("sheet1") firstrow clear

********************变量重命名********************************
rename 证券代码 stock
rename 证券简称 shortname
rename 统计截止日期 accper
rename 报表类型 report_type
rename 货币资金 cash
rename 应收账款净额 receivables
rename 流动资产合计 current_assets
rename 固定资产净额 fixed_assets
rename 资产总计 total_assets
rename 短期借款 short_debt
rename 流动负债合计 current_liabilities
rename 负债合计 total_liabilities
rename 盈余公积 surplus_reserve
rename 未分配利润 undistributed_profit
rename 归属于母公司所有者权益合计 parent_equity
rename 所有者权益合计 total_equity
label variable stock "证券代码"
label variable shortname "证券简称"
label variable accper "原始统计截止日期"
label variable report_type "报表类型：A合并，B母公司"
label variable cash "货币资金"
label variable receivables "应收账款净额"
label variable current_assets "流动资产合计"
label variable fixed_assets "固定资产净额"
label variable total_assets "资产总计"
label variable short_debt "短期借款"
label variable current_liabilities "流动负债合计"
label variable total_liabilities "负债合计"
label variable surplus_reserve "盈余公积"
label variable undistributed_profit "未分配利润"
label variable parent_equity "归属于母公司所有者权益合计"
label variable total_equity "所有者权益合计"

********************整理股票代码、日期和年份**********************
* 证券代码转为数值型
destring stock, replace

* 截取日期前四位，转为数值年份
gen int year = real(substr(accper, 1, 4))

* 提取月份和日，方便筛选年末报表
gen byte month = real(substr(accper, 6, 2))
gen byte day = real(substr(accper, 9, 2))

*把变量转变为数值
destring cash receivables current_assets fixed_assets ///
    total_assets short_debt current_liabilities ///
    total_liabilities surplus_reserve undistributed_profit ///
    parent_equity total_equity, replace ignore(",")

* 保留年末报表
keep if month == 12 & day == 31

* 保留合并报表：A为合并报表，B为母公司报表
keep if report_type == "A"

* 检查公司—年份唯一性
isid stock year

sort stock year
save "资产负债表.dta", replace

