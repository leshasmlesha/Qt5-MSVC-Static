import os
import glob
import platform
import shutil
from conans import ConanFile, tools, AutoToolsBuildEnvironment


class ICUBase(ConanFile):
    version = "65.1"
    homepage = "http://site.icu-project.org"
    license = "ICU"
    description = "ICU is a mature, widely used set of C/C++ and Java libraries " \
                  "providing Unicode and Globalization support for software applications."
    url = "https://github.com/qtwebkit/conan-icu"
    topics = ("conan", "icu", "icu4c", "i see you", "unicode")
    exports = ["icu_base.py"]
    # exports_sources = ["patches/*.patch"]
    _source_subfolder = "source_subfolder"
    _build_subfolder = "build_subfolder"
    _env_build = None
    short_paths = True

    @property
    def _the_os(self):
        return self.settings.get_safe("os") or self.settings.get_safe("os_build")

    @property
    def _the_arch(self):
        return self.settings.get_safe("arch") or self.settings.get_safe("arch_build")

    @property
    def _is_msvc(self):
        return self.settings.compiler == "Visual Studio"

    @property
    def _is_mingw(self):
        return self._the_os == "Windows" and self.settings.compiler == "gcc"

    def build_requirements(self):
        if self._the_os == "Windows":
            #self.build_requires("cygwin_installer/2.9.0@bincrafters/stable")
            self.build_requires("msys2/cci.latest")

    def source(self):
        version = self.version.replace('.', '-')
        version_with_underscore = self.version.replace('.', '_')
        source_url = "https://github.com/unicode-org/icu/releases/download/release-{0}/icu4c-{1}-src.tgz".format(version, version_with_underscore)
        self.output.info("Downloading {0} ...".format(source_url))
        tools.get(source_url,
                  sha256="53e37466b3d6d6d01ead029e3567d873a43a5d1c668ed2278e253b683136d948")
        os.rename("icu", self._source_subfolder)

    def _workaround_icu_20545(self):
        if tools.os_info.is_windows:
            # https://unicode-org.atlassian.net/projects/ICU/issues/ICU-20545
            srcdir = os.path.join(self.build_folder, self._source_subfolder, "source")
            makeconv_cpp = os.path.join(srcdir, "tools", "makeconv", "makeconv.cpp")
            tools.replace_in_file(makeconv_cpp,
                                  "pathBuf.appendPathPart(arg, localError);",
                                  "pathBuf.append('/', localError); pathBuf.append(arg, localError);")

    def build(self):
        for filename in glob.glob("patches/*.patch"):
            self.output.info('applying patch "%s"' % filename)
            tools.patch(base_path=self._source_subfolder, patch_file=filename)

        if self._is_msvc:
            run_configure_icu_file = os.path.join(self._source_subfolder, 'source', 'runConfigureICU')

            flags = "-%s" % self.settings.compiler.runtime
            if self.settings.get_safe("build_type") == 'Debug':
                flags += " -FS"
            tools.replace_in_file(run_configure_icu_file, "-MDd", flags)
            tools.replace_in_file(run_configure_icu_file, "-MD", flags)

        self._workaround_icu_20545()

        self._env_build = AutoToolsBuildEnvironment(self)
        if not self.options.get_safe("shared"):
            self._env_build.defines.append("U_STATIC_IMPLEMENTATION")
        if tools.is_apple_os(self._the_os):
            self._env_build.defines.append("_DARWIN_C_SOURCE")
            if self.settings.get_safe("os.version"):
                self._env_build.flags.append(tools.apple_deployment_target_flag(self._the_os,
                                                                            self.settings.os.version))

        build_dir = os.path.join(self.build_folder, self._source_subfolder, 'build')
        os.mkdir(build_dir)

        with tools.vcvars(self.settings) if self._is_msvc else tools.no_op():
            with tools.environment_append(self._env_build.vars):
                with tools.chdir(build_dir):
                    # workaround for https://unicode-org.atlassian.net/browse/ICU-20531
                    os.makedirs(os.path.join("data", "out", "tmp"))

                    self.run(self._build_config_cmd, win_bash=tools.os_info.is_windows)
                    if self.options.get_safe("silent"):
                        silent = '--silent' if self.options.silent else 'VERBOSE=1'
                    else:
                        silent = '--silent'
                    command = "make {silent} -j {cpu_count}".format(silent=silent,
                                                                    cpu_count=tools.cpu_count())
                    self.run(command, win_bash=tools.os_info.is_windows)
                    if self.options.get_safe("with_unit_tests"):
                        command = "make {silent} check".format(silent=silent)
                        self.run(command, win_bash=tools.os_info.is_windows)
                    command = "make {silent} install".format(silent=silent)
                    self.run(command, win_bash=tools.os_info.is_windows)

        self._install_name_tool()

    def package(self):
        for dll in glob.glob( os.path.join( self.package_folder, 'lib', '*.dll' ) ):
            shutil.move( dll, os.path.join( self.package_folder, 'bin' ) )

        self.copy("LICENSE", dst="licenses", src=os.path.join(self.source_folder, self._source_subfolder))

    @staticmethod
    def detected_os():
        if tools.OSInfo().is_macos:
            return "Macos"
        if tools.OSInfo().is_windows:
            return "Windows"
        return platform.system()

    @property
    def cross_building(self):
        if tools.cross_building(self.settings):
            if self._the_os == self.detected_os():
                if self._the_arch == "x86" and tools.detected_architecture() == "x86_64":
                    return False
            return True
        return False

    @property
    def build_config_args(self):
        prefix = self.package_folder.replace('\\', '/')
        platform = {("Windows", "Visual Studio"): "Cygwin/MSVC",
                    ("Windows", "gcc"): "MinGW",
                    ("AIX", "gcc"): "AIX/GCC",
                    ("AIX", "xlc"): "AIX",
                    ("SunOS", "gcc"): "Solaris/GCC",
                    ("Linux", "gcc"): "Linux/gcc",
                    ("Linux", "clang"): "Linux",
                    ("Macos", "gcc"): "MacOSX",
                    ("Macos", "clang"): "MacOSX",
                    ("Macos", "apple-clang"): "MacOSX"}.get((str(self._the_os),
                                                             str(self.settings.compiler)))
        arch64 = ['x86_64', 'sparcv9', 'ppc64']
        bits = "64" if self._the_arch in arch64 else "32"
        args = [platform,
                "--prefix={0}".format(prefix),
                "--with-library-bits={0}".format(bits),
                "--disable-samples",
                "--disable-layout",
                "--disable-layoutex",
                "--disable-extras"]

        if self.cross_building:
            if self._env_build.build:
                args.append("--build=%s" % self._env_build.build)
            if self._env_build.host:
                args.append("--host=%s" % self._env_build.host)
            if self._env_build.target:
                args.append("--target=%s" % self._env_build.target)

        if self.options.get_safe("data_packaging"):
            args.append("--with-data-packaging={0}".format(self.options.data_packaging))
        else:
            args.append("--with-data-packaging=static")

        if self._is_mingw:
            mingw_chost = 'i686-w64-mingw32' if self._the_arch == 'x86' else 'x86_64-w64-mingw32'
            args.extend(["--build={0}".format(mingw_chost),
                         "--host={0}".format(mingw_chost)])

        if self.settings.get_safe("build_type") == "Debug":
            args.extend(["--disable-release", "--enable-debug"])
        if self.options.get_safe("shared"):
            args.extend(["--disable-static", "--enable-shared"])
        else:
            args.extend(["--enable-static", "--disable-shared"])
        if not self.options.get_safe("with_unit_tests"):
            args.append('--disable-tests')
        return args

    @property
    def _build_config_cmd(self):
        return "../source/runConfigureICU %s" % " ".join(self.build_config_args)

    def _install_name_tool(self):
        if tools.is_apple_os(self._the_os):
            with tools.chdir(os.path.join(self.package_folder, 'lib')):
                for dylib in glob.glob('*icu*.{0}.dylib'.format(self.version)):
                    command = 'install_name_tool -id {0} {1}'.format(os.path.basename(dylib), dylib)
                    self.output.info(command)
                    self.run(command)