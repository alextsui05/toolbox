# Copy dependencies into the install directory in Linux for quick and dirty distribution.
#
# This assumes a standard distribution, i.e.
#   install(TARGETS ...
#       RUNTIME DESTINATION bin
#       LIBRARY DESTINATION lib
#   )
#
# Usage
# -----
# Drop it in cmake/ subdirectory in your CMake project.
# Add the following line in CMakeLists.txt:
#
#   install(SCRIPT cmake/PostInstall.cmake)
#
# Add the following line in .build_targets
#
#   set(BUILD_TARGETS "target1;target2;...")
#
# where target1, target2, etc. are the names of the targets you want to scan
# for dependencies.
#
# Now when you run `make install', it will call this script afterwards and
# copy dependencies, just like is done with CMake-OSX's FixupBundle.

message(STATUS "FOOBAR")
include(GetPrerequisites)
include(BundleUtilities)

function(gp_item_default_embedded_path_override item path)
    if(WIN32 AND NOT UNIX)
        set(path "@executable_path" PARENT_SCOPE)
    else()
        set(path "@executable_path/../lib" PARENT_SCOPE)
    endif()
endfunction()

function(get_project_keys exes_var keys_var)
    set(${keys_var} PARENT_SCOPE)
    set(do_copy 1) # do copy out-of-project dependencies
    set(do_not_copy 0) # don't copy in-project targets

# TODO: gather all prereqs into keys_var
    foreach(exe ${${exes_var}})
        message(STATUS "EXE: ${exe}")
        set(fullexepath "${CMAKE_INSTALL_PREFIX}/bin/${exe}")
        get_filename_component(exepath "${fullexepath}" PATH)
        message(STATUS "fullexepath: ${fullexepath}")
        get_item_key("${fullexepath}" tmp_key)
        message(STATUS "item key: ${tmp_key}")
        message(STATUS "exepath: ${exepath}")
        set_bundle_key_values(${keys_var} "${fullexepath}" "${fullexepath}" "${exepath}" "${CMAKE_INSTALL_PREFIX}/lib" 0)
        list(LENGTH keys n)
        message(STATUS "num keys: ${n}")

        # we need to exclude system libraries ourselves
        set(do_exclude_system_libraries 1)
        set(do_not_exclude_system_libraries 0)
        set(recursive_mode_on 1)
        set(recursive_mode_off 0)
        set(known_system_libraries "")
        set(known_system_libraries ${known_system_libraries} "libc.so")
        set(known_system_libraries ${known_system_libraries} "libdl.so")
        set(known_system_libraries ${known_system_libraries} "libgcc_s.so")
        set(known_system_libraries ${known_system_libraries} "libm.so")
        set(known_system_libraries ${known_system_libraries} "libstdc++.so")
        get_prerequisites("${fullexepath}" prereqs ${do_not_exclude_system_libraries} ${recursive_mode_on} "${exepath}" "")
        foreach(pr ${prereqs})
            get_filename_component(item_name "${pr}" NAME)
            set(contains 0)
            foreach(system_library ${known_system_libraries})
                string(REPLACE "++" "\\+\\+" system_library "${system_library}")
                #message(STATUS "${system_library}.*")
                if("${item_name}" MATCHES "${system_library}.*")
                    #message(STATUS "match")
                    set(contains 1)
                endif()
            endforeach()
            if (NOT contains) # if not a system library
                message(STATUS "Prerequisite found: ${item_name}") # when it resolves, it's an abspath
                #get_filename_component(exepath "${pr}" PATH)
                gp_resolve_item("${fullexepath}" "${pr}" "${exepath}" "${CMAKE_INSTALL_PREFIX}/lib" resolved_item)
                gp_item_default_embedded_path(${pr} default_embedded_path)
                string(REPLACE "@executable_path" "${CMAKE_INSTALL_PREFIX}/bin" resolved_embedded_path "${default_embedded_path}")
                message(STATUS "resolved = ${resolved_item}")
                message(STATUS "embedded = ${default_embedded_path}")
                set(resolved_embedded_item "${resolved_embedded_path}/${item_name}")
                message(STATUS "resolved embedded = ${resolved_embedded_item}")
                #execute_process(COMMAND ${CMAKE_COMMAND} -E copy "${resolved_item}" "${resolved_embedded_item}")
                set_bundle_key_values(${keys_var} "${fullexepath}" "${pr}" "${exepath}" "${CMAKE_INSTALL_PREFIX}/lib" 1)
            endif( )
        endforeach()

    endforeach()

    # Propagate values to caller's scope:
    #
    set(${keys_var} ${${keys_var}} PARENT_SCOPE)
    foreach(key ${${keys_var}})
      set(${key}_ITEM "${${key}_ITEM}" PARENT_SCOPE)
      set(${key}_RESOLVED_ITEM "${${key}_RESOLVED_ITEM}" PARENT_SCOPE)
      set(${key}_DEFAULT_EMBEDDED_PATH "${${key}_DEFAULT_EMBEDDED_PATH}" PARENT_SCOPE)
      set(${key}_EMBEDDED_ITEM "${${key}_EMBEDDED_ITEM}" PARENT_SCOPE)
      set(${key}_RESOLVED_EMBEDDED_ITEM "${${key}_RESOLVED_EMBEDDED_ITEM}" PARENT_SCOPE)
      set(${key}_COPYFLAG "${${key}_COPYFLAG}" PARENT_SCOPE)
    endforeach()
