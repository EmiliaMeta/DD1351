# Svar

## Uppgift 1
?- T=f(a,Y,Z), T=f(X,X,b).

Svar:
T = f(a, a, b),
Y = X, X = a,
Z = b.

Vilka bindngar skapas och varför?

f(a, Y, Z) definerar att index 0 ska vara atomen a, men variablerna Y och Z är inte definerade. 
f(X,X,b) definerar att index 2 är atomen b, samt att index 0 och 1 har samma värde. 
Detta leder till att 
f(index0, index1, index2)=f(index0, index0, index2)
där index0 = a, index2 = b.
så:
T = f(a,a,b)


## Uppgift 2
```prolog
remove_duplicates([],[]).           %Grundfall
remove_duplicates([H|T], X) :-      %Kolla om Head finns i Tail
  member(H, T),                     %H finns i resten av listan
  remove_duplicates(T, X).          %Hoppa över H
remove_duplicates([H|T], [H|R]) :-
  \+ member(H, T),                  %H finns inte i resten av listan
  remove_duplicates(T, R).          %Behåll H
```
### Förklara varför man kan kalla detta predikat för en funktion!
Ett predikat i Prolog beskriver en relation mellan indata och utdata. En funktion är ett speciellt fall av en relation där varje indata har exakt ett utdata. För remove_duplicates/2 gäller; givet en lista L finns det en entydig lista R som är resultatet utan dubletter. Predikatet representerar alltså en funktion av lista till lista, predikatet beter sig matematiskt som en funktion. 

## Uppgift 3
```prolog
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
partstring([_|T], Sub, L) :-
    partstring(T, Sub, L).
```

## Uppgift 4
```prolog
edge(1, 2).
edge(1, 3).
edge(2, 4).
edge(4, 5).
edge(1, 61).
edge(61, 5).

connected(X, Y) :- edge(X, Y).
connected(X, Y) :- edge(Y, X).

% startnod
road(X, Y, Road) :- 
    road(X, Y, [X], Road).

% om X och Y är direkt anslutna
road(X, Y, Visited, Road) :- 
  connected(X, Y),
  \+ member(Y, Visited),
  reverse([Y|Visited], Road).

% går till nästa nod
road(X, Y, Visited, Road) :- 
    connected(X, Z),
    \+ member(Z, Visited),
    road(Z, Y, [Z|Visited], Road).
```   