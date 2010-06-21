{application, retr,
 [{description, "retr"},
  {vsn, "0.01"},
  {modules, [
    retr,
    retr_app,
    retr_sup,
    retr_web
  ]},
  {registered, []},
  {mod, {retr_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
