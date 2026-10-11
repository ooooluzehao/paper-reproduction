
use "存贷双高计算前.dta", clear


********************1.行业划分**********************************
*非制造业取首字母，制造业保留C及一位数字这样刚好22个行业与原文对应。
replace indcode = upper(strtrim(indcode))
gen str3 industry = substr(indcode, 1, 1)
replace industry = substr(indcode, 1, 2) if substr(indcode, 1, 1) == "C"
replace industry = "" if missing(indcode)
label variable industry "非制造业按门类，制造业按两位数字大类"

********************2.筛选存贷双高公司******************************
*比例缺失仍保留缺失；总资产必须大于0。
gen double cash_ratio = cash / total_assets ///
    if !missing(cash, total_assets) & total_assets > 0
gen double debt_ratio = short_debt / total_assets ///
    if !missing(short_debt, total_assets) & total_assets > 0

*暂按保留样本的年度行业内各公司比例简单平均（论文并未说明是否为加权平均）。
bysort industry year: egen double industry_cash_mean = mean(cash_ratio)
bysort industry year: egen double industry_debt_mean = mean(debt_ratio)
replace industry_cash_mean = . if missing(industry)
replace industry_debt_mean = . if missing(industry)

*当年：两项比例都超过20%，且分别超过各自行业均值。
gen byte high_thisyear = ///
    cash_ratio > 0.20 & debt_ratio > 0.20 ///
    & cash_ratio > industry_cash_mean ///
    & debt_ratio > industry_debt_mean ///
    if !missing(cash_ratio, debt_ratio, ///
        industry_cash_mean, industry_debt_mean)

*连续两年：必须是当年和上一自然年均满足。
xtset stock year
gen byte DH = .
*任意一年明确不满足，就不可能连续两年满足
replace DH = 0 if high_thisyear == 0 | L.high_thisyear == 0
*两年都明确满足，才记为1
replace DH = 1 if high_thisyear == 1 & L.high_thisyear == 1



label variable cash_ratio "货币资金/资产总计"
label variable debt_ratio "短期借款/资产总计"
label variable industry_cash_mean "年度行业平均货币资金比例"
label variable industry_debt_mean "年度行业平均短期借款比例"
label variable high_thisyear "单年满足20%和行业均值条件"
label variable DH "当年及上一年均满足存贷双高条件"
sort stock year
save "存贷双高.dta", replace

