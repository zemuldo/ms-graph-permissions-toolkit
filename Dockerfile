# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
ARG ALPINE_VERSION=3.16

FROM elixir:1.14-alpine AS builder

ARG APP_VSN=0.1.0
ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV}

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    nodejs \
    npm \
    git \
    build-base && \
    mix local.rebar --force && \
    mix local.hex --force

# Install and compile mix dependencies
COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

# Install assets dependencies
WORKDIR /opt/app/assets
COPY assets/package.json assets/package-lock.json ./
RUN npm install

# Compile app and assets
WORKDIR /opt/app
COPY . .
RUN mix do compile, assets.deploy

# Release
RUN mix release
RUN mkdir -p release
RUN tar -czvf release/scrapper.tar.gz -C _build/prod/rel/scrapper .

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

RUN apk update && \
    apk add --no-cache \
    postgresql-client bash openssl libgcc libstdc++ ncurses-libs qpdf openssh

RUN echo "root:Docker!" | chpasswd 

COPY ssh/sshd_config /etc/ssh/

# Copy and configure the ssh_setup file
RUN mkdir -p /tmp
COPY ssh/ssh_setup.sh /tmp
RUN chmod +x /tmp/ssh_setup.sh \
    && (sleep 1;/tmp/ssh_setup.sh 2>&1 > /dev/null)

# Open port 2222 for SSH access
EXPOSE 4000 2222

ENV REPLACE_OS_VARS=true \
    APP_NAME=scrapper

WORKDIR /opt/app

COPY --from=builder /opt/app/release .

RUN tar -xzf scrapper.tar.gz && \
    rm scrapper.tar.gz

COPY sh/docker_init.sh ./

ENTRYPOINT ["bash", "docker_init.sh", "start"]