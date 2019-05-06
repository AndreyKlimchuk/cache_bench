-module(cache_bench_ecache).

%% API
-export([bench_1/1]).

bench_1(ClientsNum) ->
  Name = ?FUNCTION_NAME,
  init_cache(Name),
  Client = fun() -> [ecache:get(Name, rand:uniform(5000)) || _ <- lists:seq(1, 50000)] end,
  Clients = [{N, Client} || N <- lists:seq(1, ClientsNum)],
  Res = cache_bench:measure_clients_lifetime(Clients),
  ecache:empty(Name),
  Res.


init_cache(Name) ->
  application:ensure_started(ecache),
  ecache_server:start_link(Name, rand, uniform, unlimited, unlimited).