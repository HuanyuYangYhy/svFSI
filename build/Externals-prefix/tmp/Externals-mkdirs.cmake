# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/Externals"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-build"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/tmp"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/src/Externals-stamp"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/src"
  "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/src/Externals-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/src/Externals-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/Externals-prefix/src/Externals-stamp${cfgdir}") # cfgdir has leading slash
endif()
