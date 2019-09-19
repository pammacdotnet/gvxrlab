FROM ubuntu:18.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y subversion build-essential cmake python3-dev wget zlib1g-dev ruby-dev \
	swig libglew-dev xorg-dev libx11-dev xorg-dev fftw3-dev python3-pip libassimp-dev libtiff5-dev \
	python3-tk xvfb octave-image less libglfw3-dev libtool libffi-dev ruby ruby-dev make git libzmq3-dev autoconf pkg-config 

RUN apt-get install --fix-missing
RUN pip3 install numpy matplotlib image pillow octave_kernel notebook scipy scikit-image traitlets requests bqplot ipywidgets ipyvolume matplotlib pandas ipyleaflet pythreejs ipyevents ipysheet ipytree pywwt ipympl voila jupyterlab voila-vuetify
RUN gem install matplotlib

ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

WORKDIR ${HOME}
RUN git clone https://github.com/zeromq/czmq
WORKDIR ${HOME}/czmq
RUN ./autogen.sh && ./configure && make && make install

RUN gem install cztop
RUN gem install iruby --pre
RUN iruby register --force

WORKDIR ${HOME}


RUN svn checkout --non-interactive --trust-server-cert https://svn.code.sf.net/p/gvirtualxray/code/trunk gvirtualxray-trunk
RUN mkdir GVXRbuild
RUN mkdir GVXR
WORKDIR ${HOME}/GVXRbuild
RUN cmake ../gvirtualxray-trunk -DBUILD_PYTHON3=ON -DBUILD_RUBY=ON \
	-DUSE_SYSTEM_XCOM=OFF -DXCOM_PATH=${HOME}/GVXR/XCOM -DUSE_SYSTEM_ASSIMP=ON -DBUILD_OCTAVE=ON -DUSE_SYSTEM_GLFW=OFF
RUN make
WORKDIR ${HOME}
RUN echo "addpath('${HOME}/GVXR')" > ${HOME}/.octaverc
RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/python3/* ${HOME}/GVXR/
RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/ruby/* ${HOME}/GVXR/
RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/octave/* ${HOME}/GVXR/
RUN rm -rf GVXRbuild gvirtualxray-trunk
USER ${USER}
ENV PYTHONPATH $PYTHONPATH:${HOME}/GVXR
ENV RUBYLIB $RUBYLIB:${HOME}/GVXR