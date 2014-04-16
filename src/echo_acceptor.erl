-module(echo_acceptor).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

-export([start/1,
         stop/0]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

start(Port) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

stop() ->
  gen_server:cast(?MODULE, stop).

init([Port]) ->
  Options = [binary, {packet, raw}, {active, true}, {reuseaddr, true}],
  case gen_tcp:listen(Port, Options) of
    {ok, Listen} ->
      gen_server:cast(?MODULE, accept),
      {ok, Listen};
    {error, Reason} ->
      {stop, Reason}
  end.

handle_call(_Request, _From, State) ->
  {noreply, State}.

handle_cast(accept, Listen) ->
    case gen_tcp:accept(Listen) of
    {ok, Client} ->
      Pid = spawn(fun() -> echo:start(Client) end),
      gen_tcp:controlling_process(Client, Pid),
      gen_server:cast(self(), accept),
      {noreply, Listen};
    {error, closed} ->
      {stop, normal, Listen};
    {error, timeout} ->
      io:format("accept failed: timeout~n"),
      {stop, error, Listen};
    {error, _} ->
      io:format("accept failed: posix error~n"),
      {stop, error, Listen}
  end;
handle_cast(stop, Listen) ->
  gen_tcp:close(Listen),
  {stop, normal, Listen}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
