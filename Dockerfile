FROM --platform=linux/amd64 debian:12.5-slim as builder

# Install build-essential and tools
RUN apt-get update --assume-yes && \
        apt-get install --assume-yes build-essential debhelper \
        dpkg-dev valgrind clang

# Install package dependencies
RUN apt-get install --assume-yes libconfig-dev libconfig++-dev \
        libhiredis-dev libjson-c-dev libpq-dev librdkafka-dev

# Set environment variables
ENV CC=gcc LDFLAGS='' CFLAGS='-O2'

# Copy src files
COPY . /opt/src
WORKDIR /opt/src

# Build
RUN make

# Use debian image as binary runtime
FROM --platform=linux/amd64 debian:12.5-slim

# Install package dependencies
RUN apt-get update --assume-yes && \
        apt-get install --assume-yes libconfig-dev libconfig++-dev \
        libhiredis-dev libjson-c-dev libpq-dev librdkafka-dev
RUN apt-get clean 
RUN rm -rf /var/lib/apt/*.lz4

ENV CONFIG_FILE='/opt/config/schaufel.conf'

# Copy the binary from build image 
COPY --from=builder /opt/src/bin/schaufel /usr/local/bin/

CMD schaufel -C ${CONFIG_FILE}