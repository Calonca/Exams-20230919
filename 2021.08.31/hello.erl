-module(hello).
-compile(export_all).
% Define a function which takes two list of PIDs [x1, x2, ...], [y1, y2, ...], having the same length, and a
% function f, and creates a different "broker" process for managing the interaction between each pair of
% processes xi and yi.
% At start, the broker process i must send its PID to xi and yi with a message {broker, PID}. Then, the
% broker i will receive messages {from, PID, data, D} from xi or yi, and it must send to the other one an
% analogous message, but with the broker PID and data D modified by applying f to it.
% A special stop message can be sent to a broker i, that will end its activity sending the same message to xi
% and yi.

child_loop_1(D) ->
    receive
        {broker, Broker} ->
            io:format("Child 1 received ~p~n", [Broker]),
            Broker ! {from, self(), data, D},
            child_loop_1(D);
        {from, Broker, data, D} ->
            io:format("Child 1 received ~p~n", [D]),
            if
                D == 10 ->
                    Broker ! {stop};
                true ->
                    Broker ! {from, self(), data, D},
                    child_loop_1(D)
            end
    end.

child_loop_2(D) ->
    receive
        {broker, Broker} ->
            io:format("Child 2 received ~p~n", [Broker]),
            child_loop_1(D)
    end.

func_1(D) ->
    D + 1.

broker_loop(PidA, PidB, Func) ->
    receive
        {from, PidA, data, D} ->
            PidB ! {from, self(), data, Func(D)},
            broker_loop(PidA, PidB, Func);
        {from, PidB, data, D} ->
            PidA ! {from, self(), data, Func(D)},
            broker_loop(PidA, PidB, Func);
        {stop} ->
            ok
    end.
% receive {from, PID, data, D} from one and send it to the other with the broker pid and f D instead of D
% {stop}

broker(PidA, PidB, Func) ->
    PidA ! {broker, self()},
    PidB ! {broker, self()},
    receive
        {from, PidA, data, D} ->
            PidB ! {from, self(), data, Func(D)},
            broker_loop(PidA, PidB, Func);
        {from, PidB, data, D} ->
            PidA ! {from, self(), data, Func(D)},
            broker_loop(PidA, PidB, Func);
        {stop} ->
            ok
    end.

create_brokers([], [], _) ->
    ok;
create_brokers([PidA | PidsA], [PidB | PidsB], Fun) ->
    spawn(hello, broker, [PidA, PidB, Fun]),
    create_brokers(PidsA, PidsB, Fun).

master() ->
    PidA = spawn(hello, child_loop_1, [0]),
    PidB = spawn(hello, child_loop_2, [4]),
    create_brokers([PidA], [PidB], fun func_1/1).