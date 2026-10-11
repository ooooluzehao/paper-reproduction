# 《上市公司“存贷双高”异象与股价崩盘风险》复现指南

窦超、原亚男、白学锦（2022），《中国工业经济》2022年第4期，174–192页。DOI：10.19581/j.cnki.ciejournal.2022.04.004。

## 已上传什么，复现到哪里

**本篇的数据已经上传，不需要另找本项目已有的Excel或dta。** Git LFS发布了原始Excel、阶段性dta和两个ZIP，普通Git保存字段说明；共40个数据及说明文件，按路径合计约3.13 GB，LFS内容去重后约2.45 GB。

| 内容 | 仓库位置 |
| --- | --- |
| 原始个股周收益率全部分片、市场周收益率、字段说明 | [code/01原始数据](code/01原始数据/) |
| 导入用Excel和分片dta | [code/02数据整理](code/02数据整理/) |
| 合并后的收益率文件 | [code/03合并个股周收益率与市场周收益率](code/03合并个股周收益率与市场周收益率/) |
| 回归前、回归完成、年度崩盘风险数据 | [code/04计算股市崩溃](code/04计算股市崩溃/) |
| 资产负债表Excel和年度dta | [code/05处理资产负债表数据](code/05处理资产负债表数据/) |
| 历史行业Excel和整理结果 | [code/06处理公司行业代码](code/06处理公司行业代码/) |
| 行业匹配、存贷双高计算结果 | [code/07筛选存贷双高公司](code/07筛选存贷双高公司/) |
| 核心X、Y匹配结果 | [code/08合并XY变量](code/08合并XY变量/) |
| 原项目已有两个压缩包 | [data-archives](data-archives/) |
| 每个文件的大小和SHA-256 | [数据清单](docs/data-manifest.json) |

已完成核心变量构造和匹配；**完整样本筛选、控制变量、缩尾和论文回归尚未完成**。数据是2026-10-11上传的现有快照，不代表所有输出都由同一版脚本刚刚重跑。论文PDF没有上传。方法待核对处列在 [已知问题](docs/KNOWN_ISSUES.md)。

## 先把完整数据下载到电脑

安装Git及Git LFS后，在终端运行：

```bash
git lfs install
git clone https://github.com/ooooluzehao/paper-reproduction.git
cd paper-reproduction
git lfs pull
```

如果已经克隆过仓库：

```bash
git pull --ff-only
git lfs pull
```

**为什么要LFS：**普通GitHub文件上传有大小限制；本项目有100 MB以上的文件。Git保存小的LFS指针，实际二进制数据通过LFS获取。不要把百余字节的指针误当成真正的Excel或Stata数据。网页“Download ZIP”不保证提供完整LFS内容，优先使用上面的克隆方式。

检查：

```bash
git lfs ls-files
git lfs fsck
```

也可核对数据清单的文件大小；需要严格核验时计算SHA-256。已有ZIP是历史归档，不要解压覆盖阶段目录，二者版本可能不同。

## 环境、目录和两种使用方式

- Stata 16或以上；Python 3.11或兼容版本。
- Python回归依赖NumPy、pandas：在本篇目录执行 `python -m pip install -r requirements.txt`。
- 已有脚本使用相对文件名，Stata运行前必须切换到对应阶段目录。
- Python脚本以自身所在目录寻找输入和写出结果，不要求当前终端与脚本同目录。
- 本次文档更新没有修改统计脚本，也没有覆盖数据。

下面示例假定仓库克隆到 `D:/codex项目/paper-reproduction`，请替换为你的实际位置。Stata中可用：

```stata
global paper "D:/codex项目/paper-reproduction/papers/dou-2022-cash-debt-crash"
```

之后每阶段使用 `cd "$paper/code/对应目录"`。这个全局宏只用于下面的操作说明，现有do文件仍使用相对文件名。

**如果只想接着当前成果做：**可从第9步已有的 `合并核心变量完毕缺少控制变量.dta` 开始准备控制变量，但要先处理行业与样本口径问题。

**如果要从头重现：**按第1–9步执行；下游目录虽已有上传的数据副本，重跑后必须用新的上游输出覆盖相应副本，避免混用旧结果。保存前可先备份现有结果。没有一键入口，不应把所有do文件任意串起来运行。

