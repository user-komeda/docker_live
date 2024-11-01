FROM almalinux:minimal

RUN mkdir /tmp_build
RUN mkdir ~/ffmpeg_sources

# Rails app lives here
WORKDIR /tmp_build
# Set production environmen


RUN echo "/usr/local/lib" >> /etc/ld.so.conf && echo "/usr/local/lib64" >> /etc/ld.so.conf &&  ldconfig

RUN microdnf -y install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make pkgconfig zlib-devel tcl openssl openssl-devel

RUN git clone https://github.com/Haivision/srt.git && cd srt && ./configure && make && make install
WORKDIR ~/ffmpeg_sources

RUN curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 && tar xjvf nasm-2.15.05.tar.bz2 && cd nasm-2.15.05 && ./autogen.sh && ./configure && make && make install

RUN curl -O -L https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && tar xzvf yasm-1.3.0.tar.gz && cd yasm-1.3.0 && ./configure && make && make install

RUN git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git && cd x264 && ./configure --enable-static &&  make && make install

RUN git clone --branch stable --depth 2 https://bitbucket.org/multicoreware/x265_git && cd x265_git/build/linux  && cmake -G "Unix Makefiles" -DENABLE_SHARED:bool=off  ../../source && echo ls  && make && make install

RUN git clone --depth 1 https://github.com/mstorsjo/fdk-aac && cd fdk-aac && autoreconf -fiv && ./configure --disable-shared && make && make install 

RUN curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz && tar xzvf lame-3.100.tar.gz && cd lame-3.100 && ./configure  --disable-shared --enable-nasm && make && make install 

RUN curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz && tar xzvf opus-1.3.1.tar.gz && cd opus-1.3.1 && ./configure  --disable-shared && make && make install

RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && cd libvpx && ./configure  --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && make && make install 


RUN ldconfig && ldconfig -p | grep libx

RUN curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && tar xjvf ffmpeg-snapshot.tar.bz2

RUN cd ffmpeg &&  PATH="/usr/local/bin:$PATH" PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig" ./configure   --prefix="/usr/local"   --pkg-config-flags="--static"   --extra-cflags="-I/usr/local/include"   --extra-ldflags="-L/usr/local/lib"   --extra-libs=-lpthread   --extra-libs=-lm   --bindir="/usr/local/bin"   --enable-gpl   --enable-libfdk_aac   --enable-libfreetype   --enable-libharfbuzz   --enable-libmp3lame   --enable-libopus   --enable-libvpx   --enable-libx264     --enable-nonfree --enable-libsrt && make && make install

RUN  ffmpeg -h && ffmpeg -version
