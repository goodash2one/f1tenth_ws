# This is an auto generated Dockerfile for ros:desktop
# generated from docker_images_ros2/create_ros_image.Dockerfile.em
FROM ros:humble
SHELL ["/bin/bash", "-c"]

# install ros2 packages
## add vim, pip3 
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop=0.10.0-1* \
	vim \
	python3-pip \
    && rm -rf /var/lib/apt/lists/*

## install python3.8, venv
RUN apt update && \
	apt install -y software-properties-common && \
	add-apt-repository -y ppa:deadsnakes/ppa && \
	apt update && \
	apt install -y python3.8 python3.8-venv

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
	git clone https://github.com/CL2-UWaterloo/Raceline-Optimization.git && \
	mkdir -p f1tenth_ws/src && cd f1tenth_ws/src && \
    git clone https://github.com/goodash2one/f1tenth_gym_ros.git && \
	git clone https://github.com/goodash2one/slam_toolbox.git && \
	git clone https://github.com/goodash2one/particle_filter.git

## clone packages from CL2-UWaterloo/f1tenth_ws/src
RUN cd f1tenth_ws/src && git init && \
	git config core.sparseCheckout true && \
	git remote add origin https://github.com/CL2-UWaterloo/f1tenth_ws.git && \
	echo "src/pure_pursuit" >> .git/info/sparse-checkout && \
	git pull origin main && rm -rf .git/ && mv src CL2-UWaterloo && \
	cd CL2-UWaterloo && git init && \
	git config user.name $UNAME && git config user.email "you@example.com" && \
	git add . && git commit -m "clone packages from CL2-UWaterloo/f1tenth_ws/src"

## install f1tenth_gym && configuring && check dependencies
RUN cd f1tenth_gym && pip3 install -e .
RUN sed -i "45s/user/$UNAME/" f1tenth_ws/src/f1tenth_gym_ros/config/sim.yaml
RUN cd f1tenth_ws && rosdep install -i --from-path src --ignore-src --rosdistro humble -r -y

## build range_libc python wrapper
RUN sudo pip install cython && \
	cd f1tenth_ws/src/particle_filter/range_libc/pywrapper && ./compile.sh	## NO CUDA

## setup venv for Raceline-Optimization
RUN cd Raceline-Optimization && \
	python3.8 -m venv raceline && \
	source raceline/bin/activate && \
	pip install -r requirements.txt && \
	pip install ipykernel notebook && \
	python -m ipykernel install --user --name raceline && \
	deactivate

## colcon-build workspace
RUN source /opt/ros/humble/setup.bash && \
    cd f1tenth_ws && colcon build

#RUN echo "PATH=\$PATH:/home/$UNAME/.local/bin" >> .bashrc
RUN echo "alias underlay=\"source /opt/ros/$ROS_DISTRO/setup.bash\"" >> .bashrc && \
	echo "alias overlay=\"source install/setup.bash\"" >> .bashrc
