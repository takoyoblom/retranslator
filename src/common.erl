-module(utils).
-author('author <takoy@oblom.com>').

-export([get_conf/2]).

get_conf(Key, Default) ->
    case application:get_env(safe_key(Key)) of
        {ok, Data} -> Data;
        undefined -> Default
    end.


safe_key(Key) when is_atom(Key) ->
    Key;
safe_key(Key) when is_list(Key) ->
    list_to_atom(Key).