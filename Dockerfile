FROM erlang:24.3.3-alpine AS bulid_stage

RUN mkdir -p /buildroot
WORKDIR /buildroot
COPY . .
RUN rebar3 release

############################################################

FROM alpine

RUN apk update && \
    apk add openssl ncurses-libs libstdc++

EXPOSE 8443

COPY --from=bulid_stage /buildroot/_build/default/rel/app /srv/app
WORKDIR /srv/app
CMD ["./bin/app", "foreground"]
