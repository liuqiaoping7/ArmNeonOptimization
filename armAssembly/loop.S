.globl TEST

.section .text
TEST:

// 函数序言：保存帧指针和返回地址
stp x29, x30, [sp, #-16]!  // 分配栈空间并保存 x29, x30
mov x29, sp                 // 设置新帧指针

loop:
// 展开4次，每次8条FMLA
fmla v0.4s, v1.4s, v2.4s
fmla v3.4s, v4.4s, v5.4s
fmla v6.4s, v7.4s, v8.4s
fmla v9.4s, v10.4s, v11.4s
fmla v12.4s, v13.4s, v14.4s
fmla v15.4s, v16.4s, v17.4s
fmla v18.4s, v19.4s, v20.4s
fmla v21.4s, v22.4s, v23.4s
subs x0, x0, #1
bne loop

// 函数尾声：恢复栈指针和返回地址
mov sp, x29
ldp x29, x30, [sp], #16     // 恢复 x29, x30 并释放栈空间
ret

.global HELLOWORLD
.section .data
msg: .ascii "Hello, World!\n"
len = . - msg

.section .text
HELLOWORLD:
    // write(1, msg, len)
    mov x0, #1          // 文件描述符 stdout (1)
    adrp x1, msg        // 获取 msg 的页地址（高32位）
    add x1, x1, :lo12:msg // 组合低12位地址
    ldr x2, =len        // 直接加载 len 的值（如果 len 是常量）
    mov x8, #64         // 系统调用号 write=64
    svc #0
    ret

    // exit(0)
    mov x0, #0          // 退出状态码 0
    mov x8, #93         // 系统调用号 exit=93
    svc #0              // 触发系统调用
