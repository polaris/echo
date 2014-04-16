-module(echo_server).

-export([start/1]).

start(Client) ->
  loop(Client).

loop(Client) ->
  receive
    {tcp, Client, Data} ->
      gen_tcp:send(Client, Data),
      inet:setopts(Client, [{active, once}]),
      loop(Client);
    {tcp_closed, _} ->
      ok;
    _ ->
      error
  end.
