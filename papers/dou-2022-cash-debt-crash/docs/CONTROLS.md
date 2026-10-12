# 控制变量进度：09—13阶段

## 已生成并合并的控制变量

此次同步读取原项目09文件夹，发现sizegrowth.do已修正为保留stock、year、Size、GROWTH，并把Ret计算合并代码接在同一个do后半段。当前添加Ret.dta确实包含三项控制变量，之前“缺少Size/GROWTH”的描述已过时。

| 变量 | 当前公式和数据 | 当前合并文件缺失数 |
| --- | --- | ---: |
| Size | ln(当年年末total_assets)，资产为正且非缺失 | 2 |
| GROWTH | (当年总资产－上一自然年总资产)/上一年总资产，上一年资产为正 | 1,950 |
| Ret | 当年现金红利再投资个股周收益率ri的算术平均，忽略缺失 | 481 |

添加Ret.dta共29,108行，无重复stock/year；三项均非缺失有27,099行。缺失记录暂保留，不能把这个数当作完整回归样本，因为X/Y与其余控制变量、行业和ST/PT还需检查。

## 文件逐项用途

| 文件 | 用途 |
| --- | --- |
| sizegrowth.do | 一个do依次生成Size/GROWTH并合并，再生成Ret并合并 |
| 资产负债表.dta | 完整历史年度报表，保留早期年份以计算滞后总资产 |
| 合并核心变量完毕缺少控制变量.dta | 已匹配DH和次年崩盘风险的基表 |
| 添加sizegrowth.dta | 基表加Size、GROWTH |
| Ret_公司年度.dta | 2007–2018公司当年Ret及Ret_Nweek，共28,793行 |
| 添加Ret.dta | 基表加Size、GROWTH、Ret及Ret_Nweek |

所有这些文件均随本次提交同步，dta使用LFS。仓库版do仅将本机绝对周收益率路径改为相邻阶段的相对路径，并修正过时注释；统计公式、筛选与合并未改动。源代码校验值见source-manifest.json。

## 逐段执行与原因

从本篇code/09添加控制变量目录运行：

```stata
clear all
do "sizegrowth.do"
```

1. **打开完整资产负债表并xtset stock year**：L.total_assets找上一自然年，必须先保留2006等前期再合并；最终分析表若存在年份缺口，会丢掉本来可计算的增长率。
2. **生成Size和GROWTH**：Size取自然对数，降低规模偏态；增长率衡量资产扩张，不是资产绝对差。条件排除非正分母或缺失，不用隔两年的余额冒充上一年。
3. **keep stock year Size GROWTH**：只保留键和两项新增变量。旧写法只keep键会把新变量删掉，当前已修正。
4. **以财务表作master与核心表1:1合并**：删除_merge==1，去掉只有财务没有核心X/Y的记录；保留核心表独有及匹配记录，使核心样本不因为控制变量缺失立即减少。drop _merge避免下一次merge同名冲突。
5. **保存添加sizegrowth.dta后clear all**：下一段必须重新打开原始周数据，不能拿年度表仅保留的一周、或risk_year的周值直接计算当年Ret。
6. **周收益率改名、type==8排除、stock转数值、提取实际year**：year不减1，Ret属于解释变量当年2007–2018，而结果风险属于次年。仅使用已确认所需的Week、Week1、Week2范围；不用Week3。
7. **egen Ret=mean(ri)、Ret_Nweek=count(ri)**：年度算术平均周收益率，不是复利年度收益率、不是特有收益率W均值；Ret_Nweek记录均值实际使用的周数，此步没有额外要求Ret至少30周。
8. **每stock/year保留一行并保存Ret表**：先计算全年均值再缩成年度表，否则先保留一周就不能代表全年。
9. **从添加sizegrowth.dta合并Ret**：keep(master match)保留全部原核心行，不保留仅Ret表有的行；keepusing(Ret Ret_Nweek)只带入这两列，不覆盖其他控制变量。当前do没有显式gen(Ret_merge)，默认生成_merge；这不改变均值与匹配。
10. **另存添加Ret.dta**：保留前一阶段结果便于比较与回溯，不因为缺Ret而立即删行。原上传dta未包含_merge，重跑原do可能带该审核标记；经济变量相同不意味着二进制文件逐字节相同。

