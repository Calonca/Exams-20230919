-module(erl_leo).
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


% spawn_processes(ParentPid, ListOfProc, NumProc) ->
%     Pid = spawn(hash_bucket()),
%     spawn_processes(ParentPid, )
    
hashtable_spawn_loop(HashFun, Pids) ->
    % Pids spawn_processes(self(), []),
    % io:format("Spawn loop pid ~p~n", [self()]),
    receive
        {insert, Key, Value} ->
            Index = HashFun(Key),
            Process = lists:nth(Index, Pids),
            % io:format("Inserting value ~p in key ~p (process ~p)~n", [Value, Key, Process]),
            Process ! {insert, Key, Value},
            hashtable_spawn_loop(HashFun, Pids);
        {lookup, Key, RecipientPid} ->
            
            Index = HashFun(Key),
            Process = lists:nth(Index, Pids),
            % io:format("Looking for value in key ~p (process ~p)~n", [Key, Process]),
            Process ! {lookup, Key},
            receive
                {found, Value} -> 
                    io:format("Found value ~p~n", [Value]),
                    RecipientPid ! {found, Value};
                not_found -> 
                    io:format("value not found~n"),
                    RecipientPid ! not_found
            end,
            hashtable_spawn_loop(HashFun, Pids)
    end.

hashtable_spawn(HashFun, NumBuckets) ->
    % io:format("Spawn pid ~p~n", [self()]),
    Self = self(),
    Pids = [spawn(fun() -> hash_bucket(Self, #{}) end) || _ <- lists:seq(0, NumBuckets - 1)],
    hashtable_spawn_loop(HashFun, Pids).

hash_bucket(ParentPid, BucketMap) ->
    % io:format("Child pid ~p~n", [ParentPid]),
    receive
        {insert, Key, Value} -> hash_bucket(ParentPid, BucketMap#{Key => Value});
        {lookup, Key} ->
            % io:format("Serching for key"),
            case BucketMap of 
                #{Key := Result} -> ParentPid ! {found, Result};
                _ -> ParentPid ! not_found
            end,
            
            % case maps:find(Key, BucketMap) of
            %     {ok, Value} -> ParentPid ! {found, Value};
            %     error ->  ParentPid ! not_found
            % end,
            hash_bucket(ParentPid, BucketMap)
    end.

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


% case maps:find(one, Map) of
%     {ok, Value} -> Value;
%     error -> not_present
% end.