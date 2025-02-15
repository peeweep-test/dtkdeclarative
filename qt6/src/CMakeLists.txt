set(DTK_QML_APP_PLUGIN_PATH "${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/${LIB_NAME}/qml-app" CACHE STRING "dtk qml app plugin path")
set(DTK_QML_APP_PLUGIN_SUBPATH "dtkdeclarative/plugins" CACHE STRING "dtk qml app plugin subpath")
set(DDECLARATIVE_TRANSLATIONS_DIR "dtk5/DDeclarative/translations" CACHE STRING "DDeclarative translations directory")
set(DDECLARATIVE_TRANSLATIONS_PATH "share/${DDECLARATIVE_TRANSLATIONS_DIR}")
set(TRANSLATIONS_INSTALL_PATH "${DDECLARATIVE_TRANSLATIONS_PATH}")

# Add secure compiler options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector-all")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstack-protector-all")
set(CMAKE_EXE_LINKER_FLAGS  "-z relro -z now -z noexecstack -pie")
# For mips64
if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "mips64")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -ftree-vectorize -march=loongson3a -mhard-float -mno-micromips -mno-mips16 -flax-vector-conversions -mloongson-ext2 -mloongson-mmi")
endif()

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick DBus QuickControls2 LinguistTools)

find_package(Qt${QT_DEFAULT_MAJOR_VERSION}ShaderTools)
find_package(Dtk${DTK_VERSION_MAJOR}Core REQUIRED)
find_package(Dtk${DTK_VERSION_MAJOR}Gui REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_check_modules(GL REQUIRED IMPORTED_TARGET gl)

file(GLOB PUBLIC_HEADERS "${PROJECT_SOURCE_DIR}/src/*.h")
file(GLOB_RECURSE HEADERS "${PROJECT_SOURCE_DIR}/src/*.h")
file(GLOB_RECURSE SRCS   "${PROJECT_SOURCE_DIR}/src/*.cpp")
file(GLOB D_HEADERS   "${PROJECT_SOURCE_DIR}/src/D*")
file(GLOB ASSETS_RCS ${PROJECT_SOURCE_DIR}/src/dtkdeclarative_assets.qrc)
file(GLOB TS_FILES "${PROJECT_SOURCE_DIR}/src/translations/*.ts")
file(GLOB QML_RCS ${CMAKE_CURRENT_LIST_DIR}/dtkdeclarative_qml.qrc)

qt_add_translation(QM_FILES ${TS_FILES})

include(qml.cmake)

qt_add_qml_module(${LIB_NAME}
    PLUGIN_TARGET ${LIB_NAME}plugin
    URI "org.deepin.dtk"
    VERSION "1.0"
    SHARED
    NO_GENERATE_PLUGIN_SOURCE
    NO_PLUGIN_OPTIONAL
    QML_FILES
        ${QML_DTK_CONTROLS}
    SOURCES
        ${SRCS} ${HEADERS}
        dquickextendregister_p.h
    OUTPUT_DIRECTORY
        "${PROJECT_BINARY_DIR}/plugins/org/deepin/dtk"
)

qt_add_resources(RESOURCES
    ${QML_RCS}
    ${ASSETS_RCS}
)
target_sources(${LIB_NAME} PRIVATE
    ${RESOURCES}
)

target_link_libraries(${LIB_NAME}plugin PRIVATE
    ${LIB_NAME}
)

target_sources(${LIB_NAME}plugin PRIVATE
    ${PROJECT_SOURCE_DIR}/qmlplugin/qmlplugin_plugin.h
    ${PROJECT_SOURCE_DIR}/qmlplugin/qmlplugin_plugin.cpp
)

qt_add_shaders(${LIB_NAME} "_shaders_ng"
    BATCHABLE
    PRECOMPILE
    PREFIX
        "/dtk/declarative"
    FILES
        "shaders_ng/quickitemviewport.vert"
        "shaders_ng/quickitemviewport.frag"
        "shaders_ng/quickitemviewport-opaque.vert"
        "shaders_ng/quickitemviewport-opaque.frag"
        "shaders_ng/cornerscolorshader.vert"
        "shaders_ng/cornerscolorshader.frag"
        "shaders_ng/shadowmaterial.vert"
        "shaders_ng/shadowmaterial.frag"
)

target_include_directories(${LIB_NAME} PRIVATE
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/private
)

set_target_properties(${LIB_NAME} PROPERTIES
    VERSION ${CMAKE_PROJECT_VERSION}
    SOVERSION ${CMAKE_PROJECT_VERSION_MAJOR}
    EXPORT_NAME Declarative
)

target_compile_definitions(${LIB_NAME} PRIVATE
    DTK_QML_APP_PLUGIN_PATH="${DTK_QML_APP_PLUGIN_PATH}"
    DTK_QML_APP_PLUGIN_SUBPATH="${DTK_QML_APP_PLUGIN_SUBPATH}"
    DDECLARATIVE_TRANSLATIONS_DIR="${DDECLARATIVE_TRANSLATIONS_DIR}"
)

if(USE_QQuickStylePluginPrivate)
    target_link_libraries(${LIB_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::QuickControls2Private
    )
endif()

target_link_libraries(${LIB_NAME}
PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Dtk${DTK_VERSION_MAJOR}::Core
    Dtk${DTK_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::QuickPrivate
PRIVATE
    Qt${QT_VERSION_MAJOR}::DBus
    PkgConfig::GL
)

target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/private>
)

target_include_directories(${LIB_NAME} INTERFACE
    $<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}>
)

target_link_directories(${LIB_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${LIB_INSTALL_DIR}>
)

# gen dtkdeclarative_config.h
include(DtkBuildConfig)
set(options MSG) # print MODULE_NAME D_HEADERS DEST_DIR
gen_dtk_config_header(MODULE_NAME ${LIB_NAME} HEADERS ${D_HEADERS} DEST_DIR ${CMAKE_CURRENT_LIST_DIR}/src OUTPUT_VARIABLE CONFIG_PATH)
list(APPEND PUBLIC_HEADERS ${CONFIG_PATH})

# Install library
install(TARGETS ${LIB_NAME} EXPORT DtkDeclarativeTargets DESTINATION "${LIB_INSTALL_DIR}")
# Install headers
install(FILES ${PUBLIC_HEADERS} ${D_HEADERS} DESTINATION "${INCLUDE_INSTALL_DIR}")
# Install export targets
install(EXPORT DtkDeclarativeTargets NAMESPACE Dtk:: FILE DtkDeclarativeTargets.cmake DESTINATION "${CONFIG_INSTALL_DIR}")
# Install translations
install(FILES ${QM_FILES} DESTINATION "${TRANSLATIONS_INSTALL_PATH}")
