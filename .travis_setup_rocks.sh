# A script for setting up Lua rocks for travis-ci testing.

sudo luarocks install dkjson --deps-mode=none

mkdir busted
wget -O - https://api.github.com/repos/Olivine-Labs/busted/tarball/master | tar xz -C busted --strip-components=1
cd busted
sudo luarocks make busted-scm-0.rockspec
cd ..

mkdir luacheck
wget -O - https://api.github.com/repos/mpeterv/luacheck/tarball/master | tar xz -C luacheck --strip-components=1
cd luacheck
sudo luarocks make
cd ..
