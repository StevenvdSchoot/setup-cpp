#### Base Image
FROM ubuntu:22.04 AS base

# add setup-cpp
WORKDIR "/"
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends wget
RUN wget --no-verbose "https://github.com/aminya/setup-cpp/releases/download/v0.26.1/setup-cpp-x64-linux"
RUN chmod +x ./setup-cpp-x64-linux

# install llvm, cmake, ninja, and ccache
RUN ./setup-cpp-x64-linux --compiler llvm --cmake true --ninja true --ccache true --vcpkg true --task true

CMD source ~/.cpprc
ENTRYPOINT [ "/bin/bash" ]

#### Building
FROM base AS builder
ADD ./dev/cpp_vcpkg_project /home/app
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