## 第1步：整理并纵向合并个股周收益率

**位置与脚本：** [02数据整理](code/02数据整理/)，先 `数据整理.do`，再 `数据合并.do`。

**输入：** TRD_Week.xlsx、编号分片、TRD_Weekm.xlsx。**输出：** 分片dta、`个股周收益率合并.dta`、`市场周收益率合并.dta`。

**为什么这样做：**数据库导出的同一张周个股数据被拆成多个Excel。各分片是相同变量、不同记录，需要用append纵向接起来；市场数据是另一张表，先单独保存，后面通过键匹配。这里不应对个股分片做横向merge。

```stata
cd "$paper/code/02数据整理"
clear all
do "数据整理.do"
do "数据合并.do"
use "个股周收益率合并.dta", clear
isid 证券代码 交易周份
```

保留证券代码、交易周份、周开盘日期、再投资周收益率、总市值和市场类型，是为后面匹配及变量构造准备键和收益率。`isid`通过时不显示结果，发现重复或键缺失时会报错。

**本次数据范围已确认：**只使用TRD_Week.xlsx、TRD_Week1.xlsx、TRD_Week2.xlsx。项目提供者已确认TRD_Week3.xlsx不属于本次需要的数据，保留在上传快照供查看，但不导入、不追加。循环 `1/2` 是有意选择，不是漏导入，不需要为了包含Week3重跑。

### 本步do文件逐段说明

`数据整理.do` 的关键操作如下：

```stata
import excel "TRD_Week.xlsx", sheet("sheet1") firstrow
keep 证券代码 周开盘日期 交易周份 考虑现金红利再投资的周个股回报率 周个股总市值 市场类型
save "TRD_Week.dta", replace
```

- `firstrow`把Excel首行作为变量名，而不是一条公司记录。
- `keep`只保留指定变量，减少后面处理的内存和文件大小；这里不筛公司或周。
- `save ..., replace`将内存数据保存为Stata格式，允许覆盖同名结果。

