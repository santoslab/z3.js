#!/bin/bash -e
if [ -e /opt/emsdk-portable ]; then
  source /opt/emsdk-portable/emsdk_env.sh
else
  if [ ! -e emsdk-portable ]; then
    rm -f emsdk-portable.tar.gz
    curl -O https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz
    tar xzf emsdk-portable.tar.gz
    rm -f emsdk-portable.tar.gz
    cd emsdk-portable
    ./emsdk update
    ./emsdk install latest
    ./emsdk activate latest
  else
    cd emsdk-portable
  #  printf "Should I update the emsdk? (y/N): "
  #  answer=$(read)
  #  if [ "$answer" == "y" -o "$answer" == "Y" ]; then
      ./emsdk update
  	./emsdk install latest
  	./emsdk activate latest
  #  fi
  fi
  source ./emsdk_env.sh
  cd ..
fi
git submodule update --init --recursive
cd z3
#if [ -e build ]; then
#    mv build build-$(stat -f "%Sm" -t "%Y%m%dT%H%M%S" build | sed 's/[ :]/_/g' - | sed 's/\..*/ /g')
#fi
rm -fR build
alias c++=em++
alias g++=em++
alias ar=emar
alias cc=emcc
alias gcc=emcc
alias cmake=emcmake
alias configure=emconfigure
alias ranlib=emranlib
export CC=emcc
export CXX=em++
python scripts/mk_make.py --x86 --githash=$(git rev-parse HEAD) --staticlib
cd build
sed -i.old -e 's/AR=ar/AR=emar/g' config.mk
sed -i.old -e 's/EXE_EXT=/EXE_EXT=.js/g' config.mk
sed -i.old -e 's/^\(LINK_EXTRA_FLAGS=.*\)/\1 -L\/usr\/lib32 -Oz -s DISABLE_EXCEPTION_CATCHING=0 -s ASSERTIONS=1/g' config.mk
emmake make
cd ../..
cp z3.js.pre z3.js
cat z3/build/z3.js >> z3.js
cat z3.js.post >> z3.js
cp z3/build/z3.js.mem .
rm -f z3/a.out.js
