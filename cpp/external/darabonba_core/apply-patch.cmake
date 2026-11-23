set(patch "${CMAKE_CURRENT_LIST_DIR}/qualify-make-shared.patch")

# CodeQL reconfigures after installing dependencies in the same build directory.
execute_process(
  COMMAND "${GIT_EXECUTABLE}" apply --reverse --check "${patch}"
  RESULT_VARIABLE reverse_check
  ERROR_QUIET)
if(NOT reverse_check STREQUAL "0")
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" apply "${patch}"
    RESULT_VARIABLE apply_result)
  if(NOT apply_result STREQUAL "0")
    message(FATAL_ERROR "Could not apply the legacy Tea C++ patch")
  endif()
endif()
