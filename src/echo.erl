-module(echo).

-export([start/1]).

start(Client) ->
  echo_loop(Client).

echo_loop(Client) ->
  receive
    {tcp, Client, Data} ->
      gen_tcp:send(Client, Data),
      inet:setopts(Client, [{active, once}]),
      echo_loop(Client);
    {tcp_closed, _} ->
      ok;
    _ ->
      error
  end.