```stata
forvalues i = 1/2 {
    import excel "TRD_Week`i'.xlsx", sheet("sheet1") firstrow clear
    keep 证券代码 周开盘日期 交易周份 考虑现金红利再投资的周个股回报率 周个股总市值 市场类型
    save "TRD_Week`i'.dta", replace
    clear all
}
```

`i`先为1再为2，反引号和单引号将其展开为实际文件名。`import ..., clear`清掉内存中的上一张表，避免“data in memory would be lost”。循环只覆盖所需Week1、Week2，不包含Week3。

`数据合并.do`先打开Week，再把两个分片追加到下方：

```stata
use "TRD_Week.dta", clear
forvalues i = 1/2 {
    append using "TRD_Week`i'.dta"
}
save "个股周收益率合并.dta", replace
```

`append`增加行数，不通过证券代码配对；不同分片字段应一致。若同一公司周重复出现，后面的`isid`会报错，需要核对分片交集，而不是直接删除一条。

## 第2步：把市场周收益率匹配到个股

**位置与脚本：** [03合并个股周收益率与市场周收益率](code/03合并个股周收益率与市场周收益率/)，`合并市场收益率.do`。

**输入：**上一步两张合并表；本目录已上传现有副本。**输出：** `周收益率.dta`。

**为什么用m:1：**同一市场、同一周有很多个股记录，但市场表只能有一条收益率。键必须包括交易周份和市场类型，避免把不同市场的收益率混在一起。

```stata
cd "$paper/code/03合并个股周收益率与市场周收益率"
use "市场周收益率合并.dta", clear
isid 交易周份 市场类型
do "合并市场收益率.do"
isid 证券代码 交易周份
```

**为什么只保留 `_merge==3`：**按项目提供者说明，部分数据不包含B股，因此不同输入表的覆盖范围并不完全一致。本项目以两表均有记录的样本为匹配范围，只保留成功匹配记录是有意的样本处理，不应将所有未匹配行强行补入。建议在删除前用 `tab _merge` 留下样本筛选记录；它用于解释范围差异，不是要求取消该筛选。`_merge==3`本身不是A股标记，剩余B股仍按后续type条件处理。

### 本步do文件逐段说明

```stata
use "个股周收益率合并.dta", clear
merge m:1 交易周份 市场类型 using "市场周收益率合并.dta"
keep if _merge == 3
drop _merge
save "周收益率.dta", replace
```

| 命令 | 具体作用与原因 |
| --- | --- |
| `use` | 个股表作master，保留公司周层级 |
| `merge m:1` | 当前很多公司周记录，共享using中的同一市场周收益率 |
| `_merge==1` | 只有个股表有这个市场周键 |
| `_merge==2` | 只有市场表有这个市场周键 |
| `_merge==3` | 两边找到相同市场周键，并成功添加市场变量 |
| `keep if _merge==3` | 按本项目覆盖范围说明保留交集，排除不能配对的记录 |
| `drop _merge` | 删除本次匹配标记，避免下一次merge时同名冲突 |

特别注意：这个键没有证券代码，因为市场表不是每家公司一条；后面的财务表合并才会按stock、year进行。

## 第3步：准备时间变量和市场收益率前后两期

**位置与脚本：** [04计算股市崩溃](code/04计算股市崩溃/)，`计算股价崩溃回归前.do` 的准备部分。

**输入：** `周收益率.dta`。**输出：**供Python使用的 `周收益率_回归前.dta`，仓库已包含现有文件。

**为什么改变量名：**将证券代码、交易周份、个股收益率、市场收益率改为stock、weekstr、ri、rm，减少重复输入；type保留市场信息。本份数据type=8对应B股记录，脚本排除此类型，目标是沪深A股。

**为什么处理时间：**从例如 `2008-03` 中提取year=2008、weekno=3；tw按实际观察到的市场周共同排序，作为前后期索引。它不是原始日期，也不会自动补缺失市场周。必须确认源数据没有漏掉实际有交易的整周。

**为什么加L/F：**扩展市场模型加入市场前后两期收益率，以处理个股与市场交易不同步。不能简单把上一条个股记录当上一周，因为公司可能停牌。现有做法用公司面板的L/F，再由同市场同周其他公司补值；目标周仍可能找不到，必须检查。

**为什么最后才截年份：**先在较完整期间生成前后期，可以保留2008年初和2019年末需要的跨年市场数据，然后限制风险计算年份为2008–2019。

操作：

```stata
cd "$paper/code/04计算股市崩溃"
```

打开 `计算股价崩溃回归前.do`，**只选中从开头到 `egen long firmyear = group(stock year)` 的部分运行**。不要运行后面的慢速Stata回归循环，然后执行：

```stata
save "周收益率_回归前.dta", replace
```

检查每市场每周的rm及各前后期变量是否一致；还应与独立市场表对应目标周比较，仅比较组内一致性不够。

### 本步do文件逐段说明

```stata
rename 证券代码 stock
rename 交易周份 weekstr
rename 考虑现金红利再投资的周个股回报率 ri
rename 考虑现金红利再投资的周市场回报率流通市值加权平均法 rm
rename 市场类型 type
drop if type == 8
isid stock weekstr
```

`rename`只改名字，不改数值。`drop if`删的是特定市场记录；与前一步交集筛选不同，不能用`_merge==3`替代。`isid stock weekstr`要求公司周唯一且键不缺失。

```stata
gen int year = real(substr(weekstr, 1, 4))
gen byte weekno = real(substr(weekstr, 6, 2))
egen long tw = group(year weekno)
egen long id = group(stock)
xtset id tw
```

`substr`截字符串，`real`转成数值。`int/byte/long`是存储类型。`egen group`为不同组合分配编号，所有公司同一周共享tw，id则标识公司。`xtset`使L/F按时间键寻找记录，而非按当前行顺序机械移动。

```stata
gen double rm_l2 = L2.rm
gen double rm_l1 = L.rm
gen double rm_f1 = F.rm
gen double rm_f2 = F2.rm
foreach v in rm_l2 rm_l1 rm_f1 rm_f2 {
    bysort type tw: egen double fill = max(`v')
    replace `v' = fill if missing(`v')
    drop fill
}
```

`L/L2`为前1/2个tw，`F/F2`为后1/2个tw。公司没有该周记录时结果缺失。foreach依次处理四列，取同市场同周已有的非缺失值补齐。这里的`max`是提取共同值，前提是组内非缺失值一致；不是按最高收益率选择市场。组内全缺失时仍缺失。

```stata
keep if inrange(year, 2008, 2019)
egen long firmyear = group(stock year)
```

`inrange`包含2008和2019；firmyear为每公司年份生成编号，仅为循环方便，不替代原stock/year键。

## 第4步：按公司和年份回归，用Python提取残差

**脚本：** [Python公司年度回归.py](code/04计算股市崩溃/Python公司年度回归.py)。**输入：**同目录 `周收益率_回归前.dta`。**输出：** `周收益率_回归完成.dta`，以及运行时生成的 `Python回归核验.json`。

在终端从本篇目录运行：

```bash
python -m pip install -r requirements.txt
python "code/04计算股市崩溃/Python公司年度回归.py"
```

**为什么分公司年份回归：**需要将市场共同波动从每家公司每年的周收益率中分离。不同公司、年份的市场敏感度不同，不能把所有公司一次性混合回归。

当前模型为：

```text
ri = 常数项 + b1*rm_l2 + b2*rm_l1 + b3*rm + b4*rm_f1 + b5*rm_f2 + epsilon
```

当前rm采用流通市值加权、考虑现金红利再投资的对应市场收益率。论文正文未完整交代加权与模型细节，这是待核对实现。

**为什么用Python：**先按stock、year取得各组行位置，每组只处理几十条周记录，避免原Stata循环不断扫描整张表。Python使用普通最小二乘及常数项，剔除六个回归变量中有缺失的记录；完整观测至少30条，矩阵秩为6时生成残差。

| 输出变量 | 含义 |
| --- | --- |
| epsilon | 实际个股收益率减模型预测值，每周一个残差 |
| Nreg | 公司年份实际参与回归的周数 |
| reg_ok | 至少30条完整记录且模型满秩的公司年份标记 |

程序会重置中断前的部分结果，保留其他输入列和行顺序，核验残差均值、与解释变量正交性、抽查QR解及保存后读回一致性。语法检查不等于实际回归验证；数值一致也不代表作者口径完全相同。

### 原Stata回归循环为何这样写

采用Python时不必再运行这一循环，但理解它有助于检查两种实现是否一致：

```stata
gen double epsilon = .
gen int Nreg = .
gen byte reg_ok = 0
quietly summarize firmyear, meanonly
local groups = r(max)
```

先创建结果列：残差和周数为缺失，成功标记为0。`summarize`取得最大分组编号，保存到局部宏groups。定义宏和整个循环需在同一次do执行中运行，否则单独选中循环时groups可能失效。

循环的每一轮只处理一个firmyear：

```stata
quietly count if firmyear == `g' ///
    & !missing(ri, rm_l2, rm_l1, rm, rm_f1, rm_f2)
```

