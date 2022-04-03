-module(weight_keeper_webhook_handler).
-include_lib("kernel/include/logger.hrl").

-behaviour(cowboy_handler).

-export([init/2]).

-define(INSERT_QUERY, <<"
    INSERT INTO weights (user_id, value, inserted_at)
    VALUES($1, $2, CURRENT_TIMESTAMP)
">>).

init(Req, #{token := Token} = Opts) ->
    {ok, Json, _Req} = cowboy_req:read_body(Req),
    Data = jsx:decode(Json, [{labels, attempt_atom}]),
    react(Data, Token),
    {ok, cowboy_req:reply(204, #{}, <<>>, Req), Opts}.

react(#{message := #{chat := #{id := ChatId}, from := #{id := UserId, username := User}, text := Text}}, Token) ->
    ?LOG_DEBUG("Got message [~ts] from User [~s]", [Text, User]),
    case re:run(Text, <<"\\d+[.,]?\\d?">>, [{capture, all, binary}]) of
        {match, [Value]} ->
            pgapp:equery(main_pool, ?INSERT_QUERY, [UserId, convert_number(Value)]),
            reply(ChatId, <<"Ваш вес учтён"/utf8>>, Token);
        nomatch ->
            reply(ChatId, <<"Ничего не понял"/utf8>>, Token)
    end;
react(#{edited_message := #{from := #{username := User}, text := Text}}, _Token) ->
    ?LOG_DEBUG("Got edited message [~ts] from User [~s]", [Text, User]);
react(#{message := #{from := #{username := User}, sticker := #{set_name := Sticker}}}, _Token) ->
    ?LOG_DEBUG("Got [~ts] message from User [~s]", [Sticker, User]);
react(Message, _Token) ->
    ?LOG_DEBUG("Unexpected message ~p", [Message]).

reply(ChatId, Text, Token) ->
    Url = <<"https://api.telegram.org/bot", Token/binary, "/sendMessage">>,
    Payload = jsx:encode(#{chat_id => ChatId, text => Text}),
    case httpc:request(post, {Url, [], "application/json", Payload}, [], [{body_format, binary}]) of
        {ok, {{_, Status, ReasonPhrase}, _RespHeader, _Body}} ->
            ?LOG_DEBUG("Got response from TG: [~p: ~s]", [Status, ReasonPhrase]);
        {error, Reason} ->
            ?LOG_ERROR("Something gone wrong: [~p]", [Reason])
    end.

convert_number(Value) ->
    case string:to_float(Value) of
        {error, no_float} ->
            {Int, _Rest} = string:to_integer(Value),
            float(Int);
        {Float, _Rest} ->
            Float
    end.
