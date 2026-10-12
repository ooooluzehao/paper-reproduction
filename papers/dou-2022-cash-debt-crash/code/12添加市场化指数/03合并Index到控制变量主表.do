version 18.0
clear all
set more off

* 从12添加市场化指数目录运行。
* 将完成的公司年度Index表匹配到第11步控制变量主表。
use "../11添加剩余控制变量/控制变量与缩尾/添加剩余控制变量_未删缺失未缩尾.dta", clear
isid stock year
local Nmaster = _N

merge 1:1 stock year using "公司年度市场化指数.dta", ///
    keep(master match) keepusing(Index market_index_raw ///
        province_for_index province_code_for_index province_source) gen(Index_merge)

assert _N == `Nmaster'
assert Index_merge == 3
assert !missing(Index)
assert abs(Index - ln(1 + market_index_raw)) < 1e-12
assert risk_year == year + 1
isid stock year
label variable Index "市场化总指数加1取自然对数"
label variable market_index_raw "市场化总指数原值"
label variable Index_merge "公司年度市场化指数匹配标记"
order stock year risk_year DH FNCSKEW FDUVOL Size GROWTH Ret ROA ///
    MB Dturnt Big4 Zscore Disp DA_csv Abacc_csv Index
sort stock year
save "添加Index.dta", replace

tabulate Index_merge, missing
count if missing(Index)
count
