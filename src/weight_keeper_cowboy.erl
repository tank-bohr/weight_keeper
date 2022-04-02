-module(weight_keeper_cowboy).

-export([child_spec/0]).

child_spec() ->
    #{
        id => ?MODULE,
        start => {cowboy, start_clear, args()}
    }.

args() ->
    [name(), transport_opts(), protocol_opts()].

name() -> http.

transport_opts() -> [{port, port()}].

port() -> 8080.

protocol_opts() ->
    #{env => #{dispatch => dispatch()}}.

dispatch() ->
    Token = fetch_telegram_token(),
    cowboy_router:compile([
        {'_', [
            {"/webhook", weight_keeper_webhook_handler, #{token => Token}}
        ]}
    ]).

fetch_telegram_token() ->
    {ok, Token} = application:get_env(weight_keeper, telegram_token),
    maybe_to_binary(Token).

maybe_to_binary(Token) when is_list(Token) -> list_to_binary(Token);
maybe_to_binary(Token) when is_binary(Token) -> Token.
