clear all
set more off

* 请先cd到本篇code/10添加利润表相关控制变量，再运行此do。

import excel "FS_Comins.xlsx", sheet("sheet1") cellrange(A1:CC704375) firstrow allstring clear
drop in 1/2

* 2. 全部变量重命名
rename Stkcd stock
rename ShortName shortname
rename Accper accper
rename Typrep report_type
rename IfCorrect if_correct
rename DeclareDate correction_dates
rename B001100000 total_revenue
rename B001101000 revenue
rename Bbd1102000 interest_net_income
rename Bbd1102101 financial_interest_income
rename Bbd1102203 financial_interest_expense
rename B0i1103000 earned_premiums
rename B0i1103101 insurance_revenue
rename B0i1103111 reinsurance_revenue
rename B0i1103203 ceded_premiums
rename B0i1103303 unearned_premium_reserve
rename B0d1104000 net_fee_commission
rename B0d1104101 brokerage_net_income
rename B0d1104201 underwriting_net_income
rename B0d1104301 asset_management_net_income
rename B0d1104401 fee_commission_income
rename B0d1104501 fee_commission_expense
rename B0f1105000 other_business_revenue
rename B001200000 total_operating_cost
rename B001201000 operating_cost
rename B0i1202000 surrender_benefits
rename B0i1203000 net_claims_paid
rename B0i1203101 claims_paid
rename B0i1203203 claims_recovered
rename B0i1204000 net_insurance_reserve
rename B0i1204101 insurance_reserve
rename B0i1204203 insurance_reserve_recovered
rename B0i1205000 policyholder_dividends
rename B0i1206000 reinsurance_expense
rename B001207000 taxes_surcharges
rename B0f1208000 business_admin_expense
rename B0i1208103 reinsurance_expense_recovered
rename B0I1214000 insurance_fee_expense
rename B001209000 selling_expense
rename B001210000 admin_expense
rename B001216000 rd_expense
rename B001211000 finance_expense
rename B001211101 interest_expense
rename B001211203 interest_income
rename B001305000 other_income
rename B001302000 investment_income
rename B001302101 associates_invest_income
rename B001302201 amortized_asset_disposal_gain
rename B001303000 exchange_gain
rename B001306000 net_hedging_gain
rename B001301000 fair_value_gain
rename B001212000 asset_impairment_loss
rename B001307000 credit_impairment_loss
rename B001308000 asset_disposal_gain
rename B0f1213000 other_business_cost
rename B001304000 other_business_profit
rename B001300000 operating_profit
rename B001400000 nonoperating_income
rename B001400101 noncurrent_disposal_gain
rename B001500000 nonoperating_expense
rename B001500101 noncurrent_disposal_net_loss
rename B001500201 noncurrent_disposal_loss
rename B001000000 pretax_profit
rename B002100000 income_tax_expense
rename B002200000 unrecognized_invest_loss
rename B002300000 other_netprofit_items
rename B002000000 net_profit
rename B002000401 continuing_net_profit
rename B002000501 discontinued_net_profit
rename B002000101 parent_net_profit
rename B002000301 parent_other_equity_profit
rename B002000201 minority_profit
rename B003000000 basic_eps
rename B004000000 diluted_eps
rename B005000000 other_comprehensive_income
rename B005000101 parent_other_comprehensive
rename B005000102 minority_other_comprehensive
rename B006000000 comprehensive_income
rename B006000101 parent_comprehensive_income
rename B006000103 parent_other_equity_comp_income
rename B006000102 minority_comprehensive_income

