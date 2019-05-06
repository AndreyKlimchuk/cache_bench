-module(cache_bench).

%% API exports
-export([measure_clients_lifetime/1]).

%%====================================================================
%% API functions
%%====================================================================

-spec measure_clients_lifetime(Clients::[{Id::term(), fun(() -> term())}]) ->
  [{Id::term(), LifetimeMilliSec::non_neg_integer()}].
measure_clients_lifetime(Clients0) ->
  StartTime = os:system_time(millisecond),
  Fun = fun({Id, ClientFun}, Acc) -> Acc#{element(2, spawn_monitor(ClientFun)) => Id} end,
  Clients1 = lists:foldl(Fun, #{}, Clients0),
  fun F(C0, Acc) when map_size(C0) > 0 ->
        receive
          {'DOWN', Ref, _, _, _} ->
            {Id, C1} = maps:take(Ref, C0),
            Lifetime = os:system_time(millisecond) - StartTime,
            F(C1, [{Id, Lifetime} | Acc])
        end;
      F(_, Acc) -> Acc
  end(Clients1, []).
