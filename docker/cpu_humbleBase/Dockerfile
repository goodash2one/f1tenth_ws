# This is an auto generated Dockerfile for ros:desktop
# generated from docker_images_ros2/create_ros_image.Dockerfile.em
FROM ros:humble-ros-base-jammy
SHELL ["/bin/bash", "-c"]

# install ros2 packages
## add vim, pip3 
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop=0.10.0-1* \
	vim \
	python3-pip \
    && rm -rf /var/lib/apt/lists/*

########################################################

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
	cd f1tenth_ws/src/particle_filter/range_libc/pywrapper && ./compile.sh	## NO CUDA

## colcon-build workspace
RUN source /opt/ros/humble/setup.bash && \
    cd f1tenth_ws && colcon build


RUN echo "alias underlay=\"source /opt/ros/$ROS_DISTRO/setup.bash\"" >> .bashrc && \
	echo "alias overlay=\"source install/setup.bash\"" >> .bashrc
