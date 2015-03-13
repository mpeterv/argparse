# A script for setting up broken Lua rocks for travis-ci testing.

sudo luarocks install dkjson --deps-mode=none

git clone https://github.com/Olivine-Labs/busted
cd busted
sudo luarocks make busted-scm-0.rockspec
cd ..
