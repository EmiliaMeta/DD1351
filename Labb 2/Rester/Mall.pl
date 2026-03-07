% Läs in och starta verifiering
verify(File) :-
    see(File),
    read(Prems), read(Goal), read(Proof),
    seen,
    ( valid_proof(Prems, Goal, Proof)
      -> format('yes~n', [])
      ;  format('no~n', [])
    ).

% Kontrollera bevis: sista raden måste vara målet
valid_proof(Prems, Goal, Proof) :-
    last(Proof, [_, Goal, _]),
    valid_lines(Prems, Proof, []).

% Basfall
valid_lines(_, [], _).
valid_lines(Prems, [Line | Rest], Verified) :-
    valid_line(Prems, Line, Verified),
    append(Verified, [Line], NewVerified),
    valid_lines(Prems, Rest, NewVerified).

% === Enskild radkontroll ===

% Premiss
valid_line(Prems, [_, Formula, premise], _) :-
    memberchk(Formula, Prems).

% Copy
valid_line(_, [_, X, copy(N)], Verified) :-
    memberchk([N, X, _], Verified).

% Implication Elimination (→E)
valid_line(_, [_, Q, impel(X, Y)], Verified) :-
    ( memberchk([X, imp(P, Q), _], Verified),
      memberchk([Y, P, _], Verified)
    ;
      memberchk([Y, imp(P, Q), _], Verified),
      memberchk([X, P, _], Verified)
    ).

% Implication Introduction (→I)
valid_line(_, [_, imp(P, Q), impint(X, Y)], Verified) :-
    memberchk([[X, P, assumption] | Box], Verified),
    last(Box, [Y, Q, _]).

% Negation Introduction (¬I)
valid_line(_, [_, neg(X), negint(Xr, Yr)], Verified) :-
    memberchk([[Xr, X, assumption] | Box], Verified),
    last(Box, [Yr, cont, _]).

% Negation Elimination (¬E)
valid_line(_, [_, cont, negel(A, B)], Verified) :-
    memberchk([A, X, _], Verified),
    memberchk([B, neg(X), _], Verified).

% Contradiction Elimination (⊥E)
valid_line(_, [_, _, contel(A)], Verified) :-
    memberchk([A, cont, _], Verified).

% Box – Assumption
valid_line(Prems, [[_, _, assumption] | Lines], Verified) :-
    append(Verified, [[_, _, assumption] | Lines], NewVerified),
    valid_lines(Prems, Lines, NewVerified).

% Fallback: Ogiltig regel
valid_line(_, [_, _, Rule], _) :-
    \+ memberchk(Rule, [premise, copy, impel, impint,
                        negint, negel, contel, assumption]),
    !, fail.
