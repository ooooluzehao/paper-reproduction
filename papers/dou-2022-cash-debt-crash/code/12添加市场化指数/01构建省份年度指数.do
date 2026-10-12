version 18.0
clear all
set more off

* 从12添加市场化指数目录执行。
* 保留全部第11步主表行，不删缺失、不缩尾、不更改既有字段。
* 指数采用新提供的完整2007—2018文件，原报告节选表保留不变。

**************** 1. 省份名称统一 ****************
import delimited using "合并来源/省份名称代码对照.csv", ///
    varnames(1) case(preserve) encoding("utf-8") clear
rename province province_market
rename province_code province_code_market
isid province_short
label variable province_market "指数来源省份规范名"
label variable province_code_market "指数来源省份代码"
tempfile province_map
save `province_map'

**************** 2. 提取完整省份年度指数 ****************
use "合并来源/2007-2018企业省份+市场化指数合并.dta", clear
assert code == 证券代码
rename 证券代码 stock
rename 省份 province_short
rename market market_direct
rename 政府与市场关系 government_market_score
rename 非国有经济发展 nonstate_score
rename 产品市场的发育程度 product_market_score
rename 要素市场的发育程度 factor_market_score
rename 市场中介组织的发育和法律制度环境 intermediary_legal_score
recast long stock
recast int year
isid stock year
replace province_short = strtrim(province_short)
merge m:1 province_short using `province_map', assert(match) nogen

label variable market_direct "企业指数来源中的市场化总指数（原值）"
keep stock year province_market province_code_market market_direct ///
    government_market_score nonstate_score product_market_score ///
    factor_market_score intermediary_legal_score
save "指数来源_企业年度对照.dta", replace

* 同省份同年份的总指数和各方面指数必须完全一致才能保留一条。
foreach v in market_direct government_market_score nonstate_score ///
    product_market_score factor_market_score intermediary_legal_score {
    bysort province_code_market year: assert `v' == `v'[1]
}
bysort province_code_market year: keep if _n == 1
rename province_code_market province_code
rename province_market province
rename market_direct market_index_raw
keep province province_code year market_index_raw ///
    government_market_score nonstate_score product_market_score ///
    factor_market_score intermediary_legal_score
isid province_code year
assert _N == 31 * 12
assert inrange(year, 2007, 2018)
assert !missing(market_index_raw) & market_index_raw > -1
gen double Index = ln(1 + market_index_raw)
label variable market_index_raw "完整来源市场化总指数（未取对数）"
label variable Index "市场化总指数加1取自然对数"
label variable government_market_score "政府与市场关系指数"
label variable nonstate_score "非国有经济发展指数"
label variable product_market_score "产品市场发育程度指数"
label variable factor_market_score "要素市场发育程度指数"
label variable intermediary_legal_score "市场中介组织与法律制度环境指数"
sort province_code year
save "省份年度市场化指数_完整2007至2018.dta", replace


* 输出31省份×12年，共372条唯一省份年度指数。
count
isid province_code year
