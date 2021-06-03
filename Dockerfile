FROM ubuntu:20.04


ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install -y \
        gcc g++ build-essential cmake bash libxcb1-dev libicu-dev \
        libssl-dev linux-headers-generic curl git libxrender-dev \
         libpng-dev libjpeg-turbo8 libjpeg-turbo8-dev libicu-dev \
        libgles2-mesa libgles2-mesa-dev libfreetype6-dev libsqlite3-dev \
        libfftw3-dev libqt5svg5-dev libjack0 jackd libjack-dev git qt5-default \
        libogg-dev libvorbis-dev bzip2 gperf bison ruby flex && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/hselasky/hpsjam

WORKDIR hpsjam

RUN git checkout v1.0.14

RUN QMAKE_CFLAGS_ISYSTEM="" qmake PREFIX=/usr QMAKE_CFLAGS_ISYSTEM="" && \
    make all && \
    make install


FROM ubuntu:20.04

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install -y \
        bash libjpeg-turbo8 libgles2-mesa libjack0 jackd qt5-default libfftw3-3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/bin/HpsJam .

ENV HPS_JAM_PORT=22124
ENV HPS_JAM_PEERS=16

EXPOSE $HPS_JAM_PORT/udp

CMD ./HpsJam --server --peers $HPS_JAM_PEERS --port $HPS_JAM_PORT --jacknoconnect

