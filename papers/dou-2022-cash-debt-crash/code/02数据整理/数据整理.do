import excel "TRD_Week.xlsx", sheet("sheet1") firstrow
keep 证券代码 周开盘日期 交易周份 考虑现金红利再投资的周个股回报率 周个股总市值 市场类型
save "TRD_Week.dta",replace 
forvalues i=1/2{
	import excel "TRD_Week`i'.xlsx", sheet("sheet1") firstrow clear
	keep 证券代码 周开盘日期 交易周份 考虑现金红利再投资的周个股回报率 周个股总市值 市场类型
    save "TRD_Week`i'.dta",replace
	clear all
}
import excel "TRD_Weekm.xlsx", sheet("sheet1") firstrow
keep 市场类型 交易周份 考虑现金红利再投资的周市场回报率等权平均法 考虑现金红利再投资的周市场回报率总市值加权平均法 考虑现金红利再投资的周市场回报率流通市值加权平均法 周市场流通市值 周市场总市值
save "市场周收益率合并",replace