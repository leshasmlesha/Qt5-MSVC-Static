cd sources
pip3 install "conan<2.0"
conan profile new --detect default
conan remote add -f conan https://center.conan.io
conan remote add -f nrel https://conan.openstudio.net/artifactory/api/conan/openstudio
conan config set general.revisions_enabled=1
curl https://codeload.github.com/qtwebkit/conan-icu/zip/refs/heads/stable/65.1 -o icu.zip
curl https://codeload.github.com/qtwebkit/conan-libxml2/zip/refs/heads/stable/2.9.10 -o libxml2.zip
curl https://codeload.github.com/qtwebkit/conan-libxslt/zip/refs/heads/stable/1.1.34 -o libxslt.zip
curl https://codeload.github.com/qtwebkit/conan-libjpeg-turbo/zip/refs/heads/stable/2.0.5 -o libjpeg-turbo.zip
7z %ZOPTS% icu.zip
7z %ZOPTS% libxml2.zip
7z %ZOPTS% libxslt.zip
7z %ZOPTS% libjpeg-turbo.zip
cd conan-libxml2-stable-*
conan create . qtproject/stable
cd ..
cd conan-icu-stable-*
copy /y ..\..\Tools\patches\conan\icu.py icu_base.py
conan create . qtproject/stable
cd ..
cd conan-libxslt-stable-*
conan create . qtproject/stable
cd ..
cd conan-libjpeg-turbo-stable-*
conan create . qtproject/stable
cd ..