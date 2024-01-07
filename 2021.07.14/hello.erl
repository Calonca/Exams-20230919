-module(hello).
-compile(export_all).
% Consider a main process which takes two lists: one of function names, and one of lists of parameters (the
% first element of with contains the parameters for the first function, and so forth). For each function, the
% main process must spawn a worker process, passing to it the corresponding argument list.
% If one of the workers fails for some reason, the main process must create another worker running the same function.
% The main process ends when all the workers are done.
% -export([main_process/2]).
% get_first(F) ->
%     {A, _} = F,
%     A.
% get_second(F) ->
%     {_, B} = F,
%     B.

% fun_executor(From,F,Args) ->
%   try F(Args) ->
%     From ! success;
%   except ->
%     From ! {failure,Fun,Args}.

exec_until_done() ->
    receive
        {failure, Fun, Args} ->
            spawn(echo, fun_executor, [self(), Fun, Args]),
            exec_until_done();
        success ->
            ok
    end.

% main_process(FnNames, Params) ->
%     List3 = lists:zip(FnNames, Params),
%     processes = [spawn(echo, fun_executor, [get_first(N), get_second(N)]) || N <- List3],
%     [exec_until_done() || p <- processes],

%     io:format("\nHello, world!").
% 
testprint() ->
    io:format("Hello, world2!~n").

listmlink([], [], Pids) ->
    Pids;

listmlink([F | Fs], [D | Ds], Pids) ->
    Pid = spawn_link(?MODULE, F, D),
    listmlink(Fs, Ds, Pids#{Pid => {F, D}}).

master(Functions, Arguments) ->
    process_flag(trap_exit, true),
    Workers = listmlink(Functions, Arguments, #{}),
    master_loop(Workers, length(Functions)).

master_loop(Workers, Count) ->
    receive
        {'EXIT', _, normal} ->
            if
                Count =:= 1 -> ok;
                true -> master_loop(Workers, Count - 1)
            end;
        {'EXIT', Child, _} ->
            #{Child := {F, D}} = Workers,
            Pid = spawn_link(?MODULE, F, D),
            master_loop(Workers#{Pid => {F, D}}, Count)
    end.
