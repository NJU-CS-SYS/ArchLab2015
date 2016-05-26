# ArchLab2015
2015秋季学期组成原理实验

## 调试工具

### SPIM

在项目根目录下执行 `./test.py testcase/xxx.c spim` 可以在 `tools` 目录下生成 spim
可以使用的汇编代码文件.

将通过 `./sim/pipeline_test.v` 仿真获得的 PC 流和执行 spim 获得 PC 流用 `./tools/cmp.py` 进行比较,
观察两个执行流基本块的一致性, 判断是否发生错误以及定位错误起始基本块.

### QEMU

在项目根目录下执行 `./test.py testcase/xxx.c qemu`, 在完成 `ram.txt` 的生成后, 会启动 `qemu-mipsel` 以及 `gdb` 进行调试.
主要用以单步执行观察执行流和数据的正确性.
