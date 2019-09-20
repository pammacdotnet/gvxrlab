FROM ubuntu:18.04
#FROM python:3.7-slim
RUN mkdir -p /usr/share/man/man1
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	python3-pip python3 python3-dev \ 
	cmake subversion build-essential wget zlib1g-dev \
	swig libglew-dev xorg-dev libx11-dev xorg-dev fftw3-dev libassimp-dev libtiff5-dev \
	python3-tk xvfb octave-image liboctave-dev less libglfw3-dev libtool make autoconf pkg-config
# ruby-dev ruby git libzmq3-dev libczmq-dev libffi-dev

#RUN apt-get install --fix-missing
#RUN pip3 install --no-cache --upgrade pip
RUN pip3 install --upgrade pip
RUN pip3 install notebook xvfbwrapper
RUN pip3 install numpy matplotlib image pillow octave_kernel scipy scikit-image traitlets requests bqplot ipywidgets ipyvolume matplotlib pandas ipyleaflet pythreejs ipyevents ipysheet ipytree pywwt ipympl voila jupyterlab voila-vuetify

ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

WORKDIR ${HOME}
RUN wget -qO- https://www.dropbox.com/s/scrr0xp3kebrbad/gvxrsource.tgz?dl=1 | tar --transform 's/^dbt2-0.37.50.3/dbt2/' -xvz
RUN mkdir GVXRbuild
RUN mkdir GVXR
WORKDIR ${HOME}/GVXRbuild
RUN cmake ../gvirtualxray-trunk -DBUILD_PYTHON3=ON \
	-DBUILD_RUBY=OFF \
	-DUSE_SYSTEM_XCOM=OFF -DXCOM_PATH=${HOME}/GVXR/XCOM -DUSE_SYSTEM_ASSIMP=ON -DBUILD_OCTAVE=ON -DUSE_SYSTEM_GLFW=OFF
RUN make
WORKDIR ${HOME}
RUN echo "addpath('${HOME}/GVXR')" > ${HOME}/.octaverc
RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/python3/* ${HOME}/GVXR/
# RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/ruby/* ${HOME}/GVXR/
RUN cp -R ${HOME}/GVXRbuild/tools_bin/Wrappers/octave/* ${HOME}/GVXR/
RUN rm -rf GVXRbuild gvirtualxray-trunk

# RUN set -e
# RUN echo "Starting X virtual framebuffer (Xvfb) in background..."
# RUN export DISPLAY=:99.0
# ENV DISPLAY :99.0
# RUN Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
# RUN sleep 3
# RUN exec "$@"
ENV DISPLAY=":99"

USER ${USER}

ENV PYTHONPATH $PYTHONPATH:${HOME}/GVXR
COPY dragon.stl ${HOME}/
COPY spider.stl ${HOME}/