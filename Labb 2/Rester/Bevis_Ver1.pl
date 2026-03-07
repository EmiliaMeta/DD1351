verify1(InputFilesName) :- see(InputFilesName),
                          read(Prems), read(Goal), read(Proof),
                          seen, (valid_proof(Prems, Goal, Proof, Proof)
                           -> format('yes~n', []); format('no~n', [])).

verify1_box(Prems, Goal, Proof) :-
    valid_proof(Prems, Goal, Proof, Proof).

valid_rule(T) :-
    functor(T, Name, _),
    memberchk(Name, [
        premise, assumption, copy,
        impel, impint,
        andint, andel1, andel2,
        orint1, orint2, orel,
        negint, negel, negnegint, negnegel,
        mt, pbc, contel, lem
    ]).

% Basfall
valid_proof(_, _, [], _) :- !.
valid_proof(_, Goal, [[_, V, T]|Rest], _) :-
    Rest == [],
    V = Goal,
    valid_rule(T),
    T \= assumption,
    !.

% Vanliga rader
valid_proof(Prems, Goal, [[_, V, T]|Rest], Proof) :- 
    valid_proof(Prems, Goal, V, T, Rest, Proof).

% Box
valid_proof(Prems, Goal, [Box|Rest], Proof) :-
    is_list(Box),
    Box = [[_, P, assumption]|_],
    last(Box, [_, SubGoal, _]),
    verify1_box([P|Prems], SubGoal, Box),
    !,
    valid_proof(Prems, Goal, Rest, Proof).


% Regeldefinitioner
% Premiss
valid_proof(Prems, Goal, V, premise, Rest, Proof) :-
    memberchk(V, Prems), valid_proof(Prems, Goal, Rest, Proof).

% Antagande 
valid_proof(_, _, _, assumption, _, _) :- fail.

% Impel
valid_proof(Prems, Goal, Q, impel(X,Y), Rest, Proof) :-
    nth1(X, Proof, [_, imp(P,Q), _]),                 
    nth1(Y, Proof, [_, P, _]),                        
    valid_proof(Prems, Goal, Rest, Proof).

% Impint
valid_proof(Prems, Goal, imp(P,Q), impint(X,Y), Rest, Proof) :-
    nth1(X, Proof, [_, P, assumption]),   
    nth1(Y, Proof, [_, Q, _]),              
    valid_proof(Prems, Goal, Rest, Proof).

% Copy
valid_proof(Prems, Goal, V, copy(X), Rest, Proof) :-
    nth1(X, Proof, [_, V, _]),
    valid_proof(Prems, Goal, Rest, Proof).


% Hjälppredikat
memberchk(X,L) :- select(X,L,_), !.

% get_line(LineNum, [Line|_], Line) :-
%   Line = [LineNum, _, _].
% get_line(LineNum, [Sub|_], Line) :-
%   is_list(Sub),
%   get_line(LineNum, Sub, Line).
% get_line(LineNum, [_|Rest], Line) :-
%   get_line(LineNum, Rest, Line).