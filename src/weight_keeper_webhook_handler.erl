-module(weight_keeper_webhook_handler).
-include_lib("kernel/include/logger.hrl").

-export([init/2]).

init(Req, Opts) ->
    {ok, Json, _} = cowboy_req:read_body(Req),
    Data = jsx:decode(Json, [{labels, atom}]),
    react(Data),
    Resp = cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsx:encode(#{}), Req),
    {ok, Resp, Opts}.

react(#{message := #{from := #{username := User}, text := Text}}) ->
    ?LOG_DEBUG("Got message [~ts] from User [~s]", [Text, User]),
    ;
react(#{edited_message := #{from := #{username := User}, text := Text}}) ->
    ?LOG_DEBUG("Got edited message [~ts] from User [~s]", [Text, User]);
react(#{message := #{from := #{username := User}, sticker := #{set_name := Sticker}}}) ->
    ?LOG_DEBUG("Got [~ts] message from User [~s]", [Sticker, User]).
