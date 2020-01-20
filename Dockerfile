# Set the Docker image you want to base your image off.
FROM elixir:1.9 as builder

ENV MIX_ENV="prod" \
  PORT="5000"

# Install other stable dependencies that don't change often
RUN apt-get update && \
  apt-get install -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

FROM debian:buster-slim

RUN apt-get -qq update
RUN apt-get -qq install -y locales locales-all

# Set LOCALE to UTF8
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV MIX_ENV="prod" \
  PORT="5000"

# Exposes this port from the docker container to the host machine
EXPOSE 5000

# Because these dirs were stripped from the slim package and
# caused issues installing postgres-client
RUN seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{}

WORKDIR /app
COPY --from=builder /opt/app/_build/prod/rel/deadend ./

# The command to run when this image starts up
CMD ["./bin/deadend", "start"]
