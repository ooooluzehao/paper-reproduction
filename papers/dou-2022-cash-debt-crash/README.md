# 《上市公司“存贷双高”异象与股价崩盘风险》复现指南

窦超、原亚男、白学锦（2022），《中国工业经济》2022年第4期，174–192页。DOI：10.19581/j.cnki.ciejournal.2022.04.004。

## 已上传什么，复现到哪里

**本篇的数据已经上传，不需要另找本项目已有的Excel或dta。** Git LFS发布了原始Excel、阶段性dta和两个ZIP，普通Git保存字段说明；最新数据文件数量及大小见[数据清单](docs/data-manifest.json)，包含第13阶段ROE/ROEGROWTH查询快照与合并结果。

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
| Size、GROWTH、Ret脚本与合并结果 | [code/09添加控制变量](code/09添加控制变量/) |
| 利润表整理、ROA脚本与合并结果 | [code/10添加利润表相关控制变量](code/10添加利润表相关控制变量/) |
| 剩余控制变量CSV及整理合并 | [code/11添加剩余控制变量](code/11添加剩余控制变量/) |
| 省份市场化指数及合并结果 | [code/12添加市场化指数](code/12添加市场化指数/) |
| ROE、ROEGROWTH脚本与最新主表 | [code/13roegrowth](code/13roegrowth/) |
| 最新筛样、缩尾、两列基准回归及三份Word表 | [code/14筛选数据与回归/因果](code/14筛选数据与回归/因果/) |
| 原项目已有两个压缩包 | [data-archives](data-archives/) |
| 每个文件的大小和SHA-256 | [数据清单](docs/data-manifest.json) |

已完成核心变量构造、控制变量逐项合并及ROE/ROEGROWTH计算。**最新主表为`code/13roegrowth/添加ROE与ROEGROWTH.dta`，29,108条公司年度记录；正式DA/Abacc仍待完成；第14阶段已用来源值完成筛样、缩尾及两列固定效应回归。**各阶段保留各自运行快照，不代表整篇流程在本次重跑。论文PDF没有上传。方法待核对处列在 [已知问题](docs/KNOWN_ISSUES.md)。

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
- 第13阶段仓库默认do使用已保存的数据库查询快照；数据库在线版本另存，详见该阶段README。

下面示例假定仓库克隆到 `D:/codex项目/paper-reproduction`，请替换为你的实际位置。Stata中可用：

```stata
global paper "D:/codex项目/paper-reproduction/papers/dou-2022-cash-debt-crash"
```

之后每阶段使用 `cd "$paper/code/对应目录"`。这个全局宏只用于下面的操作说明，现有do文件仍使用相对文件名。

**如果只想接着当前成果做：**从 `code/13roegrowth/添加ROE与ROEGROWTH.dta` 继续，原变量和各阶段标记均保留；按第10步统一处理最终样本。

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

### 市场模型与W的原文出处

窦超等（2022）第180页在构造崩盘风险指标时引用Kim、Li和Zhang（2011）。现已核对该参考文献全文：**第717页（PDF第5页），第3.2节“Measuring firm-specific crash risk”，公式（1）**明确给出以下扩展市场模型，并说明按每家公司、每年估计：

$$
r_{i,w}=\alpha_i+\beta_{1i}r_{m,w-2}+\beta_{2i}r_{m,w-1}+\beta_{3i}r_{m,w}+\beta_{4i}r_{m,w+1}+\beta_{5i}r_{m,w+2}+\varepsilon_{i,w}.
$$

其中，$r_{i,w}$为公司$i$在第$w$周的个股收益率，$r_{m,w}$为同周市场收益率；$w-2$、$w-1$是前两周和前一周，$w+1$、$w+2$是后一周和后两周。原文在公式（1）下说明，加入市场收益率的领先与滞后项是为了处理非同步交易，并引用Dimson（1979）。这就是当前代码加入`rm_l2 rm_l1 rm rm_f1 rm_f2`的依据。

估计残差等于实际个股周收益率减去模型预测值：

$$
\hat{\varepsilon}_{i,w}=r_{i,w}-\hat{r}_{i,w}.
$$

同一页紧接着明确规定公司特有周收益率：

$$
W_{i,w}=\ln(1+\hat{\varepsilon}_{i,w}).
$$

**原文与Stata代码对应：**