endfunction()

function(clear_project_keys keys_var)
  foreach(key ${${keys_var}})
    set(${key}_ITEM PARENT_SCOPE)
    set(${key}_RESOLVED_ITEM PARENT_SCOPE)
    set(${key}_DEFAULT_EMBEDDED_PATH PARENT_SCOPE)
    set(${key}_EMBEDDED_ITEM PARENT_SCOPE)
    set(${key}_RESOLVED_EMBEDDED_ITEM PARENT_SCOPE)
    set(${key}_COPYFLAG PARENT_SCOPE)
  endforeach()
  set(${keys_var} PARENT_SCOPE)

endfunction()

function(copy_deps target)
    get_filename_component(exepath ${query} PATH)
#set(dirs /usr/local/atsui/lib)
    #list_prerequisites("${query}" 1 1 1)
    set(do_exclude_system_libraries 1)
    set(do_not_exclude_system_libraries 0)
    set(recursive_mode_on 1)
    set(recursive_mode_off 0)

    set(known_system_libraries "")
    set(known_system_libraries ${known_system_libraries} "libc.so")
    set(known_system_libraries ${known_system_libraries} "libdl.so")
    set(known_system_libraries ${known_system_libraries} "libgcc_s.so")
    set(known_system_libraries ${known_system_libraries} "libm.so")
    set(known_system_libraries ${known_system_libraries} "libstdc++.so")

    get_prerequisites("${target}" prereqs ${do_not_exclude_system_libraries} ${recursive_mode_on} "${exepath}" "")
    foreach(pr ${prereqs})
        get_filename_component(item_name "${pr}" NAME)
        set(contains 0)
        foreach(system_library ${known_system_libraries})
            string(REPLACE "++" "\\+\\+" system_library "${system_library}")
            #message(STATUS "${system_library}.*")
            if("${item_name}" MATCHES "${system_library}.*")
                #message(STATUS "match")
                set(contains 1)
            endif()
        endforeach()
        if (NOT contains) # if not a system library
            message(STATUS "Prerequisite found: ${item_name}") # when it resolves, it's an abspath
            message(STATUS "pr: ${pr}") # when it resolves, it's an abspath
            #get_filename_component(exepath "${pr}" PATH)
            gp_resolve_item("${target}" "${pr}" "${exepath}" "${CMAKE_INSTALL_PREFIX}/lib" resolved_item)
            gp_item_default_embedded_path(${pr} default_embedded_path)
            string(REPLACE "@executable_path" "${CMAKE_INSTALL_PREFIX}/bin" resolved_embedded_path "${default_embedded_path}")
            message(STATUS "resolved = ${resolved_item}")
            message(STATUS "embedded = ${default_embedded_path}")
            set(resolved_embedded_item "${resolved_embedded_path}/${item_name}")
            message(STATUS "resolved embedded = ${resolved_embedded_item}")
            #execute_process(COMMAND ${CMAKE_COMMAND} -E copy "${resolved_item}" "${resolved_embedded_item}")
        endif( )
    endforeach()
endfunction()

function (copy_project_keys keys_var)
    list(LENGTH ${keys_var} n)
    message(STATUS "calling copy_project_keys")
    message(STATUS "num keys: ${n}")
    set(i 0)
    foreach(key ${${keys_var}})
      math(EXPR i ${i}+1)
      if(${${key}_COPYFLAG})
        message(STATUS "${i}/${n}: copying '${${key}_RESOLVED_ITEM}'")
        execute_process(COMMAND ${CMAKE_COMMAND} -E copy "${${key}_RESOLVED_ITEM}" "${${key}_RESOLVED_EMBEDDED_ITEM}")
      else()
        message(STATUS "${i}/${n}: *NOT* copying '${${key}_RESOLVED_ITEM}'")
      endif()
    endforeach()
endfunction()

#set(my_targets "test")
message(STATUS ${CMAKE_CURRENT_LIST_FILE})
get_filename_component(CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
#file(TO_CMAKE_PATH "${CURRENT_LIST_DIR}" CURRENT_LIST_DIR)
set(PROJECT_DIR "${CURRENT_LIST_DIR}/..")
# Wow this is null
#message(STATUS ${PROJECT_SOURCE_DIR})
include("${PROJECT_DIR}/.build_targets")
get_project_keys(my_targets BUILD_TARGETS)
copy_project_keys(keys)
clear_project_keys(keys)
