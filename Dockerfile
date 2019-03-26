FROM elixir:1.4
EXPOSE 1337 8090
ENV WEBSHELL_DIR=/webshell/logs
VOLUME /webshell/logs

WORKDIR /webshell

RUN mix local.hex --force
RUN mix local.rebar --force

ADD ./mix.exs ./mix.lock /webshell
RUN mix deps.get

ADD ./lib /webshell/lib
ADD ./web /webshell/web

RUN MIX_ENV=prod mix compile
CMD MIX_ENV=prod mix run --no-halt