先数完整回归记录，六个变量任一个缺失就不计数。`quietly`只隐藏输出，不跳过计算。count的结果在r(N)中；至少30条才进入regress。

```stata
capture quietly regress ri rm_l2 rm_l1 rm rm_f1 rm_f2 ///
    if firmyear == `g'
```

最后的if不可省略：count没有删除其他组，省略会每轮用全表重复回归。`capture`允许单组回归失败后继续；`_rc==0`意味着上一条命令成功。`e(N)`保存实际回归周数，`e(rank)==6`检查五个解释变量及常数项没有秩亏。

```stata
predict double resid_tmp if e(sample), residuals
replace epsilon = resid_tmp if e(sample)
replace reg_ok = 1 if firmyear == `g'
drop resid_tmp
```

`e(sample)`限定真正参与当前回归的周；`residuals`要求残差，不加它默认是预测值。将残差填回总结果列后删除临时列，让下一轮可以重新生成。Python的按组行位置取数、最小二乘和回填对应这些操作。

## 第5步：计算公司年度NCSKEW和DUVOL

**脚本：** [计算股价崩溃回归后.do](code/04计算股市崩溃/计算股价崩溃回归后.do)。**输入：** `周收益率_回归完成.dta`。**输出：** `崩盘风险.dta`。

```stata
cd "$paper/code/04计算股市崩溃"
clear all
do "计算股价崩溃回归后.do"
```

**为什么转换残差：**当前实现用 `W=ln(1+epsilon)` 表示公司特有周收益率。只有epsilon>-1才可以取对数，否则W缺失。Nweek统计非缺失W，因此可能小于Nreg。

