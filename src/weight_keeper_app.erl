-module(weight_keeper_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Token = fetch_telegram_token(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/webhook", weight_keeper_webhook_handler, #{token => Token}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    weight_keeper_sup:start_link().

stop(_State) ->
    ok.

fetch_telegram_token() ->
    {ok, Token} = application:get_env(weight_keeper, telegram_token),
    maybe_to_binary(Token).

maybe_to_binary(Token) when is_list(Token) -> list_to_binary(Token);
maybe_to_binary(Token) when is_binary(Token) -> Token.
