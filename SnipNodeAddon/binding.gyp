{
    "variables": {
        "CurrentDir": "<!(node -p \"require('path').resolve('.')\")"  # 获取当前目录的绝对路径
    },
    "targets": [
        {
            "target_name": "screenshot_sdk",
            "includes": [
                # "src/common.gypi",
            ],
            "include_dirs": [
                ".",
            ],
            "sources": [
                "src/framework.h",
                "src/pch.h",
                "src/pch.cpp",
                "src/screenshot_event_handler.h",
                "src/screenshot_event_handler.cpp",
                "src/screenshot_sdk.cpp",
                "src/define/sdk_define.h",
                "src/node_async_queue.h",
                "src/node_async_queue.cpp",
                "src/node_event_handler.h",
                "src/node_event_handler.cpp",
                "src/node_helper.h",
                "src/node_helper.cpp",
            ],
            "conditions": [
                [
                    "OS=='win'",
                    {
                        "copies": [{
                            "destination": "<(PRODUCT_DIR)",
                            "files": [
                            ]
                        }],
                        "defines": [
                            "WIN32",
                            "WIN32_LEAN_AND_MEAN"
                        ],
                        "library_dirs": [
                            "../../lib/release/",
                        ],
                        "link_settings": {
                            "libraries": [
                                "-slsdk.lib",
                            ]
                        },
                        "msvs_settings": {
                            "VCCLCompilerTool": {
                                # "WarningLevel": "3",
                                # "DisableSpecificWarnings": ["4819"],
                                # "WarnAsError": "false",
                                # "ExceptionHandling": "0",
                                "AdditionalOptions": [
                                    # "/EHsc",
                                    "/utf-8"
                                ]
                            }
                        },
                        "defines!": [
                            # "_USING_V110_SDK71_",
                            # "_HAS_EXCEPTIONS=0"
                        ],
                        "sources": [
                            "src/win_delay_load_hook.cpp",
                            "src/framework.h",
                        ],
                        "include_dirs": [
                            "../../inc/node/",
                        ],
                        "configurations": {
                            "Release": {
                                "msvs_settings": {
                                    "VCCLCompilerTool": {
                                        # 多线程 MT (/MT)
                                        "RuntimeLibrary": "0",
                                        # 完全优化 /Os
                                        "Optimization": "2",
                                        # 使用内部函数 /Oi
                                        "EnableIntrinsicFunctions": "true",
                                        # 程序数据库 (/Zi)
                                        "DebugInformationFormat": "3",
                                        "AdditionalOptions": [
                                        ]
                                    }
                                },
                            },
                            "Debug": {
                                "msvs_settings": {
                                    "VCCLCompilerTool": {
                                        "RuntimeLibrary": "3",
                                        # "WarningLevel": "3",
                                        # "DisableSpecificWarnings": ["4819"],
                                        # "WarnAsError": "false",
                                        # "ExceptionHandling": "0",
                                        "AdditionalOptions": [
                                        ]
                                    }
                                },
                            }
                        }
                    }
                ],
                [
                    "OS=='mac'",
                    {
                        "copies": [{
                            "destination": "<(PRODUCT_DIR)",
                            "files": [
                                "statics/SnipManager.framework"
                            ]
                        }],
                        "defines": [
                            "__MAC__"
                        ],
                        # "mac_framework_dirs": [
                        #     "${PROJECT_DIR}"
                        # ],
                        # "library_dirs": [
                        #     "${PROJECT_DIR}",
                        #     "/System/Library/Frameworks"
                        # ],
                        "link_settings": {
                            "libraries": [
                                "<(CurrentDir)/statics/SnipManager.framework/Versions/Current/SnipManager",
                                "/System/Library/Frameworks/Foundation.framework",
                                "/System/Library/Frameworks/CoreFoundation.framework",
                            ]
                        },
                        "defines!": [
                            # "_NOEXCEPT",
                            "-std=c++11"
                        ],
                        "sources": [
                            # "utils.mm"
                        ],
                        "include_dirs": [
                            "./statics/SnipManager.framework/Versions/A/Headers/",
                        ],
                        "xcode_settings": {
                            "OTHER_LDFLAGS": ["-Wl,-rpath,@loader_path"],
                            "GCC_PREPROCESSOR_DEFINITIONS": [
                                "MODULE_VERSION=@\\\"$(node -p \"require('./package.json').version\")\\\""
                            ],
                            # "ALWAYS_SEARCH_USER_PATHS": "NO",
                            #"i386", "x86_64"
                            "ARCHS": ["x86_64"],
                            "MACOSX_DEPLOYMENT_TARGET": "10.14",
                            "VALID_ARCHS": ["x86_64"],
                            "CC": "clang",
                            "CXX": "clang++",
                            "GCC_VERSION": "com.apple.compilers.llvm.clang.1_0",
                            # "CLANG_CXX_LANGUAGE_STANDARD": "c++0x",
                            # libstdc++, c++11, libc++
                            # "CLANG_CXX_LIBRARY": "libstdc++",
                            # "GCC_ENABLE_OBJC_GC": "unsupported",
                            "EXCUTABLE_EXTENSION": "node",
                            "FRAMEWORK_SEARCH_PATHS": [
                                "<(CurrentDir)",
                                "/System/Library/Frameworks",
                                "<(CurrentDir)/statics",
                            ],
                            # "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
                            # "GCC_SYMBOLS_PRIVATE_EXTERN": "NO",
                            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                            # "DEPLOYMENT_POSTPROCESSING": "YES",
                            "OTHER_CFLAGS": [
                                # "-framework Foundation",
                                # "-framework CoreFoundation"
                                # "-fno-eliminate-unused-debug-symbols",
                                # "-mmacosx-version-min=10.8",
                                # compile use oc++
                                #"-x objective-c++",
                            ],
                            # "WARNING_CFLAGS": ["-Wno-deprecated-declarations"],
                            # "WARNING_CFLAGS!": ["-Wall", "-Wextra",],
                            # "WARNING_CXXFLAGS": ["-Wstrict-aliasing", "-Wno-deprecated",],
                        },  # xcode_settings
                        "defines": [
                            "__MAC__",
                            "_LP64",
                            "__LP64__",
                            "__x86_64__"
                        ],
                        "cflags": [
                            "-m64",
                            "-arch x86_64",
                            "-DLARGEFILE64_SOURCE",
                            "-D_FILE_OFFSET_BITS=64"
                        ],
                        "cflags_cc": [
                            "-m64",
                            "-arch x86_64",
                            "-DLARGEFILE64_SOURCE",
                            "-D_FILE_OFFSET_BITS=64"
                        ]
                    }
                ]
            ]
        }
    ]
}