**两个指标怎样计算：**按公司和风险年份计算，n为有效W周数。当前公式直接使用W的平方、立方和，没有另行中心化。

```text
NCSKEW = -n*(n-1)^(3/2)*ΣW³ / [(n-1)*(n-2)*(ΣW²)^(3/2)]
DUVOL  = ln[(nu-1)*ΣdownW² / ((nd-1)*ΣupW²)]
```

下跌周指W低于公司年度平均W，上涨周指W大于或等于该平均值，并非原始个股收益率小于或大于0。nd、nu为两组周数。两指标均为公司年度变量，同公司同年周行上的值相同，因此最终每公司每年只保留一行。

**当前异常处理：**脚本要求Nweek>=30且Ninvalid==0，意味着一个异常残差就使整个公司年份指标缺失。这不是论文正文明确要求。若决定仅忽略异常周，需要修改并记录选择，不能默默改变。

**为什么前推一年：**解释变量在2007–2018年，结果变量对应2008–2019年。脚本保存原始risk_year，再令year=risk_year-1，使2008年的风险和2007年的财务数据按stock、year合并。FNCSKEW/FDUVOL只是已完成时间对齐的指标名，后面不再前推。

检查：

```stata
isid stock year
assert risk_year == year + 1
summarize FNCSKEW FDUVOL, detail
count if missing(FNCSKEW, FDUVOL)
```

统计必须在每公司年份一行后做，避免将年度指标按周重复加权。

### 本步do文件逐段说明

```stata
gen byte invalid = (epsilon <= -1) if !missing(epsilon)
bysort stock year: egen Ninvalid = total(invalid)
gen double W = ln(1 + epsilon) if epsilon > -1 & !missing(epsilon)
bysort stock year: egen Nweek = count(W)
bysort stock year: egen Wmean = mean(W)
```

括号中的比较成立记1，否则0；残差缺失保持标记缺失。`total(invalid)`数异常周，`count(W)`数可取对数的周，`mean(W)`算年度平均特有收益率。egen结果复制到组内每行，不会把周数据自动合并成年度数据。

```stata
gen byte eligible = reg_ok == 1 & Nweek >= 30 & Ninvalid == 0
gen double W2 = W^2
gen double W3 = W^3
bysort stock year: egen sumW2 = total(W2)
bysort stock year: egen sumW3 = total(W3)
```

eligible只是标记，未删记录。W2/W3分别平方、立方，组内加总为指标公式准备分子分母。`double`减少小数舍入误差。Nreg>=30已在回归中检查，但异常残差转换后Nweek可能减少，因此两者不是同一个条件。

计算公式中的`sumW2>0 & sumW2<.`同时排除零与缺失：Stata的数值缺失比普通数值大，仅写`>0`不能排除缺失。

```stata
gen byte down = (W < Wmean) if !missing(W)
gen byte up = (W >= Wmean) if !missing(W)
bysort stock year: egen nd = total(down)
bysort stock year: egen nu = total(up)
gen double downW2 = W2 if down == 1
gen double upW2 = W2 if up == 1
```

按年度W均值划上下组，缺失W不划组；计数是各组有效周数。只保留各组平方项，再分别total。DUVOL要求nd/nu都大于1，平方和都为正，避免分母为0或对非正数取对数。

```stata
bysort stock year (tw): keep if _n == 1
keep stock year Nreg Nweek Ninvalid reg_ok NCSKEW DUVOL
rename year risk_year
gen int year = risk_year - 1
rename NCSKEW FNCSKEW
rename DUVOL FDUVOL
```

`_n`是组内行序号，括号内tw确定保留最早周；年度结果本来相同，因此不做平均或求和。保留必要年度列后进行一次年份对齐。股票市场交易周数据不再是最终分析单位。

## 第6步：把资产负债表整理为公司年度数据

**位置与脚本：** [05处理资产负债表数据](code/05处理资产负债表数据/)，`数据整理.do`。**输入：**FS_Combas.xlsx。**输出：** `资产负债表.dta`。

```stata
cd "$paper/code/05处理资产负债表数据"
do "数据整理.do"
isid stock year
tab year
tab report_type
```

