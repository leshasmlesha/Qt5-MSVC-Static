cd tools/patches/conan
pip3 install "conan<2.0"
conan profile new --detect default
conan remote add -f conan https://center.conan.io
conan remote add -f nrel https://conan.openstudio.net/artifactory/api/conan/openstudio
cd libxml2
conan create . qtproject/stable
cd ..
cd icu
conan create . qtproject/stable
cd ..
cd libxslt
conan create . qtproject/stable
cd ..
cd libjpeg-turbo
conan create . qtproject/stable
cd ..