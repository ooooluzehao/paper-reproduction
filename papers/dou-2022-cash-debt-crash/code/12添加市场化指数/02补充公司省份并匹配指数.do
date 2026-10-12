version 18.0
clear all
set more off

* 先运行01，再按年度省份生成公司年度指数。
use "省份年度市场化指数_完整2007至2018.dta", clear
isid province_code year
rename province_code province_code_for_index
drop province
tempfile market_by_province
save `market_by_province'
local company_market "指数来源_企业年度对照.dta"

**************** 3. 整理企业年度省份对照 ****************
use "合并来源/province.dta", clear
rename PROVINCE province_annual
rename PROVINCECODE province_code_annual
isid stock year
assert !missing(stock, year, province_code_annual)
label variable province_annual "企业年度省份表中的省份"
label variable province_code_annual "企业年度省份表中的代码"
tempfile annual_province
save `annual_province'

**************** 4. 同年省份补充，不跨年猜测 ****************
import delimited using "合并来源/缺省份记录_同年基本信息补充.csv", ///
    varnames(1) case(preserve) encoding("utf-8") clear
rename province province_db
rename province_code province_code_db
isid stock year
label variable province_db "缺省份记录的同年基本信息省份"
label variable province_code_db "缺省份记录的同年基本信息代码"
label variable source_batch "本地公司基本信息补充批次"
tempfile db_province
save `db_province'

**************** 5. 合并到第11步全部公司年度主表 ****************
use "../11添加剩余控制变量/控制变量与缩尾/添加剩余控制变量_未删缺失未缩尾.dta", clear
isid stock year
local Nmaster = _N

merge 1:1 stock year using `annual_province', ///
    keep(master match) gen(Index_province_merge)
assert _N == `Nmaster'
merge 1:1 stock year using `company_market', ///
    keep(master match) keepusing(province_market province_code_market market_direct) ///
    gen(Index_company_merge)
assert _N == `Nmaster'
merge 1:1 stock year using `db_province', ///
    keep(master match) keepusing(province_db province_code_db report_date source_batch) ///
    gen(Index_db_merge)
assert _N == `Nmaster'

* 年度省份表优先；其缺失时用指数来源省份，再用同年基本信息补充。
gen str40 province_for_index = province_annual
gen long province_code_for_index = province_code_annual
gen byte province_source = 1 if !missing(province_code_annual)
replace province_for_index = province_market ///
    if missing(province_code_for_index) & !missing(province_code_market)
replace province_source = 2 ///
    if missing(province_code_for_index) & !missing(province_code_market)
replace province_code_for_index = province_code_market ///
    if missing(province_code_for_index) & !missing(province_code_market)
replace province_for_index = province_db ///
    if missing(province_code_for_index) & !missing(province_code_db)
replace province_source = 3 ///
    if missing(province_code_for_index) & !missing(province_code_db)
replace province_code_for_index = province_code_db ///
    if missing(province_code_for_index) & !missing(province_code_db)

label define index_province_source 1 "年度省份表" 2 "指数企业省份" 3 "同年公司基本信息补充"
label values province_source index_province_source
label variable province_source "市场化指数采用的省份来源"
label variable province_for_index "本次匹配指数使用的省份，不覆盖原province"
label variable province_code_for_index "本次匹配指数使用的省份代码"

gen byte province_conflict = province_code_annual != province_code_market ///
    if !missing(province_code_annual, province_code_market)
label variable province_conflict "两份来源省份不一致=1（年度省份表优先）"

* 按省份年份匹配，而非要求每家企业出现在指数企业清单中。
merge m:1 province_code_for_index year using `market_by_province', ///
    keep(master match) gen(Index_merge)
assert _N == `Nmaster'
assert !missing(province_code_for_index, market_index_raw, Index)
assert Index_merge == 3
assert abs(Index - ln(1 + market_index_raw)) < 1e-12
assert risk_year == year + 1
isid stock year
sort stock year
order stock year risk_year province_for_index province_code_for_index ///
    province_source market_index_raw Index
save "添加市场化指数_全部企业_未删缺失未缩尾.dta", replace

* 同时保存一张独立公司年度指数对照，便于下一步merge。
preserve
    keep stock year province_for_index province_code_for_index province_source ///
        market_index_raw Index government_market_score nonstate_score ///
        product_market_score factor_market_score intermediary_legal_score ///
        province_conflict Index_merge
    isid stock year
    save "公司年度市场化指数.dta", replace
restore

tabulate province_source, missing
count if missing(Index)
count
