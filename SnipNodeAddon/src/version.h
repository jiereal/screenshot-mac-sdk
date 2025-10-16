#pragma once
#include <string>

#ifndef MODULE_VERSION
#define MODULE_VERSION "0.0.0-unknown"
#endif

inline std::string GetModuleVersion() {
    return std::string(MODULE_VERSION);
}