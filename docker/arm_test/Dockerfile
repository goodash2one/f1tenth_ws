FROM arm64v8/ubuntu:22.04

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN set -eux; \
       key='C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654'; \
       export GNUPGHOME="$(mktemp -d)"; \
       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
       mkdir -p /usr/share/keyrings; \
       gpg --batch --export "$key" > /usr/share/keyrings/ros2-latest-archive-keyring.gpg; \
       gpgconf --kill all; \
       rm -rf "$GNUPGHOME"

# setup sources.list
RUN echo "deb [ signed-by=/usr/share/keyrings/ros2-latest-archive-keyring.gpg ] http://packages.ros.org/ros2/ubuntu jammy main" > /etc/apt/sources.list.d/ros2-latest.list

# setup environment
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ENV ROS_DISTRO=humble

# install ros2 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop=0.10.0-1* \
	vim \
	python3-pip \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
	rosdep update --rosdistro $ROS_DISTRO

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

SHELL ["/bin/bash", "-c"]

## arguments about user
ARG UID=1000
ARG UNAME=docker
ARG PW=root

## create user based on user of host
RUN useradd -u $UID -m -s /bin/bash $UNAME && \
    echo $UNAME:$PW|chpasswd && \
    usermod -aG sudo $UNAME && \
    echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

## change root user to new user && prepare to use packages
USER $UNAME
WORKDIR /home/$UNAME
RUN sudo apt-get update && rosdep update

## clone repo
RUN git clone https://github.com/f1tenth/f1tenth_gym.git && \
	mkdir -p f1tenth_ws/src && cd f1tenth_ws/src && \
    git clone https://github.com/goodash2one/f1tenth_gym_ros.git && \
	git clone https://github.com/goodash2one/slam_toolbox.git && \
	git clone https://github.com/goodash2one/particle_filter.git

## install f1tenth_gym && configuring && check dependencies
RUN cd f1tenth_gym && pip3 install -e .
RUN sed -i "45s/user/$UNAME/" f1tenth_ws/src/f1tenth_gym_ros/config/sim.yaml
RUN cd f1tenth_ws && rosdep install -i --from-path src --ignore-src --rosdistro humble -r -y

## build range_libc python wrapper
RUN sudo pip install cython && \
	cd f1tenth_ws/src/particle_filter/range_libc/pywrapper && ./compile.sh

## colcon-build workspace
RUN source /opt/ros/humble/setup.bash && \
    cd f1tenth_ws && colcon build


RUN echo "alias underlay=\"source /opt/ros/$ROS_DISTRO/setup.bash\"" >> .bashrc && \
	echo "alias overlay=\"source install/setup.bash\"" >> .bashrc
