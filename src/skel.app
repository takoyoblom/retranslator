{application, skel,
 [{description, "skel"},
  {vsn, "0.01"},
  {modules, [
    skel,
    skel_app,
    skel_sup,
    skel_web
  ]},
  {registered, []},
  {mod, {skel_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.