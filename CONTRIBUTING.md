# 协作约定

## 两个人如何协作

仓库所有者在GitHub仓库 Settings → Collaborators 添加另一位协作者；对方接受邀请后有写入权限。仓库无需共享账号或密码。

日常流程：

```bash
git switch main
git pull --ff-only
git switch -c dou2022/describe-your-change
# 修改、检查后：
git add <本次修改的代码或文档>
git commit -m "Describe the change"
git push -u origin dou2022/describe-your-change
```

随后在GitHub创建Pull Request，请另一位协作者检查。main保留可以解释其状态的版本；有权限时可设置保护规则，要求PR和至少一人审阅。

## 修改统计口径时

- 写明论文页码或附件来源，不用样本数量倒推定义。
- 写明变量公式、时间窗口、缺失处理、行业层级与均值计算样本。
- 记录每一步样本数量；重大改变比较修改前后的DH、崩盘指标及最终结果。
- 不将缺失金额无依据地改成0；不得按论文观测数强行删样本。
- 原始数据留在本地，提交代码和汇总验证记录，不提交公司级原始或衍生数据。
- 相对文件名要求当前工作目录正确；更改运行路径时同步更新本篇README。

## 任务安排

建议在Issues中按“数据与样本”“变量构造”“模型验证”拆分任务，标明负责人和完成条件。两人修改同一文件前先协调；发现冲突后逐项核对，不使用强制推送覆盖对方工作。
