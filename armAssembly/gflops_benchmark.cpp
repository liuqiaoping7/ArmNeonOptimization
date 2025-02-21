#include <vector>
#include <cstdlib>
#include <iostream>
#include <cmath>
#include <chrono>

#ifdef __ANDROID__
#include <sys/syscall.h>
#include <unistd.h>
#include <stdint.h>
#include <sched.h>
#endif

#define LOOP (1e9)
#define OP_FLOATS (8*4*2)

// void test(int nn){
//     asm volatile(
        
//         "0:                             \n"

//         "subs       %0, #1              \n"
//         "bne        0b                  \n"
//         "vmla.f32 q0, q0, q0            \n"
//         "vmla.f32 q1, q1, q1            \n"
//         "vmla.f32 q2, q2, q2            \n"
//         "vmla.f32 q3, q3, q3            \n"
//         "vmla.f32 q4, q4, q4            \n"
//         "vmla.f32 q5, q5, q5            \n"
//         "vmla.f32 q6, q6, q6            \n"
//         "vmla.f32 q7, q7, q7            \n"
//         "vmla.f32 q8, q8, q8            \n"
//         "vmla.f32 q9, q9, q9            \n"
        
//         : "=r"(nn)
//         : "0"(nn)
//         : "cc", "memory", "q0", "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9"
//     );
// }

extern "C" void TEST(int);
extern "C" void HELLOWORLD(void);

static int set_sched_affinity(size_t thread_affinity_mask)
{
#ifdef __GLIBC__
    pid_t pid = syscall(SYS_gettid);
#else
#ifdef PI3
    pid_t pid = getpid();
#else
    pid_t pid = gettid();
#endif
#endif
    int syscallret = syscall(__NR_sched_setaffinity, pid, sizeof(thread_affinity_mask), &thread_affinity_mask);
    if (syscallret)
    {
        fprintf(stderr, "syscall error %d\n", syscallret);
        return -1;
    }
    return 0;
}

void bind_to_cortex_x3(int cpunum) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpunum, &cpuset);  // 假设X3核心编号为7

    if (sched_setaffinity(0, sizeof(cpuset), &cpuset) == -1) {
        printf("sched_setaffinity failed\n");
    }
}

# if 1
int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: gflops_benchmark cpunum loopnum\n");
        return 0;
    }

    int cpunum = std::atoi(argv[1]);
    bind_to_cortex_x3(cpunum);
    // 先将科学计数法字符串转换为 double 类型
    double numAsDouble = std::stod(argv[2]);
    // 再将 double 类型转换为整数
    int loopnum = static_cast<int>(numAsDouble);
    printf("gflops_benchmark cpunum=%d loopnum=%d\n",cpunum,loopnum);

    HELLOWORLD();
    int loop = 1;
    float durationGflops = 0.0f;
    for (int i = 0; i < loop; ++i) {
        auto start = std::chrono::high_resolution_clock::now();
        TEST(loopnum);
        auto stop = std::chrono::high_resolution_clock::now();
        durationGflops += std::chrono::duration<double, std::milli>(stop - start).count();
    }
    float avgDurationGflops = durationGflops / loop;

    printf("perf: %.6f GFLOPS\r\n", loopnum * 1e-9 * OP_FLOATS / (avgDurationGflops * 1e-3));

    return 0;
}
#else

int main() {
    bind_to_cortex_x3(7);
    int loopnum = 1e9;

    HELLOWORLD();
    int loop = 1;
    float durationGflops = 0.0f;
    for (int i = 0; i < loop; ++i) {
        auto start = std::chrono::high_resolution_clock::now();
        TEST(loopnum);
        auto stop = std::chrono::high_resolution_clock::now();
        durationGflops += std::chrono::duration<double, std::milli>(stop - start).count();
    }
    float avgDurationGflops = durationGflops / loop;

    printf("perf: %.6f GFLOPS\r\n", loopnum * 1e-9 * OP_FLOATS / (avgDurationGflops * 1e-3));

    return 0;
}
#endif
