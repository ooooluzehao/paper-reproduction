version 18.0
clear all
set more off

* 从本do所在目录运行；CSV保留不变，清理结果另存。
* 不删控制变量缺失行，不缩尾，不筛ST/PT或行业。
* analysis_sample.csv已经过筛选和缩尾，仅归档，不作本步骤输入。
capture mkdir "控制变量DTA"

foreach f in Big4 CFO_annual DA DAAbacc DA_detail Disp Dturnt_d Dturnt_m income_annual income_quarterly MB province ROA Zscore_STPT {

    import delimited using "控制变量CSV/`f'.csv", ///
        varnames(1) case(preserve) stringcols(_all) encoding("utf-8") clear

    * 除真实文本列外，全部转为数值；不加force，异常文本使程序停止。
    foreach v of varlist _all {
        if !inlist("`v'", "Accper_s", "ym", "PROVINCE") {
            destring `v', replace
            confirm numeric variable `v'
        }
    }

    recast long stock
    recast int year
    format stock %06.0f
    label variable stock "证券代码（数值，显示六位）"
    label variable year "解释变量年份（不按risk_year合并）"
    assert !missing(stock, year)
    assert stock == floor(stock) & inrange(stock, 0, 999999)
    assert year == floor(year) & inrange(year, 1900, 2100)

    if "`f'" == "Big4" {
        label variable Big4 "国际四大审计标记（来源CSV）"
        assert inlist(Big4, 0, 1) | missing(Big4)
    }

    if "`f'" == "CFO_annual" {
        label variable cfo "年度经营活动现金流量净额（来源CSV）"
    }

    if "`f'" == "DA" {
        rename DA DA_csv
        label variable DA_csv "来源DA：绝对应计额/年末资产，非正式DA"
    }

    if "`f'" == "DAAbacc" {
        rename DA DA_csv
        rename Abacc Abacc_csv
        label variable DA_csv "来源DA：绝对应计额/年末资产，非正式DA"
        label variable Abacc_csv "来源DA前三条记录合计，待正式计算"
    }

    if "`f'" == "DA_detail" {
        rename DA DA_csv
        label variable revenue "来源年度营业收入"
        label variable net_profit "来源年度净利润"
        label variable cfo "来源年度经营活动现金流量净额"
        label variable receivables "来源应收账款净额"
        label variable fixed_assets "来源固定资产净额"
        label variable TA "来源年末总资产"
        label variable DA_csv "来源DA：绝对应计额/年末资产，非正式DA"
    }

    if "`f'" == "Disp" {
        label variable Disp "第一大股东比例/第二至十大股东比例之和"
    }

    if "`f'" == "Dturnt_d" {
        label variable Dturnt_d "日均换手率年度均值差（来源单位保留）"
    }

    if "`f'" == "Dturnt_m" {
        label variable Dturnt_m "月换手率年度均值差（来源单位保留）"
    }

    if "`f'" == "income_annual" {
        label variable revenue "年度营业收入（来源CSV）"
        label variable net_profit "年度净利润（来源CSV）"
    }

    if "`f'" == "income_quarterly" {
        label variable revenue "报表期间营业收入（可能为累计值）"
        label variable net_profit "报表期间净利润（可能为累计值）"
        label variable Accper_s "来源报表日期字符串"
        label variable ym "来源报表年月字符串"
        gen double report_date = daily(Accper_s, "YMD")
        format report_date %tdCCYY-NN-DD
        label variable report_date "来源报表日期"
        assert !missing(report_date)
        assert year == year(report_date)
        assert ym == substr(Accper_s, 1, 7)
        isid stock report_date
        * 包含1月1日记录；保留原始期间，不冒充单季度ROE。
        * 此表不是公司年度唯一键，单独保存，不直接按stock year合并。
    }

    if "`f'" == "MB" {
        label variable MB "总市值/全部所有者权益（来源CSV）"
        label variable MB_parent "总市值/归母权益（来源候选）"
        label variable MB_ta "总市值/总资产（来源候选）"
    }

    if "`f'" == "province" {
        rename PROVINCE province
        rename PROVINCECODE province_code
        replace province = strtrim(province)
        label variable province "公司省份（来源CSV）"
        label variable province_code "省份代码（来源CSV）"
    }

    if "`f'" == "ROA" {
        rename ROA ROA_csv
        label variable ROA_csv "来源ROA（与第10步ROA并列核对）"
    }

    if "`f'" == "Zscore_STPT" {
        rename ZScore Zscore
        label variable Zscore "财务困境ZScore（来源数据库指标）"
        label variable STPT "ST/PT标记（来源CSV，本步不筛选）"
        label variable IsSuspend "暂停上市标记（来源CSV，本步不筛选）"
    }

    if "`f'" != "income_quarterly" {
        * 键重复时停止核对，不用duplicates drop随意留一条。
        isid stock year
        sort stock year
    }
    else {
        sort stock report_date
    }
    compress
    save "控制变量DTA/`f'.dta", replace
}