```stata
* 公式（1）：每个公司年份分别估计扩展市场模型
regress ri rm_l2 rm_l1 rm rm_f1 rm_f2 if firmyear == `g'

* 提取真正参与本次回归的观测残差
predict double resid_tmp if e(sample), residuals

* 将各组残差回填到epsilon后，按原文定义计算W
gen double W = ln(1 + epsilon) if epsilon > -1 & !missing(epsilon)
```

上面是公式对应片段，不是独立运行入口；完整回归仍使用本步骤的Python脚本或下方Stata循环。对数要求残差大于-1，不能对缺失值或无效残差直接取对数。

**文献：**Kim, J.-B., Li, Y., & Zhang, L. (2011). *CFOs versus CEOs: Equity incentives and crashes*. *Journal of Financial Economics*, 101(3), 713–730. [DOI: 10.1016/j.jfineco.2011.03.013](https://doi.org/10.1016/j.jfineco.2011.03.013)。第729页（PDF第17页）Appendix A.1再次列出同一市场模型与W定义。

当前rm采用流通市值加权、考虑现金红利再投资的对应市场收益率。前后两期模型及W定义已经在上述参考文献中找到直接依据。

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

**为什么转换残差：**按上一步列出的Kim等（2011）第717页定义，当前实现用 `W=ln(1+epsilon)` 表示公司特有周收益率。只有epsilon>-1才可以取对数，否则W缺失。Nweek统计非缺失W，因此可能小于Nreg。

**两个指标怎样计算：**按公司和风险年份计算，n为有效W周数。当前公式直接使用W的平方、立方和，没有另行中心化。

NCSKEW公式还可对应Kim等（2011）第718页（PDF第6页）的公式（2）；本项目以下两个指标公式对应窦超等（2022）第180页的公式（1）、（2）。

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

## 第9步：合并核心变量并逐项添加控制变量

本步汇总原第9A—9D及新ROE/ROEGROWTH内容，按9.1—9.7展开。保留现有编号文件夹和脚本路径，便于对照历史结果。

### 9.1 合并当年DH和次年股价崩盘风险

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

#### 本步do文件逐段说明

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

### 9.2 Size、GROWTH和Ret计算合并

详见 [09文件夹逐段说明与控制变量清单](docs/CONTROLS.md)。本次上传该文件夹现有do及五份dta；仓库do将原始周数据路径改成相邻目录相对路径，以便协作者运行。

```stata
cd "$paper/code/09添加控制变量"
clear all
do "sizegrowth.do"
```

一个do先处理完整资产负债表，生成Size及GROWTH并匹配核心表，保存添加sizegrowth.dta；再读取实际年份的原始周收益率，生成Ret及有效周数，匹配到前一步文件并另存添加Ret.dta。

**为何必须按此顺序：**增长率要用上一自然年资产，Ret要用当年所有有效周；不能在只保留一周、且周字段属于下一年risk_year的核心表直接求均值。keep(master match)保留原核心样本，不提前按控制变量缺失删行。

添加Ret.dta保留29,108条公司年份，已有Size、GROWTH、Ret；缺失数分别为2、1,950、481。三项均有效27,099条，但这还不是最终回归样本。

### 9.3 利润表整理与ROA计算

文件位于 [10添加利润表相关控制变量](code/10添加利润表相关控制变量/)。已上传FS_Comins.xlsx、字段说明、版权说明、两份do以及现有输出dta。

```stata
cd "$paper/code/10添加利润表相关控制变量"
do "利润表数据整理.do"
do "计算并合并ROA.do"
```

仓库do将原项目绝对路径改为相邻阶段的相对路径；运行前必须按上面切换工作目录。统计口径和数据没有在上传中修改。

#### 利润表数据整理.do：为何这样处理

1. **显式导入A1:CC704375，firstrow allstring**：此Excel共有81列，首行是数据库代码，第二行中文名称、第三行单位。工作表范围标记不完整，显式列范围避免只读A列；allstring让后两行说明不会导致财务列混合类型问题。
2. **drop in 1/2**：firstrow已取走代码行，剩下两行是名称和单位，不是公司数据，因此删除。
3. **81个字段重命名、中文label**：revenue=营业收入、total_revenue=营业总收入、net_profit=净利润、parent_net_profit=归母净利润；不同字段不能互换。利息费用与金融企业利息支出亦分别命名。
4. **destring股票代码、差错标记和金额**：真正用于计算的列转数值，日期及报表类别保留字符串；不加force，不无依据地把无法转换的文本当缺失。
5. **foreach confirm numeric**：只检查财务列是否成功转为数值，不修改它们。提取year/month/day，检查日期和A/B类型，再报告重复键。
6. **保存利润表_全部整理.dta**：保留季度和母公司记录供后续使用，不在这一步直接删掉。季度利润可能是累计值，不能直接称单季度利润。

#### 计算并合并ROA.do：为何按此顺序

```stata
keep if report_type == "A"
keep if month == 12 & day == 31
keep if inrange(year, 2007, 2018)
keep stock year net_profit if_correct
```

选A类合并、年末全年利润，与年末合并资产总额一致；年末利润是全年累计，不是第四季度单季利润。使用net_profit，不自动替换成归母净利润。保留差错更正标记，不仅因有更正就删除公司年份。确认stock/year唯一后保存净利润_年度合并.dta。

```stata
merge 1:1 stock year using "净利润_年度合并.dta", ///
    keep(master match) keepusing(net_profit if_correct) gen(ROA_profit_merge)
