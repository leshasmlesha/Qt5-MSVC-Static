# Copyright (C) 2020 Konstantin Tokarev <annulen@yandex.ru>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

from conans import ConanFile, CMake, tools
import os
import shlex
import argparse

from conan_dependencies_version import get_dependencies, check_version

class QtWebKitConan(ConanFile):
    name = "qtwebkit"
    version = "5.212.0-alpha4"
    license = "LGPL-2.0-or-later, LGPL-2.1-or-later, BSD-2-Clause"
    url = "https://github.com/qtwebkit/qtwebkit"
    description = "Qt port of WebKit"
    topics = ("qt", "browser-engine", "webkit", "qt5", "qml", "qtwebkit")
    settings = "os", "compiler", "arch", "arch_build"
    generators = "cmake", "virtualenv", "txt"
    exports_sources = "../../*"
    no_copy_source = True
    options = {
        "qt": "ANY",
        "cmakeargs": "ANY",
        "build_type": "ANY",
        "install_prefix": "ANY",
        "qt_version": "ANY"
    }
    default_options = {
        "install_prefix": None,
        "qt_version": None,

        "icu:shared": False,
        "icu:data_packaging": "static",

        "libxml2:shared": False,
        "libxml2:iconv": False,
        "libxml2:icu": True,
        "libxml2:zlib": False,

        "libxslt:shared": False,

        "libjpeg-turbo:shared": False,
        "zlib:shared": False,
        "libpng:shared": False,
        "sqlite3:shared": False,
        "libwebp:shared": False
    }

    def build_requirements(self):

        if not tools.which("gperf"):
            self.build_requires("gperf/3.1")
        if not tools.which("ruby"):
            self.build_requires("ruby_installer/2.7.3@nrel/stable")
        if not tools.which("bison"):
            self.build_requires("bison/3.8.2")
        if not tools.which("flex"):
            self.build_requires("flex/2.6.4")
        #if not tools.which("ninja"):
        self.build_requires("ninja/[>=1.9.0]")
        if not tools.which("cmake"):
            self.build_requires("cmake/[>=3.18.2]")

    def requirements(self):
        # TODO: Handle case when custom ICU is needed (AppStore etc., MACOS_USE_SYSTEM_ICU=OFF in CMake)
        if self.settings.os == 'Windows':
            self.requires("icu/65.1@qtproject/stable")
            self.requires("libxml2/2.9.10@qtproject/stable")
            self.requires("libxslt/1.1.34@qtproject/stable")
            self.requires("zlib/1.2.11")
            self.requires("libwebp/1.1.0")

        # Qt binaries for Windows and macOS are built with bundled libraries, try to use same versions to avoid conflicts
        if self.settings.os == 'Windows' or self.settings.os == 'Macos':
            qt_version_ok = False
            qt_version = ""
            if self.options.qt_version:
                qt_version = str(self.options.qt_version)
                if check_version(qt_version):
                    self.output.info(f"Using adjusted dependency versions for Qt {qt_version}")
                    qt_version_ok = True
                else:
                    self.output.warn(f"Cannot use matching dependencies for {qt_version}. Runtime errors caused by libraries bundled with Qt may happen. Use Qt >= 5.12.6 to be on a safe side")

            if qt_version_ok:
                dep = get_dependencies(qt_version)
                self.requires("sqlite3/" + dep["sqlite"])
                self.requires("libjpeg-turbo/" + dep["libjpeg-turbo"] + "@qtproject/stable")
                self.requires("libpng/" + dep["libpng"])
            else:
                self.requires("sqlite3/3.33.0")
                self.requires("libpng/1.6.37")
                self.requires("libjpeg-turbo/2.0.5@qtproject/stable")

    def build(self):
        cmake = CMake(self, set_cmake_flags=True)
        cmake.generator = "Ninja"
        cmake.verbose = False
        cmake.definitions["QT_CONAN_DIR"] = self.build_folder
        cmake.definitions["QT_CONAN_FILE"] = __file__

        # if self.options.use_ccache:
        #    cmake.definitions["CMAKE_C_COMPILER_LAUNCHER"] = "ccache"
        #    cmake.definitions["CMAKE_CXX_COMPILER_LAUNCHER"] = "ccache"

        if self.options.qt:
            cmake.definitions["Qt5_DIR"] = os.path.join(
                str(self.options.qt), "lib", "cmake", "Qt5")
            self.output.info("Qt5 directory:" + cmake.definitions["Qt5_DIR"])

        if self.options.build_type:
            cmake.build_type = str(self.options.build_type)

        if self.options.cmakeargs:
            cmake_flags = shlex.split(str(self.options.cmakeargs))
        else:
            cmake_flags = None

        if "NINJAFLAGS" in os.environ:
            parser = argparse.ArgumentParser()
            parser.add_argument('-j', default=None, type=int)
            jarg, ninja_flags = parser.parse_known_args(
                shlex.split(os.environ["NINJAFLAGS"]))
            if jarg.j:
                os.environ['CONAN_CPU_COUNT'] = str(jarg.j)
            ninja_flags.insert(0, '--')
        else:
            ninja_flags = None

        if "CONAN_CPU_COUNT" in os.environ:
            os.environ['NINJAFLAGS'] = '-j ' + os.environ['CONAN_CPU_COUNT']

        if self.options.install_prefix:
            cmake.definitions["CMAKE_INSTALL_PREFIX"] = str(self.options.install_prefix)
        else:
            del cmake.definitions["CMAKE_INSTALL_PREFIX"]

        cmake.configure(args=cmake_flags)
        cmake.build(args=ninja_flags)
        cmake.install()

    def imports(self):
        if self.settings.os == 'Windows':
            # Visual Studio
            self.copy("sicuuc.lib", "./lib", "lib")
            self.copy("sicudt.lib", "./lib", "lib")
            self.copy("sicuin.lib", "./lib", "lib")
            self.copy("libxml2_a.lib", "./lib", "lib")
            self.copy("libxslt_a.lib", "./lib", "lib")
            self.copy("sqlite3.lib", "./lib", "lib")
            self.copy("zlib.lib", "./lib", "lib")
            self.copy("jpeg-static.lib", "./lib", "lib")
            self.copy("libpng16_static.lib", "./lib", "lib")
            self.copy("webp.lib", "./lib", "lib")

    def package(self):
        pass

    def package_info(self):
        pass
