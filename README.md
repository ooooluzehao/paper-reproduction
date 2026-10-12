# Paper reproduction | 论文复现协作仓库

用于两人及后续多人协作复现学术论文。每篇论文独立保存代码、数据获取说明、操作步骤、验证记录和未解决问题。

## 当前论文

| 论文 | 目录 | 状态 |
| --- | --- | --- |
| 窦超、原亚男、白学锦（2022），《上市公司“存贷双高”异象与股价崩盘风险》，《中国工业经济》2022年第4期，174–192页 | [dou-2022-cash-debt-crash](papers/dou-2022-cash-debt-crash/README.md) | 已合并核心变量、Index和ROE/ROEGROWTH；已完成筛样、缩尾和来源值口径两列基准回归；正式DA/Abacc及进一步检验待完成 |

DOI：10.19581/j.cnki.ciejournal.2022.04.004。研究解释变量年份2007–2018，对应风险年份2008–2019。

## 仓库结构

```text
paper-reproduction/
├── README.md                  # 论文索引和整体约定
├── CONTRIBUTING.md            # 协作流程
├── .gitignore                 # 数据用LFS，运行杂项和凭据忽略
├── .github/                   # PR模板和基础代码检查
├── papers/
│   └── dou-2022-cash-debt-crash/
│       ├── README.md          # 本篇的逐步操作说明
│       ├── code/              # 按现有阶段保存Stata/Python脚本
│       ├── docs/              # 数据字典、已知问题、验证记录
│       └── requirements.txt   # Python依赖
└── templates/new-paper/       # 新论文目录说明模板
```

## 数据已经上传

本篇原始Excel、各阶段Stata数据和两个ZIP已通过Git LFS上传，共108个数据及说明文件（含第11—14阶段来源和结果）。克隆后运行 `git lfs install` 和 `git lfs pull`。详见 [详细复现步骤](papers/dou-2022-cash-debt-crash/README.md)；每步列明输入输出、操作目的与检查条件。数据快照不等于论文已完成复现。

## 如何开始

1. 克隆本仓库，每位协作者使用自己的GitHub账号。
2. 运行 `git lfs pull` 下载本篇已上传数据，再阅读对应论文README；后续新增论文按各篇数据说明处理。
3. 分支上修改代码，提交Pull Request，请另一位协作者审阅后合并。
4. 新论文复制 `templates/new-paper/` 到 `papers/<第一作者>-<年份>-<主题>/`，并更新本页索引。

本仓库目前没有一键运行全部步骤的入口。已归档代码保留当前实现与已知问题，不能将“代码执行成功”视为完成论文复现。

崩盘风险中扩展市场模型、回归残差及公司特有周收益率W的原文公式、页码和Stata对应代码，见 [本篇README第4步](papers/dou-2022-cash-debt-crash/README.md#市场模型与w的原文出处)。

## 数据边界

按仓库所有者要求，2026-10-11追加本篇原始数据、阶段性dta、字段说明和数据压缩包快照；大文件使用Git LFS。论文PDF未上传。Git LFS只解决文件存储，不改变CSMAR数据的授权条件；数据访问与使用应符合权利人的许可。其他论文的数据仍默认忽略。

当前未为代码指定开源许可证。公开可见不代表已授予任意再分发许可；论文及数据库版权归各权利人。

## 最新控制变量进度

已同步09添加控制变量目录：Size、GROWTH、Ret及合并结果。最新控制变量进度、所缺数据和时间范围见 [控制变量清单](papers/dou-2022-cash-debt-crash/docs/CONTROLS.md)。

已新增10利润表与ROA阶段。第10阶段基表是本篇code/10添加利润表相关控制变量/添加ROA.dta，包含四项控制变量。

已新增11控制变量CSV清理、合并阶段：用Stata do实际运行，保留29,108条原主表行，不删缺失、不缩尾，原有字段未变。第11阶段主表为`code/11添加剩余控制变量/控制变量与缩尾/添加剩余控制变量_未删缺失未缩尾.dta`，操作和字段安排见 [第11阶段说明](papers/dou-2022-cash-debt-crash/code/11添加剩余控制变量/控制变量与缩尾/README_Stata整理与合并.md)。

已新增12市场化指数阶段：先建372条省份年度指数，再补齐公司同年省份、生成公司年度Index并合并回控制变量主表。最新主表为`code/12添加市场化指数/添加Index.dta`，29,108条Index全部非缺失，未删缺失、未缩尾，旧字段未变。详见 [第12阶段说明](papers/dou-2022-cash-debt-crash/code/12添加市场化指数/README_公司指数合并.md)。
