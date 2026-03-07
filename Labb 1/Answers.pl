% Uppgift 2
% från handouten
% member(X,L) :- select(X,L,_).
% memberchk(X,L) :- select(X,L,_), !.

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).

my_reverse([],[]).
my_reverse([H|T], Y) :-
    my_reverse(T,X), 
    append(X,[H],Y). 

% Uppgift 2
remove_duplicates(L, X) :-
    my_reverse(L, E),
    temp(E, Y),
    my_reverse(Y, X).

temp([], []).
temp([H|T], X) :-
    member(H, T),
    temp(T, X).
temp([H|T], [H|R]) :-
    \+ member(H, T),
    temp(T, R).

% Uppgift 3

% Räknar längd (från handouten)
my_length([], 0).
my_length([_|T], N) :-
    my_length(T, N1),
    N is N1 + 1.

% Alla prefix, inkl. tomma
prefix(_, []).
prefix([H|T], [H|R]) :-
    prefix(T, R).

% Alla konsekutiva delsträngar, L>0
partstring(Lst, Sub, L) :-
    prefix(Lst, Sub),
    my_length(Sub, L),
    L > 0.

% flyttar listan framåt genom att kasta första elementet
partstring([_|T], Sub, L) :-
    partstring(T, Sub, L).


% uppgift 4

% fakta
% edge(1, 2).
% edge(1, 3).
% edge(2, 4).
% edge(4, 5).
% edge(1, 61).
% edge(61, 5).
edge(1,2).
edge(2,3).
edge(2,4).
edge(3,5).
edge(4,5).
edge(5,6).

% gör grafen symmetrisk
connected(X, Y) :- edge(X, Y).
% connected(X, Y) :- edge(Y, X).

road(X, Y, Road) :- 
    road(X, Y, [X], Road).

road(X, Y, Visited, Road) :- 
  connected(X, Y),
  \+ member(Y, Visited),
  my_reverse([Y|Visited], Road). 

% går till nästa nod
road(X, Y, Visited, Road) :- 
    connected(X, Z),
    \+ member(Z, Visited),
    road(Z, Y, [Z|Visited], Road).