%%%-------------------------------------------------------------------
%% @doc weight_keeper public API
%% @end
%%%-------------------------------------------------------------------

-module(weight_keeper_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/webhook", weight_keeper_webhook_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    weight_keeper_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
