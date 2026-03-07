verify(InputFilesName) :-   see(InputFilesName),
                            read(Prems), read(Goal), read(Proof),
                            seen, valid_proof(Prems, Goal, Proof), !.
                           % -> format('yes~n', [])
                           % ;  format('no~n', []).

% main
valid_proof(Prems, Goal, Proof) :-
    last(Proof, [_, Goal, _]),
    valid_lines(Prems, Proof, []).

% basfall
valid_lines(_, [], _).

% vanliga rader (inte boxar)
valid_lines(Prems, [Line | Rest], Verified) :-
    Line = [_,_,_],                   
    valid_line(Prems, Line, Verified),
    append(Verified, [Line], NewVerified),
    valid_lines(Prems, Rest, NewVerified).

% boxar 
valid_lines(Prems, [[[R, P, assumption] | Box] | Rest], Verified) :-
    valid_lines([P | Prems], Box, [[R, P, assumption] | Verified]),
    append(Verified, [[ [R, P, assumption] | Box ]], NewVerified),
    valid_lines(Prems, Rest, NewVerified).

% regeldefinitioner
% premise
valid_line(Prems, [_, Formula, premise], _) :-
    memberchk(Formula, Prems).

% copy
valid_line(_, [_, X, copy(N)], Verified) :-
    memberchk([N, X, _], Verified).

% impel
valid_line(_, [_, Q, impel(X, Y)], Verified) :-
    ( memberchk([X, imp(P, Q), _], Verified),
      memberchk([Y, P, _], Verified)
    ;
      memberchk([Y, imp(P, Q), _], Verified),
      memberchk([X, P, _], Verified)
    ).

% impint
valid_line(_, [_, imp(P, Q), impint(X, Y)], Verified) :-
    (
        member([[X, P, assumption] | Box], Verified),
        (   Box = []
        ->  P = Q, X = Y
        ;   last(Box, [Y, Q, _])
        )
    ;
        member(Box, Verified),
        Box = [[X, P, assumption] | Inner],
        (   Inner = []
        ->  P = Q, X = Y
        ;   last(Inner, [Y, Q, _])
        )
    ).

% andint
valid_line(_, [_, and(P, Q), andint(X, Y)], Verified) :-
    memberchk([X, P, _], Verified),
    memberchk([Y, Q, _], Verified).

% andel1
valid_line(_, [_, Q, andel1(X)], Verified) :-
    memberchk([X, and(Q, _), _], Verified).

% andel2
valid_line(_, [_, Q, andel2(X)], Verified) :-
    memberchk([X, and(_, Q), _5], Verified).

% orint1
valid_line(_, [_, or(P, _), orint1(X)], Verified) :-
    memberchk([X, P, _], Verified).

% orint2
valid_line(_, [_, or(_, Q), orint2(X)], Verified) :-
    memberchk([X, Q, _], Verified).

% orel
valid_line(_, [_, P, orel(X, Y, U, V, W)], Verified) :-
    memberchk([X, or(A, B), _], Verified),
    memberchk([[Y, A, assumption] | Box1], Verified),
    last(Box1, [U, P, _]),
    memberchk([[V, B, assumption] | Box2], Verified),
    last(Box2, [W, P, _]).

% negint
valid_line(_, [_, neg(P), negint(X, Y)], Verified) :-
    memberchk([[X, P, assumption] | Box], Verified),
    last(Box, [Y, cont, _]).

% negel
valid_line(_, [_, cont, negel(X, Y)], Verified) :-
    memberchk([X, P, _], Verified),
    memberchk([Y, neg(P), _], Verified).

% contel
valid_line(_, [_, _, contel(X)], Verified) :-
    memberchk([X, cont, _], Verified).

% negnegint
valid_line(_, [_, neg(neg(P)), negnegint(X)], Verified) :-
    memberchk([X, P, _], Verified).

% negnegel
valid_line(_, [_, P, negnegel(X)], Verified) :-
    memberchk([X, neg(neg(P)), _], Verified).

% mt
valid_line(_, [_, neg(P), mt(X, Y)], Verified) :-
    memberchk([X, imp(P, Q), _], Verified),
    memberchk([Y, neg(Q), _], Verified).

% pbc
valid_line(_, [_, P, pbc(X, Y)], Verified) :-
    memberchk([[X, neg(P), assumption] | Box], Verified),
    last(Box, [Y, cont, _]).

% lem
valid_line(_, [_, or(P, neg(P)), lem], _).

% fallback
valid_line(_, [_, _, Rule], _) :-
    \+ memberchk(Rule, [premise, copy, impel, impint,
                        andint, andel1, andel2, orint1, orint2, orel,
                        negint, negel, contel, negnegint, negnegel,
                        mt, pbc, lem]),
    !, fail.

% helper
memberchk(X, L) :- select(X, L, _), !.
