-module(echo).

-export([start/1,
         stop/0]).

start(Port) ->
  io:format("Start listening on port ~p~n", [Port]),
  application:start(?MODULE),
  echo_acceptor:listen(Port).

stop() ->
  application:stop(?MODULE).
