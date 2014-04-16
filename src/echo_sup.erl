-module(echo_sup).

-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Port) ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, [Port]).

init([Port]) ->
  EchoAcceptor = {echo_acceptor, {echo_acceptor, start, [Port]}, permanent, 2000, worker, [echo_acceptor]},
  Children = [EchoAcceptor],
  RestartStrategy = {one_for_one, 0, 1},
  {ok, {RestartStrategy, Children}}.