-module(echo).

-export([start/1]).

start(Client) ->
  echo_loop(Client).

echo_loop(Client) ->
  receive
    {tcp, Client, Data} ->
      gen_tcp:send(Client, Data),
      io:format("Received ~p from ~p~n", [Data, Client]),
      inet:setopts(Client, [{active, once}]),
      echo_loop(Client);
    {tcp_closed, _} ->
      ok;
    _ ->
      error
  end.
