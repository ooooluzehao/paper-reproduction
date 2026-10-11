*************数据合并***********************
use "TRD_Week.dta",clear
forvalues i = 1/2{
	append using "TRD_Week`i'.dta"
}
save "个股周收益率合并.dta",replace