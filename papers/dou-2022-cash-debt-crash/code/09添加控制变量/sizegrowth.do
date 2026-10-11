use "资产负债表.dta", clear
xtset stock year
gen  Size = ln(total_assets) if total_assets > 0 & !missing(total_assets)
gen GROWTH = (total_assets - L.total_assets) / L.total_assets if !missing(total_assets, L.total_assets) & L.total_assets > 0
keep stock year Size GROWTH
merge 1:1 stock year  using "合并核心变量完毕缺少控制变量.dta"
drop if _merge == 1
drop _merge
save"添加sizegrowth.dta",replace


clear all
********************1. 读取原始周收益率***************************
use "../03合并个股周收益率与市场周收益率/周收益率.dta", clear
rename 证券代码 stock
rename 交易周份 weekstr
rename 考虑现金红利再投资的周个股回报率 ri
rename 市场类型 type

drop if type == 8
isid stock weekstr
destring stock, replace

gen int year = real(substr(weekstr, 1, 4))
keep if inrange(year, 2007, 2018)

********************2. 计算公司年度平均周收益率*******************
bysort stock year: egen double Ret = mean(ri)
bysort stock year: egen Ret_Nweek = count(ri)

* 先计算全年均值，再每公司年份保留一行。
bysort stock year: keep if _n == 1
keep stock year Ret Ret_Nweek
label variable Ret "当年平均周个股收益率（现金红利再投资，算术平均）"
label variable Ret_Nweek "计算Ret的当年非缺失周收益率数量"
isid stock year
sort stock year
save "Ret_公司年度.dta", replace

********************3. 合并到当前核心变量数据*********************
* 前半段已保留Size/GROWTH，以下从添加sizegrowth.dta合并当年Ret。
use "添加sizegrowth.dta", clear
isid stock year
merge 1:1 stock year using "Ret_公司年度.dta", keep(master match) keepusing(Ret Ret_Nweek) 
save "添加Ret.dta", replace


