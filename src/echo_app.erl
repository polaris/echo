-module(echo_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(DEFAULT_PORT, 1234).

start(_Type, _StartArgs) ->
  Port = get_port(),
  io:format("Starting with port ~p~n", [Port]),
  case echo_sup:start_link(Port) of
    {ok, Pid} ->
      {ok, Pid};
    Other ->
      {error, Other}
  end.

stop(_State) ->
  ok.

get_port() ->
  case application:get_env(echo, port) of
    {ok, Port} -> Port;
    _ -> ?DEFAULT_PORT
  end.