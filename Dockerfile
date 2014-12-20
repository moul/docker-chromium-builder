FROM ubuntu:14.04
MAINTAINER Manfred Touron <m@42.am> (@moul)


RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y -q upgrade
RUN apt-get -y -q install build-essential curl lsb-release
# && dpkg --add-architecture i386


RUN curl -L https://src.chromium.org/chrome/trunk/src/build/install-build-deps.sh > /tmp/install-build-deps.sh \
 && chmod +x /tmp/install-build-deps.sh
RUN apt-get -y -q install gcc-arm-linux-gnueabihf g++-4.8-multilib-arm-linux-gnueabihf gcc-4.8-multilib-arm-linux-gnueabihf
RUN /tmp/install-build-deps.sh --no-prompt --arm --no-chromeos-fonts --no-nacl --no-syms
RUN rm /tmp/install-build-deps.sh

RUN useradd -m user
USER user
ENV HOME /home/user
WORKDIR /home/user

ENV DEPOT_TOOLS /home/user/depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS
ENV PATH $PATH:$DEPOT_TOOLS
RUN echo -e "\n# Add Chromium's depot_tools to the PATH." >> .bashrc
RUN echo "export PATH=\"\$PATH:$DEPOT_TOOLS\"" >> .bashrc

RUN fetch chromium --nosvn=True
WORKDIR src

RUN ninja -C out/Release chrome -j18
