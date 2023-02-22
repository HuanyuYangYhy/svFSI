# Install script for directory: /Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/Code

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local/SV")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "RelWithDebInfo")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Library/Developer/CommandLineTools/usr/bin/objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/ThirdParty/zlib/simvascular_zlib/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/ThirdParty/metis_svfsi/simvascular_metis_svfsi/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/ThirdParty/parmetis_svfsi/simvascular_parmetis_svfsi/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/ThirdParty/tetgen/simvascular_tetgen/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/Source/Include/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/Source/cmake_install.cmake")
  include("/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/Scripts/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/yanghuanyu/Desktop/modify_svFSI_source_code/svFSI-master/svFSI/build/svFSI-build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
