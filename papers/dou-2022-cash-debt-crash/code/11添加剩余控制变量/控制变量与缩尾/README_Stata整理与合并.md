# 第11阶段：控制变量CSV清理与合并（不删缺失、不缩尾）

本阶段从第10步 `添加ROA.dta` 出发，以 `stock year` 为键合并用户提供的控制变量。Stata MP 18已实际运行三份do，结果保留29,108条公司年度记录，全部原主表字段未变。原始CSV和已有处理脚本保持原样。

## 运行入口

在Stata切换到本说明所在目录后执行：

```stata
do "00运行整理与合并.do"
```

原项目目录为 `D:/存贷双高论文复现/11添加剩余控制变量/控制变量与缩尾`；仓库中对应 `papers/dou-2022-cash-debt-crash/code/11添加剩余控制变量/控制变量与缩尾`。主表使用相对路径 `../../10添加利润表相关控制变量/添加ROA.dta`，两处都可运行。

## do文件逐步说明

| 文件 | 做什么 | 为什么这样做 |
| --- | --- | --- |
| 00运行整理与合并.do | 依次运行01和02 | 一次完整执行，避免漏掉清理结果 |
| 01控制变量CSV整理.do | 导入14张未缩尾的单项/辅助CSV，统一数值类型、重命名、中文标签，另存到控制变量DTA | allstring保留原始导入内容，再destring；不加force，意外文本会报错而非静默变为缺失 |
| 02合并剩余控制变量.do | 从第10步主表依次merge，保留匹配标记，保存新主表 | keep(master match)保留全部原主表行；匹配失败不删除，不添加只有控制变量来源才有的行 |

`case(preserve)`保留Big4、MB等字段大小写；stock转数值并按六位显示，year保持解释变量当年，不与risk_year匹配。CSV已经包含year，无需再次截日期造年度。年度表使用`isid stock year`核对唯一性，不自动删除重复行。

季度利润另按`stock report_date`核对，并保留原日期、year、ym及所有期间。它包含1月1日等记录，不能直接按公司年度merge，也不在这一步当作单季度ROE。省份保持字符串，省份代码转数值。

## 文件与字段安排

| 来源CSV | 整理/合并字段 | 处理安排 |
| --- | --- | --- |
| Big4.csv | Big4 | 来源国际四大标记，检查0/1或缺失 |
| Disp.csv | Disp | 来源股权分散指标，保留原值 |
| MB.csv | MB、MB_parent、MB_ta | 主指标和两个候选指标同时保留 |
| Dturnt_d.csv / Dturnt_m.csv | Dturnt_d、Dturnt_m | 两个来源值都保留，新增Dturnt=Dturnt_d，不改变单位 |
| Zscore_STPT.csv | Zscore、STPT、IsSuspend | ZScore改为Zscore；本次不依据ST/PT、暂停状态删行 |
| DAAbacc.csv | DA_csv、Abacc_csv | 按用户选择合并来源值，正式DA/Abacc另做 |
| DA.csv / DA_detail.csv | DA_csv及来源明细 | 独立清理保存，主表用DAAbacc.csv避免重复覆盖 |
| province.csv | province、province_code | PROVINCE/PROVINCECODE改名，用于后续Index匹配 |
| ROA.csv | ROA_csv | 原主表ROA不覆盖，ROA_csv_diff用于核对 |
| CFO_annual.csv | cfo | 合并来源年度经营现金流，供后续正式DA使用 |
| income_annual.csv | revenue_csv、net_profit_csv | 保留原主表net_profit，来源年度利润另命名 |
| income_quarterly.csv | 日期、利润、收入及year/ym | 单独保存，暂不按年度直接合并 |
| analysis_sample.csv | 仅归档 | 来源说明表明已删缺失并缩尾，不能作本次主表或控制变量来源 |

来源DA的生成脚本计算的是`abs(net_profit-cfo)/TA`，没有估计可操纵应计盈余模型；来源Abacc由上述值滞后三条记录求和。因此以DA_csv/Abacc_csv保存，不能声称已经完成论文DA/Abacc。此步骤不修改这些来源值，不重新估计。

各次merge保留独立审核变量：值1表示主表未匹配，值3表示匹配。匹配成功与指标非缺失是两件事，不能根据match标记直接认为数据完整。对于原有ROA，25,978条双方有效记录的ROA_csv_diff全部为0。

## 输出和核验

- `控制变量DTA/`：14份清理后的Stata表，与各来源CSV记录数、数值和文本核对一致。
- `添加剩余控制变量_未删缺失未缩尾.dta`：29,108行，公司年度键唯一，原主表全部字段逐值未变。
- `整理合并核验.json`：实际运行工具、来源表行数、各次merge匹配数及缺失数。

主表新增字段缺失数：MB 4,386；Dturnt 5,282；Big4 3,128；Zscore 3,833；Disp 3,131；DA_csv 3,130；Abacc_csv 11,751；省份未匹配3,128。以上记录全部保留。Stata缺失字符串是空字符串，省份缺失计数需包括空字符串。

检查包含原主表逐值比较、14张清理表逐列比较、11次左合并独立重算、风险年份相差1和公司年度键唯一。没有重跑第1—10阶段。

## 下一步

仍需正式构造DA和Abacc；Index已有省份但缺对应年度分省市场化指数；ROEGROWTH仍缺季度权益/单季度ROE及年度汇总规则。样本筛选、缺失处理和缩尾按用户指示留到后续。目录名称含“缩尾”，不表示这些新do执行了缩尾。
