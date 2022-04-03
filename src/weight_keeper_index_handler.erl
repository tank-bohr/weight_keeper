-module(weight_keeper_index_handler).
-include_lib("kernel/include/logger.hrl").

-behaviour(cowboy_handler).

-export([init/2]).

-define(RESP_HEADERS, #{
    <<"content-type">> => <<"text/plain">>
}).

init(Req, Opts) ->
  {ok, cowboy_req:reply(200, ?RESP_HEADERS, <<"OK">>, Req), Opts}.
