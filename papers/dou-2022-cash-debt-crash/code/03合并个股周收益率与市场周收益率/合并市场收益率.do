use "个股周收益率合并.dta",clear
merge m:1 交易周份 市场类型 using"市场周收益率合并.dta"
keep if _merge == 3
drop _merge
save "周收益率.dta",replace