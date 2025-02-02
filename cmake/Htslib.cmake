if(NOT DEFINED HTSLIB_LIBRARIES) # lazy include guard
    if(WIN32)
        message(STATUS "Fetching htslib from Box")
        download_and_extract(https://nanoporetech.box.com/shared/static/9dnctbjw86d20qq8l8tw3dk93hu1nrul.gz htslib-win)
        set(HTSLIB_DIR ${DORADO_3RD_PARTY}/htslib-win CACHE STRING
                    "Path to htslib repo")
        set(HTSLIB_LIBRARIES hts-3)
        link_directories(${HTSLIB_DIR})
    else()
        message(STATUS "Building htslib")
        set(HTSLIB_DIR ${DORADO_3RD_PARTY}/htslib CACHE STRING
                    "Path to htslib repo")
        set(MAKE_COMMAND make)
        set(AUTOCONF_COMMAND autoconf)
        execute_process(COMMAND bash -c "autoconf -V | sed 's/.* //; q'"
                OUTPUT_VARIABLE AUTOCONF_VERS)
        if(AUTOCONF_VERS VERSION_GREATER_EQUAL 2.70)
            set(AUTOCONF_COMMAND autoreconf --install)
        endif()
        set(htslib_PREFIX ${CMAKE_BINARY_DIR}/3rdparty/htslib)

        include(ExternalProject)
        ExternalProject_Add(htslib_project
                PREFIX ${htslib_PREFIX}
                SOURCE_DIR ${HTSLIB_DIR}
                BUILD_IN_SOURCE 1
                CONFIGURE_COMMAND autoheader
                COMMAND ${AUTOCONF_COMMAND}
                COMMAND ./configure --disable-bz2 --disable-lzma --disable-libcurl --disable-s3 --disable-gcs
                BUILD_COMMAND ${MAKE_COMMAND} install prefix=${htslib_PREFIX}
                INSTALL_COMMAND ""
                BUILD_BYPRODUCTS ${htslib_PREFIX}/lib/libhts.a
                LOG_CONFIGURE 0
                LOG_BUILD 0
                LOG_TEST 0
                LOG_INSTALL 0
                )

        include_directories(${htslib_PREFIX}/include/htslib)
        set(HTSLIB_LIBRARIES htslib)
        add_library(htslib STATIC IMPORTED)
        set_property(TARGET htslib APPEND PROPERTY IMPORTED_LOCATION ${htslib_PREFIX}/lib/libhts.a)
        message(STATUS "Done Building htslib")
    endif()
endif()
