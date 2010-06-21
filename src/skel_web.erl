%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Web server for skel.

-module(skel_web).
-author('author <author@example.com>').

-export([start/1, stop/0, loop/3]).
-export([http_progress/0]).

-define(Content_Type_Text, "text/plain; charset=utf-8").
-define(SERVER_NAME, [{"Server","retranslator 0.1"}]).
%% External API

start(Options) ->
    inets:start(),
    Progress= spawn(?MODULE, http_progress,[]),
    Urls = utils:get_conf("destinations",[]),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req,Urls,Progress)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options]).

stop() ->    
    Res=mochiweb_http:stop(?MODULE),
    http_progress_process ! stop,
    inets:stop(),
    Res.

loop(Req, Urls, Progress) ->
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
                            [ http:request(get, {Url ++ Path ++ "?" ++ QueryString, []}, [],
                                        [{sync, false}, {receiver, Progress }]) || Url <- Urls];
                        'POST' ->
                            Params = Req:parse_post(),
                            QueryString =build_queryString(Params),
                            [http:request(post, {Url ++ Path, [],"application/x-www-form-urlencoded",QueryString}, [],
                                [{sync, false}, {receiver, Progress}, {body_format, string}]) || Url <- Urls]
                    end,
                    Req:ok({?Content_Type_Text,
                                    ?SERVER_NAME, "ok" })

            end;
        _ ->
            Req:respond({501, [], []})
    end.

http_progress() ->
    receive
        {http, Data} ->
            error_logger:info_msg("http progress: ~p",[Data]),
            http_progress();
        stop ->
            stop
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