## 校验结果与版本

本次对当前文件重新核验：Size/GROWTH与完整资产负债表按上述公式重算结果一致，Ret与Ret_公司年度.dta按stock/year匹配结果一致；三张年度表键无重复。do未在此次同步中通过Stata执行，上传的是现有结果，非声称全流程刚刚重跑。

## 已新增ROA（10阶段）

ROA使用同年A类合并报表全年net_profit/年末total_assets。最新添加ROA.dta含Size、GROWTH、Ret、ROA，29,108行，ROA缺失2行。10文件夹包含原始Excel、全部整理数据、两份do和年度结果，已同步到GitHub。详细do解释见本篇README第9步9.3节。

## 剩余控制变量进度（第12阶段，2026-10-12）

第11阶段已从第10步主表合并MB、Dturnt、Big4、Zscore、Disp，以及ST/PT、暂停状态、省份、经营现金流和来源利润。主表全部29,108行保留，未删控制变量缺失、未缩尾、未做行业或ST/PT样本筛选。已有ROA不覆盖；来源ROA单列核对。

| 状态 | 变量 | 当前基础及下一步 |
| --- | --- | --- |
| 已有并保留 | Size、GROWTH、Ret、ROA | 第10步主表原字段逐值未变 |
| 已合并来源指标 | MB、Dturnt、Big4、Zscore、Disp | 已有年度CSV；Dturnt=Dturnt_d，Dturnt_m及MB候选版本同时保留 |
| 来源值已合并，正式计算另做 | DA、Abacc | 当前命名DA_csv、Abacc_csv；来源仅计算绝对应计额/资产及其滞后合计，正式模型需另估计并补足历史年份 |
| 已构造并合并 | Index | 第12阶段先建完整省份年度总指数，再匹配公司同年省份；Index=ln(1+market_index_raw)，29,108条全部非缺失 |
| 已构造并合并 | ROEGROWTH | 单季度ROE相邻季度增长率年度均值，保留有效季度数；主表缺失1,467条 |
| 补充合并 | ROE | 全年合并净利润/年末权益的数据库ROE A，主表缺失300条，不自动加入基准模型 |

正式DA/Abacc若使用前三期，应准备足够的前期数据，并按自然年度核对滞后，不用上一条记录替代上一自然年。上述“已合并”只说明来源表进入新主表，不代表已经完成论文全部样本与回归。具体操作见 [第11阶段说明](../code/11添加剩余控制变量/控制变量与缩尾/README_Stata整理与合并.md)。

## Index完成（12阶段）

最新主表为`code/12添加市场化指数/添加Index.dta`，新增Index在29,108条公司年度记录中全部非缺失，旧主表变量逐值不变。该阶段之后继续完成ROE/ROEGROWTH；正式DA/Abacc仍未完成；样本筛选、删除缺失和缩尾仍未执行。详细步骤见 [第12阶段说明](../code/12添加市场化指数/README_公司指数合并.md)。

## ROE与ROEGROWTH完成（13阶段）

最新主表`code/13roegrowth/添加ROE与ROEGROWTH.dta`，29,108行，旧字段不变。ROE与ROEGROWTH分别缺失300和1,467条，全部保留。详细计算见[第13阶段说明](../code/13roegrowth/README.md)。剩余正式DA/Abacc需另做；后续任务按本篇README第10步依次处理回归变量缺失、J/K行业、年度ST/PT、连续变量缩尾和基准回归。本次未执行这些任务。

## 第14阶段基准模型已运行

基准控制变量为Size、MB、ROA、Ret、Dturnt、GROWTH、Big4、Index、Zscore、Disp、DA_csv、Abacc_csv。来源DA/Abacc按用户选择暂用，并注明；正式计算仍待完成。ROEGROWTH按论文盈余管理机制检验说明不入本次基准模型。当前按模型删缺失、剔除J/K和ST/PT、全样本连续变量默认1%/99%缩尾后14,572条，公司与年份×行业固定效应回归实际14,405条。
