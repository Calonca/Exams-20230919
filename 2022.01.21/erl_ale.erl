-module(erl_ale).
-compile(export_all).
% Exercise 3, Erlang (12 pts)
% Create a distributed hash table with separate chaining. The hash table will consist of an agent for each
% bucket, and a master agent that stores the buckets’ PIDs and acts as a middleware between them and the
% user. Actual key/value pairs are stored into the bucket agents.
% The middleware agent must be implemented by a function called hashtable_spawn that takes as its
% arguments (1) the hash function and (2) the number of buckets. When executed, hashtable_spawn
% spawns the bucket nodes, and starts listening for queries from the user. Such queries can be of two kinds:

% • Insert: {insert, Key, Value} inserts a new element into the hash table, or updates it if an
% element with the same key exists;
% • Lookup: {lookup, Key, RecipientPid} sends to the agent with PID “RecipientPid” a
% message of the form {found, Value}, where Value is the value associated with the given key, if
% any. If no such value exists, it sends the message not_found.
% The following code:

bucket(Map, MiddlePid) ->
    receive
        {insert, Key, Value} ->  bucket(Map#{Key => Value}, MiddlePid);
        {lookup, Key} -> 
            case maps:find(Key, Map) of
                {ok, Value} -> MiddlePid ! {found, self(), Value};
                error ->  MiddlePid ! {not_found, self()}
            end,
            bucket(Map, MiddlePid)
    end.

hashtable_spawn_loop(HashFun, Pids) ->
    receive
        {insert, Key, Value} ->
            Pid = lists:nth(HashFun(Key), Pids),
            Pid ! {insert, Key, Value};
        {lookup, Key, RecipientPid} ->
            Pid = lists:nth(HashFun(Key), Pids),
            Pid ! {lookup, Key},
            receive
                {found, Pid, Value} -> RecipientPid ! {found, Value};
                {not_found, Pid} ->  RecipientPid !  not_found
            end
    end,
    hashtable_spawn_loop(HashFun, Pids).

hashtable_spawn(HashFun, NumBuckets) ->
    Pids = [spawn(?MODULE, bucket, [#{}, self()]) || _ <- lists:seq(0, NumBuckets - 1)],
    hashtable_spawn_loop(HashFun, Pids).

main() ->
    HT = spawn(?MODULE, hashtable_spawn, [fun(Key) -> Key rem 7 end, 7]),
    HT ! {insert, 15, "Apple"},
    HT ! {insert, 8, "Orange"},
    timer:sleep(500),
    HT ! {lookup, 8, self()},
    receive
        {found, A1} -> io:format("~s~n", [A1])
    end,
    HT ! {insert, 8, "Pineapple"},
    timer:sleep(500),
    HT ! {lookup, 9, self()},
    receive
        {found, A2} -> io:format("~s~n", [A2]);
        not_found -> io:format("Not found~n")
    end.

% should print the following:
% Orange
% Pineapple

% c(erl_leo),erl_leo:main().