**为什么重命名和转数值：**cash、short_debt、total_assets分别对应货币资金、短期借款和资产总计。金额必须为数值才能计算比例；stock在此转为数值，后面其他表也要统一类型。

**为什么提取年份：**accper是字符串日期，如2006-12-31，截前四位再转数值得到year；month和day用于筛选报告期。

**为什么保留12月31日：**资产负债表是某时点存量，季度数据不能求和为年度数据；研究用年度财务变量，选年末余额。

**为什么选A类合并报表：**CSMAR的A=合并、B=母公司。核心DH按上市公司合并财务口径计算，避免同公司同年两个报表类型重复或混用。母公司数据在进一步分类分析可能另有用途，不能把二者相互替代。

**为什么保留2006及更早数据：**判断2007是否连续两年双高，需要2006。Abacc涉及滞后DA还可能需更早期数据。计算完滞后之前不要先删除2007年前记录。缺失金额不能无依据填0。

### 本步do文件逐段说明

```stata
import excel "FS_Combas.xlsx", sheet("sheet1") firstrow clear
rename 证券代码 stock
rename 证券简称 shortname
rename 统计截止日期 accper
rename 报表类型 report_type
rename 货币资金 cash
rename 短期借款 short_debt
rename 资产总计 total_assets
```

这是名称映射，不构造经济变量；其余应收款、固定资产、权益等重命名为后续控制变量准备字段。不要因为cash改了名字就把缺失值填0。

```stata
destring stock, replace
gen int year = real(substr(accper, 1, 4))
gen byte month = real(substr(accper, 6, 2))
gen byte day = real(substr(accper, 9, 2))
```

destring将代码字符串转数值，000001变成1；year是报告期年份，不是网页下载年。按本文件YYYY-MM-DD格式截取月份日，不能照搬到其他日期格式。

金额转换语句`destring ..., replace ignore(",")`忽略千位分隔逗号；已是数值的列不会变成另一种财务口径。不要加force去吞掉异常文本。

```stata
keep if month == 12 & day == 31
keep if report_type == "A"
isid stock year
sort stock year
save "资产负债表.dta", replace
```

依次限定年末、合并口径，然后确认唯一性；`sort`只排列，不删数据。筛选后如键仍重复，应检查来源和报表版本，而不是任意保留第一条。

## 第7步：整理历史行业并匹配到财务数据

**脚本一：** [06处理公司行业代码/数据整理.do](code/06处理公司行业代码/数据整理.do)，输入STK_LISTEDCOINFOANL.xlsx，输出 `公司行业代码.dta`。

```stata
cd "$paper/code/06处理公司行业代码"
do "数据整理.do"
isid stock year
```

脚本保存未带replace；重复运行遇到同名文件时，应检查并在决定覆盖后调整save选项，勿把报错忽略。indcode、indname来自行业代码C、行业名称C，即下载的2012版行业字段。

**脚本二：**将资产负债表和公司行业代码两个新输出放到 [07筛选存贷双高公司](code/07筛选存贷双高公司/)，运行 `merge公司行业代码.do`，输出 `存贷双高计算前.dta`。

```stata
cd "$paper/code/07筛选存贷双高公司"
do "merge公司行业代码.do"
```

**为什么按stock、year做1:1：**每公司每年一张年末财务表、一条行业记录。行业可能变化，要保留历史年份，不能只用今天的行业回填所有年份。

**为什么需要行业：**行业间正常现金和借款水平不同；论文要求两个比例都高于同行业平均水平。此外行业用于剔除金融房地产和构造固定效应。

本项目部分表不包含B股，合并时保留两表交集是有意设计；这里的两次drop等价于仅保留 `_merge==3`。不同合并使用不同键，建议分别记录匹配数量，不把每一条未匹配都自动认定为B股。文件名引号内有尾部空格，应核对实际输出名。合并同名变量时Stata通常优先保留master值，因此最终shortname不能当成已确认的完整ST/PT状态。

### 两个do文件逐段说明

行业整理先限定字段并改名：

```stata
keep 行业代码C 行业名称C 统计截止日期 股票代码 股票简称
rename 股票代码 stock
rename 股票简称 shortname
rename 统计截止日期 accper
rename 行业代码C indcode
rename 行业名称C indname
destring stock, replace
gen int year = real(substr(accper, 1, 4))
drop if year > 2022
```