gen double ROA = net_profit / total_assets ///
    if !missing(net_profit, total_assets) & total_assets > 0
```

先从05完整年度资产表取同年total_assets，再匹配利润。按论文正文“净利润/总资产”，本实现分母是年末总资产，不是平均总资产。金额均为元，结果是比例，不乘100。净利润可为负，亏损不是删除理由；资产非正或缺失不计算。

保存ROA_公司年度.dta后，从09添加Ret.dta匹配ROA、net_profit、if_correct，另存添加ROA.dta。只保留原核心样本及匹配行，不加入只有ROA的公司年份，也不覆盖已存在的总资产字段。匹配year不是risk_year，控制变量属于解释变量当年。

#### 现有输出与核验

- 净利润_年度合并.dta：公司年度合并净利润和差错标记。
- ROA_公司年度.dta：32,240行，ROA缺失3行，无重复公司年份。
- 添加ROA.dta：29,108行，ROA缺失2行，无重复公司年份；已有Size、GROWTH、Ret、ROA。
- 这些是已运行保存的数据快照；本次上传只检查当前字段、行数和键，不宣称重新跑了整个Stata流程。

### 9.4 剩余控制变量CSV清理与合并

**输入：**第10步`添加ROA.dta`和第11文件夹`控制变量CSV/`中的单项控制变量、辅助表。**输出：**`控制变量DTA/`的14张清理表，以及`添加剩余控制变量_未删缺失未缩尾.dta`。

```stata
cd "$paper/code/11添加剩余控制变量/控制变量与缩尾"
do "00运行整理与合并.do"
```

1. `01控制变量CSV整理.do`以firstrow列名和保留大小写导入，先字符串后destring，将股票代码、年份、金额和指标转数值，并设置中文标签。真实文本列保留字符串。异常文本会报错，不能用force静默转换；不删除任何指标缺失行。
2. 年度表用`isid stock year`检查唯一键；季度利润按日期检查，保留1月1日等原始期间，单独保存，不按年度直接合并。
3. `02合并剩余控制变量.do`以第10步为master，通过`keep(master match)`保留全部主表观测。每张来源的merge标记独立保存，未匹配与匹配成功但指标缺失都可追踪。
4. 既有ROA、net_profit等字段保持原值，来源值使用ROA_csv、net_profit_csv命名。来源DA/Abacc按用户选择保存为DA_csv/Abacc_csv，正式计算另做。Dturnt使用Dturnt_d，同时保留Dturnt_m。
5. `analysis_sample.csv`已经由来源流程删缺失并缩尾，仅作为原始交付文件归档，不作为本步骤master或控制变量输入。本步骤不调用来源merge_and_winsor.py。
6. 不根据ST/PT、IsSuspend或行业筛选，也不调用winsor2或任何分位数截断；目录名称含“缩尾”不改变本次处理范围。

本次实际运行Stata MP 18成功：主表29,108行、公司年度键唯一，全部原主表字段与第10步逐值一致；独立核对14张清理表和11次左合并。原CSV与既有脚本保持原样，结果另存。详细字段映射、匹配数、缺失数和原因见 [第11阶段说明](code/11添加剩余控制变量/控制变量与缩尾/README_Stata整理与合并.md)及 [核验JSON](code/11添加剩余控制变量/控制变量与缩尾/整理合并核验.json)。

### 9.5 市场化指数构造与合并

**本阶段输出：**[添加Index.dta](code/12添加市场化指数/添加Index.dta)。保留第11步29,108条公司年度记录、全部原字段及新增Index。Index缺失0；不删其他变量缺失、不缩尾、不做额外样本筛选。

```stata
cd "$paper/code/12添加市场化指数"
do "01构建省份年度指数.do"
do "02补充公司省份并匹配指数.do"
do "03合并Index到控制变量主表.do"
```

1. **先构建省份—年份—指数**：01从用户新提供的完整2007—2018企业省份与指数文件中，统一省份简称及六位省级代码。先检查同省份同年份总指数及各方面指数完全一致，再保留一条，得到31省×12年=372条的`省份年度市场化指数_完整2007至2018.dta`。这样不要求每家企业原本就在指数企业清单中。
2. **再补齐公司年度省份**：02将年度province.dta和指数企业省份表分别按stock/year匹配。年度省份表优先提供25,980条，指数来源省份补2,690条，剩余438条从本地国泰安companyinfo批次44e1c459442938e64d768a49取同年12月31日省份。补充表随本阶段发布，不需协作者连接数据库，也未改动数据库或用跨年省份猜测本年。
3. **按省份年份匹配公司指数**：用province_code_for_index/year进行m:1合并，生成`公司年度市场化指数.dta`，stock/year唯一。province_source记录三种来源，province_conflict记录两个企业省份来源的不一致；新匹配字段另命名，保留原主表province/province_code。
4. **将Index带回控制变量主表**：03从第11步主表按stock/year做1:1合并，仅带入Index、原始指数及其省份来源，另存`添加Index.dta`。Index按当年year匹配，不使用次年risk_year。负的原始总指数只要大于-1仍可取对数，不因负值删行。
5. **保留总指数原值**：`market_index_raw`为来源总指数，`Index=ln(1+market_index_raw)`。原指数企业文件的market_direct与按年度省份匹配的总指数分别保留在完整审核主表中，避免混淆。

本阶段另保存了最初2018报告17页节选的录入表、Excel和2007—2018缺年模板：它只有2008/2010/2012/2014/2016五年155条真实值，**不参与完整Index合并**。完整合并使用后来提供的2007—2018数据，两套来源分开保留。

三步do已通过Stata MP 18实际运行及独立回读核对：省份年度372条唯一，公司年度29,108条唯一，Index全匹配且公式正确，最终添加Index.dta全部旧字段逐值不变。详细文件说明见 [第12阶段说明](code/12添加市场化指数/README_公司指数合并.md)；来源批次、文件哈希和核验结果保存在该阶段JSON中。

### 9.6 单季度ROE增长率、年度ROEGROWTH及年度ROE合并

**位置：**[13roegrowth](code/13roegrowth/)。**输入：**完整合并利润表、已保存的季度末权益与累计ROE查询快照、添加Index.dta。**最新输出：**[添加ROE与ROEGROWTH.dta](code/13roegrowth/添加ROE与ROEGROWTH.dta)。

```stata
cd "$paper/code/13roegrowth"
do "计算并合并ROEGROWTH.do"
do "合并年度ROE到主表.do"
```

1. **保留2006—2018季度末合并权益及净利润**：2007年第一季度增长率依赖2006年第四季度ROE；不能先删掉2006年。数据库定期报告取source=0，合并报表取A。
2. **累计利润还原单季度利润**：Q1直接使用累计净利润，Q2—Q4减去上一季度累计值；`xtset stock qdate`和`L.`避免把跨越缺口的记录当作相邻季度。
3. **生成单季度ROE**：单季度净利润/季度末合并总权益。数据库`f050501b`为累计净利润/期末权益，单列核对，不能直接当单季度ROE或对累计ROE简单求差。
4. **季度增长率**：`(ROE_q-L.ROE_q)/L.ROE_q`。零基期、季度缺口或无效分母保留缺失，负基期按公式保留。完成滞后计算后才截取2007—2018。
5. **年度汇总**：按用户选择取季度增长率均值；缺季度时当前为有效季度均值，同时保留`ROEGROWTH_Nquarter`及四季完整标记，供最终统一筛样。
6. **补入年度ROE**：取数据库ROE A的12月31日值作为全年ROE，而非季度ROE均值，另存年度ROE表并匹配主表。ROE是补充字段，不自动加入论文基准控制变量清单。
7. **另存最新主表**：29,108条公司年度记录全部保留；ROE缺失300条，ROEGROWTH缺失1,467条；25,889条有完整四季度增长率。原字段逐值不变，不删缺失、不缩尾。

已实际运行Stata并独立核对原字段、季度均值与年度结果。仓库使用查询快照的离线入口也经过Stata执行；在线数据库入口单独保存。完整公式与文件说明见[本阶段README](code/13roegrowth/README.md)。

### 9.7 控制变量当前进度（2026-10-12）

第11阶段已从第10步主表合并MB、Dturnt、Big4、Zscore、Disp，以及ST/PT、暂停状态、省份、经营现金流和来源利润。主表全部29,108行保留，未删控制变量缺失、未缩尾、未做行业或ST/PT样本筛选。已有ROA不覆盖；来源ROA单列核对。

| 状态 | 变量 | 当前基础及下一步 |
| --- | --- | --- |
| 已有并保留 | Size、GROWTH、Ret、ROA | 第10步主表原字段逐值未变 |
| 已合并来源指标 | MB、Dturnt、Big4、Zscore、Disp | 已有年度CSV；Dturnt=Dturnt_d，Dturnt_m及MB候选版本同时保留 |
| 来源值已合并，正式计算另做 | DA、Abacc | 当前命名DA_csv、Abacc_csv；来源仅计算绝对应计额/资产及其滞后合计，正式模型需另估计并补足历史年份 |
| 已构造并合并 | Index | 第12阶段先建完整省份年度总指数，再匹配公司同年省份；Index=ln(1+market_index_raw)，29,108条全部非缺失 |
| 已构造并合并 | ROEGROWTH | 单季净利润/季末权益得到ROE，再算相邻季度增长率，年度取有效季度均值，保留有效季度数 |
| 补充合并 | ROE | 当年年末数据库ROE A；不自动加入基准回归控制变量 |

正式DA/Abacc若使用前三期，应准备足够的前期数据，并按自然年度核对滞后，不用上一条记录替代上一自然年。上述“已合并”只说明来源表进入新主表，不代表已经完成论文全部样本与回归。具体操作见 [第11阶段说明](code/11添加剩余控制变量/控制变量与缩尾/README_Stata整理与合并.md)。

## 第10步：样本筛选、缩尾和基准回归（已运行，DA/Abacc暂用来源值）

**位置：**[14筛选数据与回归/因果](code/14筛选数据与回归/因果/)。使用第13阶段29,108条主表，最新版脚本为[baseline.do](code/14筛选数据与回归/因果/baseline.do)。

```stata
cd "$paper/code/14筛选数据与回归/因果"
do "baseline.do"
```

1. **全局定义控制变量**：Size、MB、ROA、Ret、Dturnt、GROWTH、Big4、Index、Zscore、Disp、DA_csv、Abacc_csv。来源DA/Abacc暂用口径在表格注明；ROEGROWTH按原文用于盈余管理机制检验，不加入本次基准模型。
2. **先删除缺失**：rowmiss检查模型字段及stock/year/STPT，再检查industry，不对所有审核字段一刀切。
3. **剔除J/K**：按industry剔除金融和房地产公司年份，保留现有DH，不静默重算行业均值。
4. **剔除ST/PT**：按当年STPT==1处理；STPT缺失已在缺失筛选中删除。
5. **缩尾**：`winsor2 $continuous, replace`采用默认全样本1%/99%，不写cuts()，不按年；DH、Big4不缩尾。
6. **包输出统计表**：sum2docx输出描述统计，corr2docx输出Pearson相关矩阵。
7. **两条独立回归**：reghdfe分别以FNCSKEW/FDUVOL为因变量，吸收公司与年份×行业固定效应，公司聚类；风险已对齐次年，不再次前移。对应论文式(3)、表4第(3)(4)列。
8. **包输出回归表**：reg2docx输出系数、t值、N、R²及固定效应标记。最新版源脚本不另存dta，只输出三份Word表，依照当前源文件上传。

筛选后14,572条，DH=1有163条；reghdfe默认去除单例后实际回归14,405条。三份Word表已实际导出并检查版面。完整文件说明、依赖、筛选数量及暂用口径见[第14阶段README](code/14筛选数据与回归/因果/README.md)。

### 输出表一 描述性统计

| 变量 | 样本数 | 最小值 | 最大值 | 均值 | 标准差 |
| --- | --- | --- | --- | --- | --- |
| FNCSKEW | 14572 | -2.4830 | 1.7509 | -0.3246 | 0.7310 |
| FDUVOL | 14572 | -1.4117 | 1.0632 | -0.2173 | 0.4864 |
| DH | 14572 | 0.0000 | 1.0000 | 0.0112 | 0.1052 |
| Size | 14572 | 19.8853 | 26.1347 | 22.3080 | 1.2480 |
| MB | 14572 | 1.3600 | 23.9330 | 4.3573 | 3.2607 |
| ROA | 14572 | -0.2301 | 0.1905 | 0.0348 | 0.0572 |
| Ret | 14572 | -0.0175 | 0.0373 | 0.0022 | 0.0102 |
| Dturnt | 14572 | -5.2701 | 4.5369 | -0.3445 | 1.6862 |
| GROWTH | 14572 | -0.2723 | 3.0886 | 0.1913 | 0.4145 |
| Big4 | 14572 | 0.0000 | 1.0000 | 0.0642 | 0.2451 |
| Index | 14572 | 1.5217 | 2.5041 | 2.2904 | 0.1908 |
| Zscore | 14572 | 0.0978 | 39.4940 | 4.9136 | 6.0298 |
| Disp | 14572 | 0.2698 | 26.6910 | 3.2447 | 4.4243 |
| DA_csv | 14572 | 0.0007 | 0.3027 | 0.0515 | 0.0515 |
| Abacc_csv | 14572 | 0.0201 | 0.6674 | 0.1618 | 0.1148 |

DA_csv、Abacc_csv暂用来源值；连续变量全样本1%缩尾。

### 输出表二 Pearson相关性矩阵

| 变量 | FNCSKEW | FDUVOL | DH | Size | MB | ROA | Ret | Dturnt | GROWTH | Big4 | Index | Zscore | Disp | DA_csv | Abacc_csv |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FNCSKEW | 1 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| FDUVOL | 0.881\*\*\* | 1 |  |  |  |  |  |  |  |  |  |  |  |  |  |
| DH | 0.011 | 0.007 | 1 |  |  |  |  |  |  |  |  |  |  |  |  |
| Size | -0.010 | -0.017\*\* | 0.015\* | 1 |  |  |  |  |  |  |  |  |  |  |  |
| MB | 0.080\*\*\* | 0.082\*\*\* | 0.096\*\*\* | -0.209\*\*\* | 1 |  |  |  |  |  |  |  |  |  |  |
| ROA | 0.040\*\*\* | 0.023\*\*\* | -0.049\*\*\* | 0.042\*\*\* | -0.174\*\*\* | 1 |  |  |  |  |  |  |  |  |  |
| Ret | 0.037\*\*\* | 0.016\*\* | -0.001 | -0.129\*\*\* | 0.285\*\*\* | 0.121\*\*\* | 1 |  |  |  |  |  |  |  |  |
| Dturnt | -0.070\*\*\* | -0.084\*\*\* | 0.013 | 0.025\*\*\* | 0.074\*\*\* | -0.052\*\*\* | 0.465\*\*\* | 1 |  |  |  |  |  |  |  |
| GROWTH | 0.025\*\*\* | 0.012 | -0.014\* | 0.079\*\*\* | -0.036\*\*\* | 0.176\*\*\* | 0.142\*\*\* | -0.039\*\*\* | 1 |  |  |  |  |  |  |
| Big4 | -0.013 | -0.016\* | -0.017\*\* | 0.380\*\*\* | -0.056\*\*\* | 0.062\*\*\* | -0.025\*\*\* | 0.012 | -0.020\*\* | 1 |  |  |  |  |  |
| Index | -0.012 | -0.019\*\* | 0.002 | -0.026\*\*\* | -0.053\*\*\* | 0.054\*\*\* | 0.048\*\*\* | 0.043\*\*\* | -0.002 | 0.059\*\*\* | 1 |  |  |  |  |
| Zscore | 0.041\*\*\* | 0.035\*\*\* | -0.044\*\*\* | -0.395\*\*\* | 0.214\*\*\* | 0.271\*\*\* | 0.245\*\*\* | 0.043\*\*\* | -0.047\*\*\* | -0.077\*\*\* | 0.064\*\*\* | 1 |  |  |  |
| Disp | -0.060\*\*\* | -0.053\*\*\* | -0.000 | 0.104\*\*\* | 0.002 | -0.050\*\*\* | -0.024\*\*\* | 0.010 | -0.078\*\*\* | 0.028\*\*\* | -0.119\*\*\* | -0.087\*\*\* | 1 |  |  |
| DA_csv | 0.027\*\*\* | 0.032\*\*\* | 0.026\*\*\* | -0.077\*\*\* | 0.192\*\*\* | -0.329\*\*\* | -0.038\*\*\* | 0.023\*\*\* | -0.086\*\*\* | -0.027\*\*\* | -0.024\*\*\* | -0.030\*\*\* | 0.027\*\*\* | 1 |  |
| Abacc_csv | 0.021\*\* | 0.024\*\*\* | 0.033\*\*\* | -0.097\*\*\* | 0.196\*\*\* | -0.055\*\*\* | 0.019\*\* | -0.005 | 0.061\*\*\* | -0.035\*\*\* | -0.065\*\*\* | -0.001 | 0.043\*\*\* | 0.266\*\*\* | 1 |

Pearson相关系数；DA_csv、Abacc_csv暂用来源值。 星号为包默认显著性标记：`*** p<0.01`，`** p<0.05`，`* p<0.10`。上三角空白沿用包输出。

### 输出表三 两列基准回归

| 变量 | (1) FNCSKEW | (2) FDUVOL |
| --- | --- | --- |
| DH | 0.0377<br>(0.500) | 0.0071<br>(0.145) |
| Size | 0.1248\*\*\*<br>(6.024) | 0.0678\*\*\*<br>(4.942) |
| MB | 0.0095\*\*\*<br>(2.792) | 0.0072\*\*\*<br>(3.173) |
| ROA | -0.2097<br>(-1.146) | -0.1988\*<br>(-1.675) |
| Ret | 12.2152\*\*\*<br>(11.750) | 8.0273\*\*\*<br>(11.874) |
| Dturnt | -0.0146\*\*\*<br>(-2.964) | -0.0112\*\*\*<br>(-3.379) |
| GROWTH | -0.0371\*\*<br>(-2.165) | -0.0290\*\*<br>(-2.465) |
| Big4 | -0.0403<br>(-0.594) | 0.0138<br>(0.296) |
| Index | -0.2537\*<br>(-1.720) | -0.2318\*\*<br>(-2.521) |
| Zscore | 0.0070\*\*\*<br>(3.543) | 0.0046\*\*\*<br>(3.409) |
| Disp | -0.0085\*\*\*<br>(-3.292) | -0.0048\*\*\*<br>(-2.776) |
| DA_csv | 0.4867\*\*\*<br>(3.163) | 0.3059\*\*\*<br>(3.029) |
| Abacc_csv | 0.0289<br>(0.363) | 0.0328<br>(0.622) |
| _cons | -2.6222\*\*\*<br>(-4.479) | -1.2701\*\*\*<br>(-3.354) |
| 公司固定效应 | 是 | 是 |
| 年份×行业固定效应 | 是 | 是 |
| 公司聚类 | 是 | 是 |
| N | 14405 | 14405 |
| R2 | 0.2642 | 0.2650 |

括号内为公司聚类t值。DA_csv、Abacc_csv暂用来源值。固定效应列默认剔除单例。 星号：`*** p<0.01`，`** p<0.05`，`* p<0.10`。

## 第11步：下一阶段任务

1. 另行完成正式DA/Abacc，并核查MB、Dturnt、行业分组等上游定义；不能把来源值直接标为正式模型残差。
2. 正式变量确定后，沿用明确的筛样、缩尾、固定效应与公司聚类流程重跑，对照论文描述统计、样本数、系数、t值与R²。
3. 再开展论文分类检验、机制检验和稳健性检验。ROEGROWTH在对应盈余管理机制模型中使用。

当前已完成采用来源值的初步基准回归，尚不等于完成整篇论文复现；不为凑17,011条或获取显著结果改变数据规则。

## 检查记录与协作

历史数值核验见 [VALIDATION.md](docs/VALIDATION.md)，待办见 [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md)，数据字段见 [DATA.md](docs/DATA.md)。历史样本数不能直接作为新版本的固定验收值。

每次修改方法或数据，应在PR中说明依据、修改前后样本数量和指标差异。GitHub CI只检查Python语法，不自动运行受数据、Stata环境及未确认口径影响的整个实证流程。
