# Paper reproduction | 论文复现协作仓库

用于两人及后续多人协作复现学术论文。每篇论文独立保存代码、数据获取说明、操作步骤、验证记录和未解决问题。

## 当前论文

| 论文 | 目录 | 状态 |
| --- | --- | --- |
| 窦超、原亚男、白学锦（2022），《上市公司“存贷双高”异象与股价崩盘风险》，《中国工业经济》2022年第4期，174–192页 | [dou-2022-cash-debt-crash](papers/dou-2022-cash-debt-crash/README.md) | 核心变量计算阶段；完整样本、控制变量及回归尚未完成 |

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

本篇原始Excel、各阶段Stata数据和两个ZIP已通过Git LFS上传，共40个数据及说明文件。克隆后运行 `git lfs install` 和 `git lfs pull`。详见 [详细复现步骤](papers/dou-2022-cash-debt-crash/README.md)；每步列明输入输出、操作目的与检查条件。数据快照不等于论文已完成复现。

## 如何开始

1. 克隆本仓库，每位协作者使用自己的GitHub账号。
2. 运行 `git lfs pull` 下载本篇已上传数据，再阅读对应论文README；后续新增论文按各篇数据说明处理。
3. 分支上修改代码，提交Pull Request，请另一位协作者审阅后合并。
4. 新论文复制 `templates/new-paper/` 到 `papers/<第一作者>-<年份>-<主题>/`，并更新本页索引。

本仓库目前没有一键运行全部步骤的入口。已归档代码保留当前实现与已知问题，不能将“代码执行成功”视为完成论文复现。

## 数据边界

按仓库所有者要求，2026-10-11追加本篇原始数据、阶段性dta、字段说明和数据压缩包快照；大文件使用Git LFS。论文PDF未上传。Git LFS只解决文件存储，不改变CSMAR数据的授权条件；数据访问与使用应符合权利人的许可。其他论文的数据仍默认忽略。

当前未为代码指定开源许可证。公开可见不代表已授予任意再分发许可；论文及数据库版权归各权利人。
