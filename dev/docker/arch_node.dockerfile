## base image
FROM archlinux as base

RUN pacman -Syuu --noconfirm
RUN pacman-db-upgrade

# nodejs
RUN pacman -S --noconfirm --needed nodejs

# curl for downloading setup-cpp
RUN pacman -S --noconfirm --needed curl

# add setup-cpp.js
COPY "./dist/node12" "/"
WORKDIR "/"

# run installation
RUN node ./setup-cpp.js --compiler llvm --cmake true --ninja true --cppcheck true --ccache true --vcpkg true --doxygen true --gcovr true --task true

# clean up
RUN pacman -Scc --noconfirm
RUN rm -rf /tmp/*

CMD source ~/.cpprc
ENTRYPOINT [ "/bin/bash" ]

#### Building
FROM base AS builder
COPY ./dev/cpp_vcpkg_project /home/app
WORKDIR /home/app
RUN bash -c 'source ~/.cpprc \
    && task build'

### Running environment
# use a distroless image or ubuntu:22.04 if you wish
FROM gcr.io/distroless/cc
# copy the built binaries and their runtime dependencies
COPY --from=builder /home/app/build/my_exe/Release/ /home/app/
WORKDIR /home/app/
ENTRYPOINT ["./my_exe"]
