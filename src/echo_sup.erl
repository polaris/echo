-module(echo_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  EchoAcceptor = {echo_acceptor, {echo_acceptor, start_link, []}, permanent, 2000, worker, [echo_acceptor]},
  Children = [EchoAcceptor],
  RestartStrategy = {one_for_one, 0, 1},
  {ok, {RestartStrategy, Children}}.