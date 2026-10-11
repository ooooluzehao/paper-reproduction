clear all


********************1. 处理周收益率数据***********************
use "周收益率.dta", clear
rename 证券代码 stock
rename 交易周份 weekstr
rename 考虑现金红利再投资的周个股回报率 ri
rename 考虑现金红利再投资的周市场回报率流通市值加权平均法 rm
rename 市场类型 type

*排除B股市场
drop if type == 8

*检查键值唯一性
isid stock weekstr

*******************2.处理时间变量，给所有周排序****************

*提取年份
gen int year = real(substr(weekstr, 1, 4))
*提取第几周
gen byte weekno = real(substr(weekstr, 6, 2))
*忽略被跳过的周，给所有周排序
egen long tw = group(year weekno)

*******************3. 在市场周数据中生成市场收益率前后两期*****

* 为每家公司生成数值编号
egen long id = group(stock)

* 声明公司—交易周面板
xtset id tw

* 直接生成市场收益率的前后期
gen double rm_l2 = L2.rm
gen double rm_l1 = L.rm
gen double rm_f1 = F.rm
gen double rm_f2 = F2.rm

* 公司缺少对应周记录时，用同市场同周其他公司的值补齐
foreach v in rm_l2 rm_l1 rm_f1 rm_f2 {

    bysort type tw: egen double fill = max(`v')
    replace `v' = fill if missing(`v')
    drop fill

}

* 论文的崩盘风险年份为2008—2019年
keep if inrange(year, 2008, 2019)


*********************4. 定义公司年度崩盘风险计算程序**************

* 每个公司年份生成一个分组编号
egen long firmyear = group(stock year)

* 准备存储回归结果
gen double epsilon = .
gen int Nreg = .
gen byte reg_ok = 0

quietly summarize firmyear, meanonly
local groups = r(max)

* 每个公司年份分别回归
forvalues g = 1/`groups' {

    quietly count if firmyear == `g' ///
        & !missing(ri, rm_l2, rm_l1, rm, rm_f1, rm_f2)

    if r(N) >= 30 {

        capture quietly regress ri ///
            rm_l2 rm_l1 rm rm_f1 rm_f2 ///
            if firmyear == `g'
		
        if _rc == 0 {

            quietly replace Nreg = e(N) if firmyear == `g'

            if e(rank) == 6 {

                quietly predict double resid_tmp ///
                    if e(sample), residuals

                quietly replace epsilon = resid_tmp ///
                    if e(sample)

                quietly replace reg_ok = 1 ///
                    if firmyear == `g'

                drop resid_tmp
            }
        }
    }
}

