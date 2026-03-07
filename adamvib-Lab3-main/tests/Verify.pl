% DD1351 Labb 3: CTL Model Checker

verify(Input) :-
    see(Input),
    read(T),    % transitions
    read(L),    % labeling
    read(S),    % start state
    read(F),    % formula
    seen,
    check(T, L, S, [], F).
    %( check(T, L, S, [], F) ->
    %    format(' yes~n', [])
    %;
    %   format(' no~n', [])
    %).

% Hjälpfunktioner
% successors(T, State, SuccessorList)
successors(T, S, Succ) :-
    member([S, Succ], T).

% labeled(L, State, Atoms)
labeled(L, S, Atoms) :-
    member([S, Atoms], L).

% check_all: alla maste hålla
check_all(_, _, [], _, _).
check_all(T, L, [S|Rest], U, F) :-
    check(T, L, S, U, F),
    check_all(T, L, Rest, U, F).

% check_some: minst en håller
check_some(T, L, [S|_], U, F) :-
    check(T, L, S, U, F).
check_some(T, L, [_|Rest], U, F) :-
    check_some(T, L, Rest, U, F).


% Literaler

% Atom p: sant om p finns i labeling L(S)
check(_, L, S, [], P) :-
    atom(P),
    labeled(L, S, Atoms),
    member(P, Atoms),
    !.

% Negerat atom neg(p)
check(_, L, S, [], neg(P)) :-
    atom(P),
    labeled(L, S, Atoms),
    \+ member(P, Atoms),
    !.


% Booleska operatorer

% F ∧ G
check(T, L, S, U, and(F, G)) :-
    check(T, L, S, U, F),
    check(T, L, S, U, G).

% F ∨ G
check(T, L, S, U, or(F, _)) :-
    check(T, L, S, U, F),
    !.
check(T, L, S, U, or(_, G)) :-
    check(T, L, S, U, G).


% AX: alla efterföljare
check(T, L, S, [], ax(F)) :-
    successors(T, S, Succ),
    check_all(T, L, Succ, [], F).


% EX: någon efterföljare
check(T, L, S, [], ex(F)) :-
    successors(T, S, Succ),
    check_some(T, L, Succ, [], F).


% AG: Always Globally

% AG1: loop leder till success
check(_, _, S, U, ag(_)) :-
    member(S, U),
    !.

% AG2: opackning
check(T, L, S, U, ag(F)) :-
    \+ member(S, U),              % s tillhör ej U
    check(T, L, S, [], F),        % M,s goal F
    successors(T, S, Succ),
    check_all(T, L, Succ, [S|U], ag(F)).

% EG: Exists Globally

% EG1: loop leder till success
check(_, _, S, U, eg(_)) :-
    member(S, U),
    !.

% EG2:
check(T, L, S, U, eg(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F),
    successors(T, S, Succ),
    check_some(T, L, Succ, [S|U], eg(F)).


% AF: Always Finally

% AF1: om F gäller → success
check(T, L, S, U, af(F)) :-
    \+ member(S, U),         % s ∉ U
    check(T, L, S, [], F),   % M,s ⊢ F
    !.

% AF2: annars maste alla vägar till sist uppfylla F
check(T, L, S, U, af(F)) :-
    \+ member(S, U),
    successors(T, S, Succ),
    check_all(T, L, Succ, [S|U], af(F)).


% EF: Exists Finally

% EF1: om F gäller leder till success
check(T, L, S, U, ef(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F),
    !.

% EF2: finns någon väg som når F
check(T, L, S, U, ef(F)) :-
    \+ member(S, U),
    successors(T, S, Succ),
    check_some(T, L, Succ, [S|U], ef(F)).