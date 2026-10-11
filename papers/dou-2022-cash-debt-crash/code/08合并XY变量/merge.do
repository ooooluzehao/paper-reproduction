use "崩盘风险.dta",clear
destring stock,replace
merge 1:1 stock year using"存贷双高.dta"
keep if _merge == 3
drop _merge 
save "合并核心变量完毕缺少控制变量.dta",replace