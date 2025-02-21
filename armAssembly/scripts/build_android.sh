#!/usr/bin/env bash

set -e
# set -x

basepath=$(cd `dirname $0`/..; pwd)

BUILD_DIR=${basepath}/build_android

BUILD_ANDROID_NDK_HOME=/Users/liuqiaoping/Library/Android/sdk/ndk/28.0.13004108
DEPLOY_DIR=/data/local/tmp/build_android
CMAKE_PATH=cmake

# ABI="armeabi-v7a"
ABI="arm64-v8a"
ANDROID_API_LEVEL=android-21
ANDROID_TOOLCHAIN=clang

rm -rf ${BUILD_DIR}
if [[ ! -d ${BUILD_DIR} ]]; then
    mkdir -p ${BUILD_DIR}
fi

cd ${BUILD_DIR}
${CMAKE_PATH} \
-DCMAKE_TOOLCHAIN_FILE=${BUILD_ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
-DANDROID_NDK=${BUILD_ANDROID_NDK_HOME} \
-DANDROID_ABI=${ABI} \
-DANDROID_ARM_NEON=ON \
-DANDROID_NATIVE_API_LEVEL=${ANDROID_API_LEVEL} \
-DANDROID_TOOLCHAIN=${ANDROID_TOOLCHAIN} \
../

make all -j4

##### geenrate disassembly files
# DISASSEMBLY_FILES_PATH=${basepath}/datas/disassemble_files
# ${BUILD_ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-dis \
#     ${BUILD_DIR}/assemblyEx1ArrWeightSum \
#     -o ${DISASSEMBLY_FILES_PATH}/assemblyEx1ArrWeightSum_${ABI}.txt

# ${BUILD_ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-dis \
#     ${BUILD_DIR}/assemblyEx2Rgb2Gray \
#     -o ${DISASSEMBLY_FILES_PATH}/assemblyEx2Rgb2Gray_${ABI}.txt

adb shell "mkdir -p ${DEPLOY_DIR}"

##### run gflops_benchmark experiments
adb push ${BUILD_DIR}/gflops_benchmark ${DEPLOY_DIR}
adb shell "cd ${DEPLOY_DIR}; ./gflops_benchmark" 0 1e9

# ##### run arr weight sum experiments
# adb push ${BUILD_DIR}/assemblyEx1ArrWeightSum ${DEPLOY_DIR}
# adb shell "cd ${DEPLOY_DIR}; ./assemblyEx1ArrWeightSum"

# ##### run rgb to gray experiments
# INPUT_NAME=dragonball.jpg
# OUTPUT_NAME=gray_${INPUT_NAME}
# INPUT_PATH=${basepath}/datas/images/${INPUT_NAME}
# OUTPUT_PATH=${basepath}/datas/results/

# adb push ${INPUT_PATH} ${DEPLOY_DIR}
# adb push ${BUILD_DIR}/assemblyEx2Rgb2Gray ${DEPLOY_DIR}
# adb shell "cd ${DEPLOY_DIR}; ./assemblyEx2Rgb2Gray ${INPUT_NAME} ${OUTPUT_NAME}"
# adb pull ${DEPLOY_DIR} ${OUTPUT_PATH}



