%% -*- mode: Erlang; fill-column: 75; comment-column: 50; -*- %%
{application, echo,
  [{description, "Erlang TCP echo"},
    {vsn, "0.1.0"},
    {modules, [echo_app, echo_sup]},
  {registered, [echo_sup]},
  {applications, [kernel, stdlib]},
  {mod, {echo_app, []}}
]}.
