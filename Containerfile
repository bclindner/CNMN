# build step
FROM docker.io/elixir:1.14 AS build

ENV MIX_ENV=prod
WORKDIR /build
COPY mix.exs mix.lock ./
COPY config ./config
# get hex and rebar (these ought to just come standard...)
RUN mix local.hex --force
RUN mix local.rebar --force
# install
RUN mix deps.get
# add source and compile
COPY lib ./lib
RUN mix compile
# build release
RUN mix release
# move release to the new folder, remove /build
RUN mv "_build/prod/rel/cnmn" /app
WORKDIR /app
RUN rm -rf /build

# set up runtime environment
FROM docker.io/debian:bullseye

# resolve locale issue
# (see https://stackoverflow.com/q/32407164)
ENV LANG=C.UTF-8
# install deps
RUN apt-get update && apt-get install -y ffmpeg python3 python3-pip imagemagick
RUN pip install yt-dlp==2023.07.06
# copy from the previous container
WORKDIR /app
COPY --from=build /app .

# use /app/bin/cnmn as entrypoint (s.t. we can attach with `[podman/docker] exec [...] remote`)
ENTRYPOINT ["/app/bin/cnmn"]
CMD ["start"]
