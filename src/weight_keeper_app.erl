-module(weight_keeper_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    weight_keeper_sup:start_link().

stop(_State) ->
    ok.