`行业代码C`中的C是数据库字段后缀，不表示只下载制造业C门类。当前保留到2022是输入清理范围，最终2007–2018取决于与风险表匹配和研究期间，不要把此条件当论文样本年份。

财务与行业匹配：

```stata
use "资产负债表.dta", clear
merge 1:1 stock year using "公司行业代码.dta"
drop if _merge == 2
drop if _merge == 1
drop _merge
```

删2是去掉只有行业没有财务的键，删1是去掉只有财务没有行业的键；与`keep if _merge==3`等价。部分输入不包含B股，项目有意取交集。保留行业缺失公司无法计算对应行业均值，但仍应记录各次合并为何未匹配，不能让补数据或类型错误悄悄混入。

## 第8步：计算行业均值、单年条件和连续两年DH

**脚本：** [筛选存贷双高.do](code/07筛选存贷双高公司/筛选存贷双高.do)。**输入：** `存贷双高计算前.dta`。**输出：** `存贷双高.dta`。

```stata
cd "$paper/code/07筛选存贷双高公司"
do "筛选存贷双高.do"
isid stock year
tab DH, missing
tab industry
```

先计算：

```text
cash_ratio = 货币资金 / 年末资产总计
debt_ratio = 短期借款 / 年末资产总计
```

**为什么除总资产：**转为相对规模，避免大公司仅因规模大就被判断双高。总资产必须为正，分子分母缺失时比例仍缺失。

**为什么算行业均值：**每年度、每行业内分别求各公司cash_ratio和debt_ratio的简单平均，各公司权重相同，缺失不参与对应均值。这不是行业金额总和/行业资产总和。作者加权方式和均值总体尚待确认。

**为什么不只用20%：**论文要求两项比例同时超过20%，且各自超过年度行业均值。单年满足时high_thisyear=1，数据可判断但未满足时为0，缺数据则为缺失。

**为什么要求连续两年：**排除暂时融资或现金积累造成的单年现象。`xtset stock year` 后的 `L.high_thisyear` 指上一自然年，缺口不会当成连续。当前脚本的判断是：

```stata
gen byte DH = .
replace DH = 0 if high_thisyear == 0 | L.high_thisyear == 0
replace DH = 1 if high_thisyear == 1 & L.high_thisyear == 1
```

任意一年明确不满足就可判DH=0；两年都满足才为1；其余无法确定时缺失。连续三年及以上的后续年度也会满足“至少连续两年”。本实现没有回溯标记连续段的第一年。

**为什么保留DH=0：**回归要比较双高和非双高公司，不能仅留下双高公司。金额缺失不等于非双高，应保留不可判断状态。

**重要待核对：**脚本现有行业取非制造业首字母、制造业前两字符C1–C4；这是人为合并口径，非CSRC标准C13等大类，22类还包含J和K，不能据行业数量认定与作者一致。金融房地产、ST/PT及行业均值总体也没有最终确定，当前DH不是已确认的最终论文变量。

### 本步do文件逐段说明

```stata
replace indcode = upper(strtrim(indcode))
gen str3 industry = substr(indcode, 1, 1)
replace industry = substr(indcode, 1, 2) if substr(indcode, 1, 1) == "C"
replace industry = "" if missing(indcode)
```

`strtrim`清理首尾空格、upper统一大写，避免同一行业因字符形式不同被分成两组。str3是最多三字符的字符串存储，不表示变量一定有三位；当前实际制造业截取两字符，因此为C1–C4。这段解释当前实现，并不确认该层级是作者层级。

```stata
gen double cash_ratio = cash / total_assets ///
    if !missing(cash, total_assets) & total_assets > 0
gen double debt_ratio = short_debt / total_assets ///
    if !missing(short_debt, total_assets) & total_assets > 0
bysort industry year: egen double industry_cash_mean = mean(cash_ratio)
bysort industry year: egen double industry_debt_mean = mean(debt_ratio)
```

只在分子分母可用、资产为正时算比例。mean按industry/year独立分组；两个均值分别忽略各自缺失，因此参与两个均值的公司集合可能不同。不能替换为总货币资金/总资产而仍称相同口径。

```stata
replace industry_cash_mean = . if missing(industry)
replace industry_debt_mean = . if missing(industry)
```

