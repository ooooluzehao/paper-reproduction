version 18.0
clear all
set more off

* 从本do所在目录运行；只生成省份年度表，不合并现有公司表。
foreach f in 市场化指数_原表年份 市场化指数_2007至2018匹配模板 {
    import delimited using "`f'.csv", ///
        varnames(1) case(preserve) stringcols(_all) encoding("utf-8") clear
    destring province_code year market_index_raw Index pdf_page book_page, replace
    recast long province_code
    recast int year
    assert !missing(province_code, year)
    isid province_code year
    assert market_index_raw >= 0 if !missing(market_index_raw)
    replace Index = ln(1 + market_index_raw) if !missing(market_index_raw)
    capture confirm variable reported
    if _rc != 0 {
        gen byte reported = 1
    }
    else {
        destring reported, replace
    }
    label variable province "规范省份名称"
    label variable province_code "省级六位行政代码（匹配附加）"
    label variable year "指数实际年份，非报告出版年份"
    label variable market_index_raw "原表市场化总指数（分）"
    label variable Index "市场化总指数加1取自然对数"
    label variable reported "原表有指数值=1，原表未列年份=0"
    label variable pdf_page "来源PDF页码"
    label variable book_page "来源书内页码"
    label variable source_table "来源表编号"
    format market_index_raw %9.2f
    format Index %12.6f
    assert reported == !missing(market_index_raw)
    sort province_code year
    save "`f'.dta", replace
}
