# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/Code"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-build"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/tmp"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/src/svFSI-stamp"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/src"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/src/svFSI-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/src/svFSI-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/Docker/svFSI/build/svFSI-prefix/src/svFSI-stamp${cfgdir}") # cfgdir has leading slash
endif()