防止行业代码缺失的公司被当成一个真正行业并得到均值。Stata的空字符串表示字符串缺失。

`high_thisyear`里的四个比较通过`&`连接：两项都>0.20，两项都>各自行业均值；最后的`if !missing(...)`防止缺失因Stata大小比较规则误判为满足。

`xtset stock year`后才使用L.，明确上一自然年。输出保留全部已有年份，方便审核连续判断；最终解释变量2007–2018由后续匹配限制，不应提前切掉2006。

## 第9步：合并当年DH和次年股价崩盘风险

**位置与脚本：** [08合并XY变量](code/08合并XY变量/)，`merge.do`。**输入：** `崩盘风险.dta`、`存贷双高.dta`。**输出：** `合并核心变量完毕缺少控制变量.dta`。

```stata
cd "$paper/code/08合并XY变量"
do "merge.do"
isid stock year
assert risk_year == year + 1
count if missing(DH, FNCSKEW, FDUVOL)
tab DH, missing
```

**为什么把stock统一为数值：**风险表仍可能使用六位字符串，财务表使用数值，键类型不同无法匹配。000001转为1后仍代表同家公司，所有表必须统一。

**为什么用1:1：**两张表都是每公司每年一行。year已是解释变量年份，合并后形成“当年存贷双高 → 下一年崩盘风险”的对应关系。

**为什么匹配后还检查缺失：** `_merge==3`只表示两边都有键，不表示DH和风险指标都有有效值。现阶段保留缺失便于审核，确定最终控制变量后再统一筛选完整回归样本。

### 本步do文件逐段说明

```stata
use "崩盘风险.dta", clear
destring stock, replace
merge 1:1 stock year using "存贷双高.dta"
keep if _merge == 3
drop _merge
save "合并核心变量完毕缺少控制变量.dta", replace
```

风险数据是master，存贷数据是using。保留3意味着同时具备这两类记录的公司年份，符合本项目按可匹配范围取交集的安排；它不执行数值非缺失筛选，不代替行业或ST/PT剔除，也不自动补控制变量。

例如风险表的一行`stock=1, year=2007, risk_year=2008`，匹配的是财务表`stock=1, year=2007`，表示2007双高状态与2008风险。不能改用risk_year匹配财务，否则经济含义变成同年关系。

## 第10步：补全样本、控制变量和回归（尚未完成）

1. 按已确认的Week/Week1/Week2范围处理收益率，Week3不纳入；继续核对作者行业分组和行业均值总体，如调整，从受影响的上游步骤重算。
2. 按论文剔除金融、房地产、ST/PT，记录是否在均值计算之前筛选及依据；不要随意把所有公司全年或全部历史一起删除。
3. 核对市场模型与异常残差处理；保留相应敏感性比较。
4. 补齐Size、MB、ROA、Ret、Dturnt、GROWTH、Big4、Index、Zscore、Disp、DA、Abacc、ROEGROWTH等控制变量基础数据和附件定义。现有数据只覆盖其中一部分。
5. 每步记录公司年份数，最后按完整回归模型检查缺失。论文17,011是筛选后的样本，不能通过人为删记录凑数。
6. 对最终样本主要连续变量按论文1%/99%缩尾；缩尾调整极端数值，通常不删除观测。作者是否按年缩尾待核对；不要对二元DH随意缩尾。
7. 按论文模型控制公司、年份×行业固定效应，在公司层面聚类标准误。先复现基准，再做进一步分析。
8. 对照论文描述统计、DH比例、系数、标准误和样本数，差异应解释，不应仅因为符号相同就宣布复现完成。

**为什么不能只合并X、Y就回归并解释因果：**控制变量、固定效应和样本选择共同决定可比性；省略它们得到的是另一个模型。次年对齐本身也不能消除所有内生性。

## 检查记录与协作

历史数值核验见 [VALIDATION.md](docs/VALIDATION.md)，待办见 [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md)，数据字段见 [DATA.md](docs/DATA.md)。历史样本数不能直接作为新版本的固定验收值。

每次修改方法或数据，应在PR中说明依据、修改前后样本数量和指标差异。GitHub CI只检查Python语法，不自动运行受数据、Stata环境及未确认口径影响的整个实证流程。
