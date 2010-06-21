%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(retr).
-author('author <takoy@oblom.com>').
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.
        
%% @spec start() -> ok
%% @doc Start the skel server.
start() ->
    ensure_started(crypto),
    application:start(retr).

%% @spec stop() -> ok
%% @doc Stop the skel server.
stop() ->
    Res = application:stop(retr),
    application:stop(crypto),
    Res.
