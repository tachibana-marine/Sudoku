FROM debian:latest

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ENV SHELL=/bin/bash

RUN groupadd --gid $USER_GID $USERNAME &&\
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME &&\
    apt-get update &&\
    apt-get install -y sudo &&\
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&\
    chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt update && apt upgrade -y
# Install tools to download and extract Godot executable
RUN apt update && apt install wget unzip git -y    
# Install python and gdtoolkit for the linter
RUN apt update && apt install python3 python3-pip -y && python3 -m pip install gdtoolkit --break-system-packages
# Install gedit to get gui libs
RUN apt update && apt install  gedit -y
# Install audio related libs
RUN apt update && apt install alsa-utils ffmpeg pulseaudio -y

RUN mkdir /Godot
WORKDIR /Godot
RUN wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip && unzip Godot_v4.3-stable_linux.x86_64.zip

USER $USERNAME

