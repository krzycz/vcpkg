# NOTE:
# - x86/x64 - vcpkg default one is x86, to build nvml use nvml:x64-windows or set environment variable VCPKG_DEFAULT_TRIPLET to 'x64-windows'

set(NVML_VERSION 1.2.2)
set(NVML_HASH 1cca38e579307308ac9be1e1e648893707f19b62f0d5d9377db38a8a4a1f16352c8d731fa76d4ba31b57a0bbace02ba6127b9bf2d03fe0f92a45f1f4c8b24ed6)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${NVML_VERSION})

include(vcpkg_common_functions)

#if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    message(FATAL_ERROR "Static building not supported.")
#endif()
 
if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is not supported in NVML - please use nvml:x64-windows or set environment variable VCPKG_DEFAULT_TRIPLET to 'x64-windows'")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    message(FATAL_ERROR "x86 is not supported in NVML - please use nvml:x64-windows or set environment variable VCPKG_DEFAULT_TRIPLET to 'x64-windows'")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# Download source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/nvml
    REF ${NVML_VERSION}
    SHA512 ${NVML_HASH}
    HEAD_REF master
)

# Build only the selected projects
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/src/NVML.sln
    PLATFORM x64
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${NVML_VERSION}
)

set(DEBUG_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Debug)
set(RELEASE_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Release)

# Install headers 
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/libpmemobj/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libpmemobj)
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/libpmemobj++/*.hpp)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libpmemobj++)
    
# Install libraries (debug)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/libpmem*.lib ${DEBUG_ARTIFACTS_PATH}/libpmem*.exp)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libpmemcommon.lib)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/libpmem*.dll)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Install tools (debug)
file(INSTALL ${DEBUG_ARTIFACTS_PATH}/pmempool.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

# Install libraries (release)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/libpmem*.lib ${RELEASE_ARTIFACTS_PATH}/libpmem*.exp)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libpmemcommon.lib)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/libpmem*.dll)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Install tools (release)
file(INSTALL ${RELEASE_ARTIFACTS_PATH}/pmempool.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nvml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nvml/LICENSE ${CURRENT_PACKAGES_DIR}/share/nvml/copyright)
