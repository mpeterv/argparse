# A script for setting up environment for travis-ci testing. 
# Sets up Lua and Luarocks. 
# LUA must be "Lua 5.1", "Lua 5.2" or "LuaJIT 2.0". 

if [ "$LUA" == "LuaJIT 2.0" ]; then
  curl http://luajit.org/download/LuaJIT-2.0.2.tar.gz | tar xz
  cd LuaJIT-2.0.2
  make && sudo make install
  cd ..;
else
  if [ "$LUA" == "Lua 5.1" ]; then
    curl http://www.lua.org/ftp/lua-5.1.5.tar.gz | tar xz
    cd lua-5.1.5;
  elif [ "$LUA" == "Lua 5.2" ]; then
    curl http://www.lua.org/ftp/lua-5.2.3.tar.gz | tar xz
    cd lua-5.2.3;
  fi

  sudo make linux install
  cd ..;
fi

curl http://luarocks.org/releases/luarocks-2.1.1.tar.gz | tar xz
cd luarocks-2.1.1

if [ "$LUA" == "LuaJIT 2.0" ]; then
  ./configure --lua-suffix=jit --with-lua-include=/usr/local/include/luajit-2.0;
else
  ./configure;
fi

make && sudo make install
cd ..
