use "周收益率_回归完成.dta"


*********************5. 生成公司特有周收益率*********************

* ln(1+残差)要求残差大于-1
gen byte invalid = (epsilon <= -1) if !missing(epsilon)
bysort stock year: egen Ninvalid = total(invalid)

gen double W = ln(1 + epsilon) ///
    if epsilon > -1 & !missing(epsilon)

* 统计有效周数、计算公司年度平均W
bysort stock year: egen Nweek = count(W)
bysort stock year: egen Wmean = mean(W)

* 标记符合计算条件的公司年份
* 沿用此前规则：至少30个有效周，且无无法取对数的残差
gen byte eligible = ///
    reg_ok == 1 & Nweek >= 30 & Ninvalid == 0


*********************6. 计算NCSKEW*******************************

gen double W2 = W^2
gen double W3 = W^3

bysort stock year: egen sumW2 = total(W2)
bysort stock year: egen sumW3 = total(W3)

gen double NCSKEW = ///
    -(Nweek * (Nweek - 1)^1.5 * sumW3) ///
    / ((Nweek - 1) * (Nweek - 2) * sumW2^1.5) ///
    if eligible == 1 & sumW2 > 0 & sumW2 < .


*********************7. 计算DUVOL********************************

* 低于公司当年平均W为下跌周，其余为上涨周
gen byte down = (W < Wmean) if !missing(W)
gen byte up   = (W >= Wmean) if !missing(W)

* 下跌周数、上涨周数
bysort stock year: egen nd = total(down)
bysort stock year: egen nu = total(up)

* 下跌周和上涨周各自的W平方
gen double downW2 = W2 if down == 1
gen double upW2   = W2 if up == 1

bysort stock year: egen sumDownW2 = total(downW2)
bysort stock year: egen sumUpW2   = total(upW2)

* 暂采用自然对数
gen double DUVOL = ///
    ln(((nu - 1) * sumDownW2) ///
    / ((nd - 1) * sumUpW2)) ///
    if eligible == 1 & nd > 1 & nu > 1 ///
    & sumDownW2 > 0 & sumDownW2 < . ///
    & sumUpW2 > 0 & sumUpW2 < .


*********************8. 保存周明细和公司年度结果******************

*每家公司每年保留一行
bysort stock year (tw): keep if _n == 1
isid stock year

*********************9. 对齐下一年崩盘风险************************

* 例如：2008年的风险，对应2007年的解释变量
rename year risk_year
gen int year = risk_year - 1

rename NCSKEW FNCSKEW
rename DUVOL FDUVOL

order stock year risk_year FNCSKEW FDUVOL
isid stock year

save "崩盘风险.dta", replace