* 3. 添加中文标签（金额和每股项目单位按源文件单位行：元）
label variable stock "证券代码"
label variable shortname "证券简称"
label variable accper "统计截止日期"
label variable report_type "报表类型"
label variable if_correct "是否发生差错更正"
label variable correction_dates "差错更正披露日期"
label variable total_revenue "营业总收入"
label variable revenue "营业收入"
label variable interest_net_income "利息净收入"
label variable financial_interest_income "利息收入"
label variable financial_interest_expense "利息支出"
label variable earned_premiums "已赚保费"
label variable insurance_revenue "保险业务收入"
label variable reinsurance_revenue "其中：分保费收入"
label variable ceded_premiums "减：分出保费"
label variable unearned_premium_reserve "减：提取未到期责任准备金"
label variable net_fee_commission "手续费及佣金净收入"
label variable brokerage_net_income "其中：代理买卖证券业务净收入"
label variable underwriting_net_income "其中:证券承销业务净收入"
label variable asset_management_net_income "其中：受托客户资产管理业务净收入"
label variable fee_commission_income "手续费及佣金收入"
label variable fee_commission_expense "手续费及佣金支出"
label variable other_business_revenue "其他业务收入"
label variable total_operating_cost "营业总成本"
label variable operating_cost "营业成本"
label variable surrender_benefits "退保金"
label variable net_claims_paid "赔付支出净额"
label variable claims_paid "赔付支出"
label variable claims_recovered "减：摊回赔付支出"
label variable net_insurance_reserve "提取保险责任准备金净额"
label variable insurance_reserve "提取保险责任准备金"
label variable insurance_reserve_recovered "减：摊回保险责任准备金"
label variable policyholder_dividends "保单红利支出"
label variable reinsurance_expense "分保费用"
label variable taxes_surcharges "税金及附加"
label variable business_admin_expense "业务及管理费"
label variable reinsurance_expense_recovered "减：摊回分保费用"
label variable insurance_fee_expense "保险业务手续费及佣金支出"
label variable selling_expense "销售费用"
label variable admin_expense "管理费用"
label variable rd_expense "研发费用"
label variable finance_expense "财务费用"
label variable interest_expense "其中：利息费用(财务费用)"
label variable interest_income "其中：利息收入(财务费用)"
label variable other_income "其他收益"
label variable investment_income "投资收益"
label variable associates_invest_income "其中：对联营企业和合营企业的投资收益"
label variable amortized_asset_disposal_gain "其中：以摊余成本计量的金融资产终止确认收益"
label variable exchange_gain "汇兑收益"
label variable net_hedging_gain "净敞口套期收益"
label variable fair_value_gain "公允价值变动收益"
label variable asset_impairment_loss "资产减值损失"
label variable credit_impairment_loss "信用减值损失"
label variable asset_disposal_gain "资产处置收益"
label variable other_business_cost "其他业务成本"
label variable other_business_profit "其他业务利润"
label variable operating_profit "营业利润"
label variable nonoperating_income "加：营业外收入"
label variable noncurrent_disposal_gain "其中：非流动资产处置利得"
label variable nonoperating_expense "减：营业外支出"
label variable noncurrent_disposal_net_loss "其中：非流动资产处置净损益"
label variable noncurrent_disposal_loss "其中：非流动资产处置损失"
label variable pretax_profit "利润总额"
label variable income_tax_expense "减：所得税费用"
label variable unrecognized_invest_loss "未确认的投资损失"
label variable other_netprofit_items "影响净利润的其他项目"
label variable net_profit "净利润"
label variable continuing_net_profit "持续经营净利润"
label variable discontinued_net_profit "终止经营净利润"
label variable parent_net_profit "归属于母公司所有者的净利润"
label variable parent_other_equity_profit "归属于母公司其他权益工具持有者的净利润"
label variable minority_profit "少数股东损益"
label variable basic_eps "基本每股收益"
label variable diluted_eps "稀释每股收益"
label variable other_comprehensive_income "其他综合收益(损失)"
label variable parent_other_comprehensive "归属母公司所有者的其他综合收益的税后净额"
label variable minority_other_comprehensive "归属于少数股东的其他综合收益的税后净额"
label variable comprehensive_income "综合收益总额"
label variable parent_comprehensive_income "归属于母公司所有者的综合收益"
label variable parent_other_equity_comp_income "归属于母公司其他权益工具持有者的综合收益总额"
label variable minority_comprehensive_income "归属少数股东的综合收益"

* 4. 股票代码、差错标记和金额转为数值；日期和报表类型保留字符串。
destring stock if_correct, replace

