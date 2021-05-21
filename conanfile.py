from conans import ConanFile, tools


class DocgenConan(ConanFile):
    name = 'docgen'
    version = tools.load('version.txt').strip()
    license = '0BSD'
    url = 'https://github.com/DavidZemon/docgen.git'
    description = 'Doxygen documentation generation utilities'

    exports = 'version.txt'
    exports_sources = '*', '!.idea/*'

    def package(self):
        self.run('make DESTDIR={0} install'.format(self.package_folder))
