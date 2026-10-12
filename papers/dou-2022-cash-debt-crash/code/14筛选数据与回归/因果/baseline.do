* 存贷双高与股价崩盘风险：论文式(3)、表4。
* DA_csv、Abacc_csv暂用来源值；ROEGROWTH用于机制检验，不入本次基准模型。
global controls "Size MB ROA Ret Dturnt GROWTH Big4 Index Zscore Disp DA_csv Abacc_csv"
global continuous "FNCSKEW FDUVOL Size MB ROA Ret Dturnt GROWTH Index Zscore Disp DA_csv Abacc_csv"

version 18.0
clear all
set more off
* 请先cd到本目录，再运行baseline.do。
use "添加ROE与ROEGROWTH.dta", clear
isid stock year

* 1. 删除模型变量及筛选字段的缺失记录。
egen nmiss = rowmiss(FNCSKEW FDUVOL DH $controls stock year STPT)
drop if nmiss > 0 | missing(industry)
drop nmiss

* 2. 剔除金融业J、房地产业K。
drop if inlist(industry, "J", "K")

* 3. 剔除当年ST/PT。
drop if STPT == 1

* 4. 主要连续变量全样本两端各1%缩尾，DH、Big4不缩尾。
winsor2 $continuous, replace

* 5. 描述性统计由sum2docx输出。
sum2docx FNCSKEW FDUVOL DH $controls using "描述性统计.docx", replace ///
    stats(N min(%9.4f) max(%9.4f) mean(%9.4f) sd(%9.4f)) ///
    title("基准模型描述性统计") font("宋体", 10) ///
    note("DA_csv、Abacc_csv暂用来源值；连续变量全样本1%缩尾。")

* 6. Pearson相关性矩阵由corr2docx输出。
corr2docx FNCSKEW FDUVOL DH $controls using "相关性矩阵.docx", replace ///
    spearman(ignore) star fmt(%9.3f) landscape pagesize(A3) ///
    font("宋体", 9) title("基准模型变量相关性矩阵") ///
    note("Pearson相关系数；DA_csv、Abacc_csv暂用来源值。")

* 7. 对应论文式(3)、表4第(3)(4)列，按公司聚类。
egen long year_industry = group(year industry)
reghdfe FNCSKEW DH $controls, absorb(stock year_industry) vce(cluster stock)
estimates store FE_FNCSKEW

reghdfe FDUVOL DH $controls, absorb(stock year_industry) vce(cluster stock)
estimates store FE_FDUVOL
gen byte sample_fe = e(sample)
label variable sample_fe "固定效应回归实际样本（reghdfe默认剔除单例）"

* 8. 回归表由reg2docx输出，括号内为t值。
reg2docx FE_FNCSKEW FE_FDUVOL ///
    using "两列基准回归.docx", replace b(%9.4f) t(%9.3f) ///
    scalars(N r2(%9.4f)) order(DH $controls) ///
    mtitles("FNCSKEW" "FDUVOL") ///
    addfe("公司固定效应 = 是 是" "年份×行业固定效应 = 是 是" "公司聚类 = 是 是") ///
    title("存贷双高与次年股价崩盘风险基准回归") font("宋体", 10) ///
    note("括号内为公司聚类t值。DA_csv、Abacc_csv暂用来源值。固定效应列默认剔除单例。")


