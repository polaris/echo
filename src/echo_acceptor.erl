-module(echo_acceptor).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

-export([start_link/0,
         listen/1,
         stop/0]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(acceptor_state, {listen_port = undefined}).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
  gen_server:cast(?MODULE, stop).

listen(Port) ->
  gen_server:cast(?MODULE, {listen, Port}).

init([]) ->
  {ok, #acceptor_state{}}.

handle_call(_Request, _From, State) ->
  {noreply, State}.

handle_cast({listen, Port}, State) ->
  Options = [binary, {packet, raw}, {active, true}, {reuseaddr, true}],
  case gen_tcp:listen(Port, Options) of
    {ok, Listen} ->
      gen_server:cast(?MODULE, accept),
      {noreply, State#acceptor_state{listen_port=Listen}};
    {error, _} ->
      {stop, error, State}
  end;
handle_cast(accept, #acceptor_state{listen_port=Listen} = State) ->
    case gen_tcp:accept(Listen) of
    {ok, Client} ->
      Pid = spawn(fun() -> echo_server:start(Client) end),
      gen_tcp:controlling_process(Client, Pid),
      gen_server:cast(self(), accept),
      {noreply, State};
    {error, closed} ->
      {stop, normal, State};
    {error, timeout} ->
      io:format("accept failed: timeout~n"),
      {stop, error, State};
    {error, Reason} ->
      io:format("accept failed: ~p~n", [Reason]),
      {stop, error, State}
  end;
handle_cast(stop, #acceptor_state{listen_port=Listen} = State) ->
  gen_tcp:close(Listen),
  {stop, normal, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
