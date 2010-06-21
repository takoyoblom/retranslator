%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Web server for skel.

-module(retr_web).
-author('author <takoy@oblom.com>').

-export([start/1, stop/0, loop/2]).
-export ([http_loop/0]).

-define(Content_Type_Text, "text/plain; charset=utf-8").
-define(SERVER_NAME, [{"Server","retranslator 0.1"}]).
%% External API

start(Options) ->
    inets:start(),
    register(processor, spawn(?MODULE, http_loop,[])),
    Urls = utils:get_conf("destinations",[]),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req,Urls)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options]).

stop() ->    
    Res=mochiweb_http:stop(?MODULE),
    processor ! stop,
    inets:stop(),
    Res.

loop(Req, Urls) ->
    Path = Req:get(path),
    case Req:get(method) of
        Method when Method =:= 'GET'; Method =:= 'POST' ->
            case Path of
                _ ->
                    % forward request to List servers
                    case Method of
                        'GET'  -> 
                            Query = Req:parse_qs(),
                            QueryString =build_queryString(Query),                            
                            [ processor ! {command, 'get', Url ++ Path ++ "?" ++ QueryString} || Url <- Urls];
                        'POST' ->
                            Params = Req:parse_post(),
                            QueryString =build_queryString(Params),
                            [ processor ! {command, 'post', Url ++ Path, QueryString} || Url <- Urls]
                    end,
                    Req:ok({?Content_Type_Text,
                                    ?SERVER_NAME, "ok" })

            end;
        _ ->
            Req:respond({501, [], []})
    end.

http_loop()->
    receive
        {http, Data} ->
            error_logger:info_msg("http progress: ~p",[Data]),
            http_loop();
        {command, 'get', URL} ->
            http:request(get, {URL, []}, [],  [{sync, false}]),
            http_loop();
        {command, 'post', URL, Params} ->
            http:request(post, {URL, [],"application/x-www-form-urlencoded",Params}, [],
                                [{sync, false}, {body_format, string}]),
            http_loop();
        stop ->
            stop;
        DATA ->
            error_logger:error_msg("Unrecognzed command: ~p",[DATA]),
            http_loop()
    end.

%% Internal API

build_queryString(Query)->
    build_queryString("", Query).
build_queryString(Res, [])->
    Res;
build_queryString(Res, [{Key, Val}| T])->
    build_queryString(Res ++ "&" ++ safe_to_list(Key) ++"=" ++ Val , T).

safe_to_list(V) when is_list(V) ->
    V;
safe_to_list(V) when is_atom(V) ->
    atom_to_list(V).
