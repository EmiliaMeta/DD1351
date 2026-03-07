verify(InputFilesName) :- see(InputFilesName),
                          read(Prems), read(Goal), read(Proof),
                          seen, (valid_proof(Prems, Goal, Proof)
                           -> format('yes~n', []); format('no~n', [])).

% main
valid_proof(Prems, Goal, Proof) :-
    last(Proof, [_, Goal, _]),              
    valid_lines(Prems, Proof, []).            

% basfall 
valid_lines(_, [], _).
valid_lines(Prems, [Line | Rest], Verified) :-
    valid_line(Prems, Line, Verified),      
    append(Verified, [Line], NewVerified),  
    valid_lines(Prems, Rest, NewVerified).  


% regeldefinitioner
% premiss
valid_line(Prems, [_, Formula, premise], _) :-
    memberchk(Formula, Prems).

% antagande/box
valid_line(Prems, [[_, _, assumption] | Lines], Verified) :-
    append(Verified, [[_, _, assumption] | Lines], NewVerified),
    valid_lines(Prems, Lines, NewVerified). 

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
    memberchk([[X, P, assumption] | Box], Verified),
    last(Box, [Y, Q, _]).

% fallback
valid_line(_, [_, _, Rule], _) :-
    \+ memberchk(Rule, [premise, assumption, copy, impel, impint]),
    !, fail.

% hjälppredikat
memberchk(X,L) :- select(X,L,_), !.