destring total_revenue revenue interest_net_income financial_interest_income ///
    financial_interest_expense earned_premiums insurance_revenue reinsurance_revenue ///
    ceded_premiums unearned_premium_reserve net_fee_commission brokerage_net_income ///
    underwriting_net_income asset_management_net_income fee_commission_income fee_commission_expense ///
    other_business_revenue total_operating_cost operating_cost surrender_benefits ///
    net_claims_paid claims_paid claims_recovered net_insurance_reserve ///
    insurance_reserve insurance_reserve_recovered policyholder_dividends reinsurance_expense ///
    taxes_surcharges business_admin_expense reinsurance_expense_recovered insurance_fee_expense ///
    selling_expense admin_expense rd_expense finance_expense ///
    interest_expense interest_income other_income investment_income ///
    associates_invest_income amortized_asset_disposal_gain exchange_gain net_hedging_gain ///
    fair_value_gain asset_impairment_loss credit_impairment_loss asset_disposal_gain ///
    other_business_cost other_business_profit operating_profit nonoperating_income ///
    noncurrent_disposal_gain nonoperating_expense noncurrent_disposal_net_loss noncurrent_disposal_loss ///
    pretax_profit income_tax_expense unrecognized_invest_loss other_netprofit_items ///
    net_profit continuing_net_profit discontinued_net_profit parent_net_profit ///
    parent_other_equity_profit minority_profit basic_eps diluted_eps ///
    other_comprehensive_income parent_other_comprehensive minority_other_comprehensive comprehensive_income ///
    parent_comprehensive_income parent_other_equity_comp_income minority_comprehensive_income, replace ignore(",")

* 不加force，避免将无法识别的文字静默转换为缺失。
* 若某列仍是字符串，以下检查会提示该变量，先核对原值。
foreach v in total_revenue revenue interest_net_income financial_interest_income ///
    financial_interest_expense earned_premiums insurance_revenue reinsurance_revenue ///
    ceded_premiums unearned_premium_reserve net_fee_commission brokerage_net_income ///
    underwriting_net_income asset_management_net_income fee_commission_income fee_commission_expense ///
    other_business_revenue total_operating_cost operating_cost surrender_benefits ///
    net_claims_paid claims_paid claims_recovered net_insurance_reserve ///
    insurance_reserve insurance_reserve_recovered policyholder_dividends reinsurance_expense ///
    taxes_surcharges business_admin_expense reinsurance_expense_recovered insurance_fee_expense ///
    selling_expense admin_expense rd_expense finance_expense ///
    interest_expense interest_income other_income investment_income ///
    associates_invest_income amortized_asset_disposal_gain exchange_gain net_hedging_gain ///
    fair_value_gain asset_impairment_loss credit_impairment_loss asset_disposal_gain ///
    other_business_cost other_business_profit operating_profit nonoperating_income ///
    noncurrent_disposal_gain nonoperating_expense noncurrent_disposal_net_loss noncurrent_disposal_loss ///
    pretax_profit income_tax_expense unrecognized_invest_loss other_netprofit_items ///
    net_profit continuing_net_profit discontinued_net_profit parent_net_profit ///
    parent_other_equity_profit minority_profit basic_eps diluted_eps ///
    other_comprehensive_income parent_other_comprehensive minority_other_comprehensive comprehensive_income ///
    parent_comprehensive_income parent_other_equity_comp_income minority_comprehensive_income {
    confirm numeric variable `v'
}

*5.按原字符串日期提取年、月、日，保留所有期间和报表类型。
gen int year = real(substr(accper, 1, 4))
gen byte month = real(substr(accper, 6, 2))
gen byte day = real(substr(accper, 9, 2))
label variable year "报表年份"
label variable month "报表月份"
label variable day "报表日期中的日"

assert !missing(stock, year, month, day)
assert inrange(month, 1, 12)
assert inrange(day, 1, 31)
replace report_type = upper(strtrim(report_type))
assert inlist(report_type, "A", "B")

*6. 检查、保存。。
order stock shortname accper year month day report_type if_correct correction_dates
sort stock year month day report_type
tab report_type, missing
duplicates report stock accper report_type
save "利润表_全部整理.dta", replace
