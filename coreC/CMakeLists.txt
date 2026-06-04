cmake_minimum_required(VERSION 3.22.1)
project(CoreC C)

# ==========================================
# 1. SHARED CONFIGURATION (iOS / LOCAL)
# ==========================================

# We create the pure static library for iOS and tests
add_library(core_c_lib STATIC core_component.c)

# Your current executable for local testing remains exactly the same
add_executable(programa_test main.c)
target_link_libraries(programa_test PRIVATE core_c_lib)