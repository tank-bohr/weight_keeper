-module(weight_keeper_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ok = logger:set_primary_config(filters, [
        {suppress_progress, {fun logger_filters:progress/2, stop}}
    ]),
    weight_keeper_sup:start_link().

stop(_State) ->
    ok.
