
% från handouten
% member(X,L) :- select(X,L,_).
% memberchk(X,L) :- select(X,L,_), !.

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).

my_reverse([],[]).
my_reverse([H|T], Y) :-
    my_reverse(T,X), % Skapar en lista X med tail elementen
    append(X,[H],Y). % Lägger på listan X och listan Head på Y. 

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
edge(3,4).
edge(4,1).
edge(4,2).
edge(1,4).

% gör grafen symmetrisk
% X och Y är connected om det finns en kant från X till Y
connected(X, Y) :- edge(X, Y).
% connected(X, Y) :- edge(Y, X).

% startnod läggs in i visited, så vi inte gar i cirklar.
road(X, Y, Road) :- 
    road(X, Y, [X], Road).

% om X och Y är direkt anslutna
% och om Y inte är besökt, vi har hittat en väg.
road(X, Y, Visited, Road) :- 
  connected(X, Y),
  \+ member(Y, Visited),
  my_reverse([Y|Visited], Road).  % vägen byggs baklänges, därför körs reverse

% går till nästa nod
% om inte X leder till Y, letar vi efter en granne Z.
% Vi lägger till Z i listan besökta noder.
% Sedan kallar vi road rekursivt. 
road(X, Y, Visited, Road) :- 
    connected(X, Z),
    \+ member(Z, Visited),
    road(Z, Y, [Z|Visited], Road).