-module(echo_sup).

-behaviour(supervisor).

-export([start_link/1,
         start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).
-define(DEFAULT_PORT, 1234).

start_link(Port) ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, [Port]).

start_link() ->
  start_link(?DEFAULT_PORT).

init([Port]) ->
  EchoServer = {echo_server, {echo_server, start, [Port]}, permanent, 2000, worker, [echo_server]},
  Children = [EchoServer],
  RestartStrategy = {one_for_one, 0, 1},
  {ok, {RestartStrategy, Children}}.