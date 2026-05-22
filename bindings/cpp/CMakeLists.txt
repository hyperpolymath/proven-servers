# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# CMake configuration for proven-servers C++ bindings.
# Header-only library wrapping the Zig FFI C-ABI with RAII and type safety.

cmake_minimum_required(VERSION 3.16)
project(proven-servers-cpp
    VERSION 0.1.0
    DESCRIPTION "C++ bindings for proven-servers Zig FFI (10 core protocols)"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Header-only interface library
add_library(proven INTERFACE)
target_include_directories(proven INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# Link against the Zig FFI shared libraries
target_link_libraries(proven INTERFACE
    proven_httpd
    proven_dns
    proven_firewall
    proven_ftp
    proven_graphql
    proven_grpc
    proven_mqtt
    proven_smtp
    proven_ssh_bastion
    proven_websocket
)

# Install headers
install(DIRECTORY include/proven
    DESTINATION include
)

install(TARGETS proven
    EXPORT proven-targets
)

install(EXPORT proven-targets
    FILE proven-config.cmake
    NAMESPACE proven::
    DESTINATION lib/cmake/proven
)
