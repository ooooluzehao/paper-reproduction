version 18.0
clear all
set more off

* 本文件从控制变量与缩尾目录运行，实际不执行删缺失或缩尾。
use "../../10添加利润表相关控制变量/添加ROA.dta", clear
isid stock year
assert risk_year == year + 1
local Nmaster = _N

* 主表为已合并X/Y及Size/GROWTH/Ret/ROA的第10步输出。
* keep(master match)保留所有主表行，控制变量未匹配也保留。
* 每张来源保留独立merge标记：1=主表未匹配，3=匹配。

merge 1:1 stock year using "控制变量DTA/Zscore_STPT.dta", ///
    keep(master match) keepusing(Zscore STPT IsSuspend) gen(Zscore_merge)
assert _N == `Nmaster'
tabulate Zscore_merge, missing
label variable Zscore_merge "Zscore_STPT匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/Big4.dta", ///
    keep(master match) keepusing(Big4) gen(Big4_merge)
assert _N == `Nmaster'
tabulate Big4_merge, missing
label variable Big4_merge "Big4匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/Disp.dta", ///
    keep(master match) keepusing(Disp) gen(Disp_merge)
assert _N == `Nmaster'
tabulate Disp_merge, missing
label variable Disp_merge "Disp匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/DAAbacc.dta", ///
    keep(master match) keepusing(DA_csv Abacc_csv) gen(DAAbacc_merge)
assert _N == `Nmaster'
tabulate DAAbacc_merge, missing
label variable DAAbacc_merge "DAAbacc匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/MB.dta", ///
    keep(master match) keepusing(MB MB_parent MB_ta) gen(MB_merge)
assert _N == `Nmaster'
tabulate MB_merge, missing
label variable MB_merge "MB匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/Dturnt_d.dta", ///
    keep(master match) keepusing(Dturnt_d) gen(Dturnt_d_merge)
assert _N == `Nmaster'
tabulate Dturnt_d_merge, missing
label variable Dturnt_d_merge "Dturnt_d匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/Dturnt_m.dta", ///
    keep(master match) keepusing(Dturnt_m) gen(Dturnt_m_merge)
assert _N == `Nmaster'
tabulate Dturnt_m_merge, missing
label variable Dturnt_m_merge "Dturnt_m匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/province.dta", ///
    keep(master match) keepusing(province province_code) gen(province_merge)
assert _N == `Nmaster'
tabulate province_merge, missing
label variable province_merge "province匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/ROA.dta", ///
    keep(master match) keepusing(ROA_csv) gen(ROA_csv_merge)
assert _N == `Nmaster'
tabulate ROA_csv_merge, missing
label variable ROA_csv_merge "ROA匹配标记：1未匹配，3匹配"

merge 1:1 stock year using "控制变量DTA/CFO_annual.dta", ///
    keep(master match) keepusing(cfo) gen(CFO_merge)
assert _N == `Nmaster'
tabulate CFO_merge, missing
label variable CFO_merge "CFO_annual匹配标记：1未匹配，3匹配"

* 来源年度利润与现有net_profit并列保存，不能静默覆盖第10步数据。
preserve
    use "控制变量DTA/income_annual.dta", clear
    rename revenue revenue_csv
    rename net_profit net_profit_csv
    label variable revenue_csv "来源CSV年度营业收入"
    label variable net_profit_csv "来源CSV年度净利润（保留现有net_profit）"
    tempfile income_csv
    save `income_csv'
restore
merge 1:1 stock year using `income_csv', ///
    keep(master match) keepusing(revenue_csv net_profit_csv) gen(income_csv_merge)
assert _N == `Nmaster'
label variable income_csv_merge "年度利润CSV匹配标记：1未匹配，3匹配"

* 原始两个换手率版本都保留，Dturnt使用来源日均版本。
gen double Dturnt = Dturnt_d
label variable Dturnt "日均换手率年度均值差（等于Dturnt_d）"

* 仅生成比较列，不据此删行或替换数值。
gen double ROA_csv_diff = ROA_csv - ROA if !missing(ROA_csv, ROA)
label variable ROA_csv_diff "来源ROA减第10步ROA"

* DA_csv/Abacc_csv只表示来源值，不生成正式DA/Abacc。
* province是Index的匹配基础，不等同市场化指数。
* 季度利润缺少季度权益/ROE，暂不生成ROEGROWTH。
isid stock year
assert risk_year == year + 1
assert _N == `Nmaster'
order stock year risk_year DH FNCSKEW FDUVOL Size GROWTH Ret ROA ///
    MB Dturnt Big4 Zscore Disp DA_csv Abacc_csv province province_code
sort stock year
save "添加剩余控制变量_未删缺失未缩尾.dta", replace

* 描述性核对只报告，不改变样本与数值。
misstable summarize FNCSKEW FDUVOL DH Size GROWTH Ret ROA ///
    MB Dturnt Big4 Zscore Disp DA_csv Abacc_csv
summarize ROA_csv_diff, detail
count
