use "资产负债表.dta",clear
merge 1:1 stock year using "公司行业代码.dta"
drop if _merge == 2
drop if _merge == 1
drop _merge 
save "存贷双高计算前.dta "