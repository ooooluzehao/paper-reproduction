version 18.0
clear all
set more off

* 先cd到本文件所在的控制变量与缩尾目录，再整体运行。
* 无缺失值筛除、无缩尾、无ST/PT或行业筛选。
do "01控制变量CSV整理.do"
do "02合并剩余控制变量.do"
