import os
import shutil

from conans import ConanFile, tools


class DocgenConan(ConanFile):
    name = 'docgen'
    version = tools.load('version.txt').strip()
    license = '0BSD'
    url = 'https://github.com/DavidZemon/docgen.git'
    description = 'Doxygen documentation generation utilities'
    settings = {
        'os': None,
        'compiler': None
    }

    exports = 'version.txt'
    exports_sources = '*', '!.idea/*'

    @property
    def _source_subfolder(self):
        return '.'

    def package(self):
        os.makedirs(os.path.join(f'{self.package_folder}', 'licenses'))
        shutil.copy2(
            os.path.join(self._source_subfolder, 'license.txt'),
            os.path.join(f'{self.package_folder}', 'licenses', self.name)
        )

        os.makedirs(f'{self.package_folder}/res')
        self.copy(
            'resources/*',
            f'{self.package_folder}/res/resources',
            src=self._source_subfolder,
            keep_path=False
        )
        self.copy(
            'Doxyfile.in',
            f'{self.package_folder}/res',
            src=self._source_subfolder,
            keep_path=False
        )
        self.copy(
            'DocGen-functions.cmake',
            f'{self.package_folder}/res',
            src=self._source_subfolder,
            keep_path=False
        )

    def package_info(self):
        self.cpp_info.libdirs = []
        self.cpp_info.builddirs = [os.path.join('res')]

        self.cpp_info.set_property('cmake_file_name', 'DocGen')
        self.cpp_info.set_property('cmake_target_name', 'DocGen')
        self.cpp_info.set_property(
            'cmake_build_modules',
            [os.path.join('res', 'DocGen-functions.cmake')]
        )
