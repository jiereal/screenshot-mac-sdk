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
                "src",
                "<!(node -p \"require('node-addon-api').include_dir\")"
            ],
            "defines": [
                "NODE_ADDON_API_CPP_EXCEPTIONS"
            ],
            "sources": [
                "src/framework.h",
                "src/pch.h",
                "src/pch.cpp",
                "src/screenshot_event_handler_napi.h",
                "src/screenshot_event_handler_napi.cpp",
                "src/screenshot_sdk_napi.cpp",
                "src/define/sdk_define.h",
                "src/node_async_queue.h",
                "src/node_async_queue.cpp",
                "src/node_event_handler.h",
                "src/node_event_handler.cpp",
                "src/node_helper.h",
                "src/node_helper.cpp",
                "src/napi_helper.h",
                "src/napi_helper.cpp",
            ],
            "dependencies": [
                "<!(node -p \"require('node-addon-api').gyp\")"
            ],
            "conditions": [
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
                            "__MAC__",
                            "NODE_ADDON_API_CPP_EXCEPTIONS"
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
                            "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
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
                            "__x86_64__",
                            "MODULE_VERSION=\"<!(node -p \"require('./package.json').version\")\""
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
