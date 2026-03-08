FROM opensuse/tumbleweed:latest

RUN zypper refresh && zypper --non-interactive dup
RUN zypper refresh && zypper --non-interactive install pipewire pipewire-devel dbus-1-daemon wget
RUN rpm --verbose --import https://build.opensuse.org/projects/devel:languages:crystal/signing_keys/download?kind=gpg
RUN zypper addrepo --refresh --priority 50 obs://devel:languages:crystal devel_languages_crystal
RUN zypper refresh && zypper --non-interactive install crystal

RUN mkdir -p /run/dbus
RUN mkdir -p /run/pipewire

ENV PIPEWIRE_RUNTIME_DIR /run/pipewire

WORKDIR /app
