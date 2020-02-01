if(SELF_DIRECTORY)
    return()
endif()
set(SELF_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

include(CodeCoverage)
include(CMakeParseArguments)

find_package(Catch2 REQUIRED)

if(COVERAGE)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        add_compile_options(--coverage)
        add_link_options(--coverage)

    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")

    else()
        message(FATAL_ERROR "no configuration for compiler ${CMAKE_CXX_COMPILER_ID}")

    endif()
endif()

# Links the TARGET with Catch2::Catch2 and adds default "run test" targets for reporting results.
#
# Usage:
#
# add_catch2_and_reporting(
#     NAME common_report_target_for_some_executable
#     TARGET some_executable
# )
#
function(add_catch2_and_reporting_targets)
    set(options "")
    set(oneValueArgs NAME TARGET)
    set(multiValueArgs "")
    cmake_parse_arguments(Catch2Tests "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    target_link_libraries(${Catch2Tests_TARGET} PRIVATE Catch2::Catch2)

    set(JUNIT_REPORT_TARGET "${Catch2Tests_NAME}-junit")
    add_custom_target(${JUNIT_REPORT_TARGET}
        COMMENT "Collecting JUnit reports of ${Catch2Tests_TARGET}"
        DEPENDS ${Catch2Tests_TARGET}
        COMMAND ${Catch2Tests_TARGET} -d yes -r junit -o "${JUNIT_REPORT_TARGET}.xml"
        BYPRODUCTS "${JUNIT_REPORT_TARGET}.xml"
    )

    add_custom_target(${Catch2Tests_NAME}
        COMMENT "Running tests and collecting reports of ${Catch2Tests_TARGET}"
        DEPENDS ${JUNIT_REPORT_TARGET}
    )

    if(COVERAGE)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

            set(CORBETURA_REPORT_TARGET "${Catch2Tests_NAME}-cobertura")
            setup_target_for_coverage_gcovr_xml(
                NAME ${CORBETURA_REPORT_TARGET}
                BASE_DIRECTORY "${CMAKE_SOURCE_DIR}"
                EXECUTABLE ${Catch2Tests_TARGET}
                EXECUTABLE_ARGS -r compact
                DEPENDENCIES ${Catch2Tests_TARGET}
            )
            add_dependencies(${Catch2Tests_NAME} ${CORBETURA_REPORT_TARGET})

            set(GCOV_REPORT_TARGET "${Catch2Tests_NAME}-gcov")
            add_custom_target(${GCOV_REPORT_TARGET}
                COMMENT "Collecting gcov reports of ${Catch2Tests_TARGET}"
                DEPENDS ${Catch2Tests_TARGET}
                COMMAND ${CMAKE_COMMAND} -E make_directory gcov
                COMMAND sh "${SELF_DIRECTORY}/generate-gcov-report.sh"
                BYPRODUCTS gcov/
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            )
            add_dependencies(${Catch2Tests_NAME} ${GCOV_REPORT_TARGET})

        elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")

        else()
            message(FATAL_ERROR "no configuration for compiler ${CMAKE_CXX_COMPILER_ID}")

        endif()
    endif()

endfunction()

