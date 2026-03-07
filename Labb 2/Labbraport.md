# **DD1351 – Lab2 2: Proof verification in prolog**
#### Authors: 

- Emilia Lindqvist
- Adam Viberg
#### Date: HT25 12/11

## **1. Objective**
The goal of this lab is to implement and understand a proof verifier in Prolog for natural deduction.
The program reads: 
1. A list of premises
2. A goal
3. A proof

and determines whether the conclusion (goal) is valid.
The result is printed as `yes` if the proof is valid, and `no` otherwise.

## **2. Algorithm description**
### Overview

**The proof verifier consists of three main predicates:**

| Predicate | Function |
|-----------|-----------|
| `verify/1` | Reads a file containing premises, goal, and proof. It calls `valid_proof/3` and prints `yes` or `no`.|
| `valid_proof/3` | Checks that the last line of the proof matches the goal and verifies all lines. |
| `valid_lines/3` | Iterates through every line (and subproof/box) in the proof, verifying each using valid_line/3. |


Each proof line has the form:
```
[LineNumber, Formula, Rule].
```
Subproofs *(boxes)* are represented as lists within lists:
```
[[[R, P, assumption] | Box] | Rest].
```

### Predicate truth conditions
| Predicate | True when | False when |
|-----------|-----------|----------- |
| `verify(File)` | The proof in the file is valid according to deduction rules. | The goal cannot be derived.|
| `valid_proof(Prems, Goal, Proof)` | The last line of `Proof` equals `Goal` and all lines are valid. | The last line does not match the goal. |
| `valid_lines(Prems, Proof, Verified)` | All lines and boxes in `Proof` are valid. | At least one line violates a rule. |
| `valid_line(Prems, [_, Formula, premise], _)` | The formula is listed among the premises. | Otherwise |
| `valid_line(_, [_, X, copy(N)], Verified)` | A previous line `[N, X, _]` exists. | No such line exists. |
| `valid_line(_, [_, Q, impel(X,Y)], Verified)` | Lines X and Y together yield Q via implication elimination. | Incorrect references. |
| `valid_line(_, [_, imp(P,Q), impint(X,Y)], Verified)` | There exists a box starting with `[X,P,assumption]` that ends with `Q`. | The box is missing or ends incorrectly. |
| `valid_line(_, [_, and(P,Q), andint(X,Y)], Verified)` | Lines X and Y contain P and Q. | Either is missing. |
| `valid_line(_, [_, P, andel1(X)], Verified)`| Line X contains and(P, _). | No matching line found. |
| `valid_line(_, [_, Q, andel2(X)], Verified)` | Line X contains and(_, Q). | No matching line found. |
| `valid_line(_, [_, or(P,_), orint1(X)], Verified)` | Line X contains P. | No matching line found. |
| `valid_line(_, [_, or(_,Q), orint2(X)], Verified)` | Line X contains Q. | No matching line found. |
| `valid_line(_, [_, P, orel(X,Y,U,V,W)], Verified)` | Line X contains `or(A,B)`; subproofs Y–U and V–W both conclude P.| Boxes missing or end with different formulas. |
| `valid_line(_, [_, neg(P), negint(X,Y)], Verified)` | A box starting with `[X,P,assumption]` ends with contradiction `cont`.| Box missing or does not end in contradiction. |
| `valid_line(_, [_, cont, negel(X,Y)], Verified)` | Lines X and Y are P and neg(P) respectively.| No contradiction found. |
| `valid_line(_, [_, _, contel(X)], Verified)` | Line X contains cont, allowing any formula to be inferred. | No `cont` line found. |
| `valid_line(_, [_, neg(neg(P)), negnegint(X)], Verified)` | Line X contains P. | No matching P-line found. |
| `valid_line(_, [_, P, negnegel(X)], Verified)` | Line X contains negneg(P).| No matching line found. |
| `valid_line(_, [_, neg(P), mt(X,Y)], Verified)` | Line X contains imp(P,Q) and line Y contains neg(Q).| Either premise missing. |
| `valid_line(_, [_, P, pbc(X,Y)], Verified)` | A box starting with `[X,neg(P),assumption]` ends with contradiction `cont`.| Box missing or not ending in contradiction. |
| `valid_line(_, [_, or(P,neg(P)), lem], _)` | Represents the Law of Excluded Middle; always valid. | - |


## **3. Handling Boxes** 
Boxes represent **assumptions** and **local subproofs**.
When `valid_lines/3` encounters a box:

1. It verifies the inner proof recursively using:
```
valid_lines([P | Prems], Box, [[R, P, assumption] | Verified])
``` 

The box inherits its assumption `P` **and** all previously verified lines.

2. When the box is verified, it is added to the verified context:
```
append(Verified, [[ [R, P, assumption] | Box ]], NewVerified)
```

3. Rules such as `impint`, `pbc`, and `negint` can then access the box inside `Verified`.

**Common issue:**
Earlier versions didn’t pass the outer Verified list into nested boxes, which prevented subproofs from accessing outer premises.

**Final solution:**
Each recursive call now includes the current Verified context, allowing impint and other rules to work with nested structures.

## **4. The algorithm from top to bottom**
### Example of a valid proof: My_Valid.txt
**Expected output:** `yes`

**Premises:** `[imp(p,q), neg(q)]`

**Goal:** `neg(p)`

**Proof:**
```prolog
[imp(p,q), neg(q)].

neg(p).

[
    [1, imp(p,q), premise],
    [2, neg(q), premise],
    [
        [3, p, assumption],
        [4, q, impel(3,1)],
        [5, cont, negel(4,2)]
    ],
    [6, neg(p), negint(3,5)]
].
```
#### Dry run step by step:
| Step | Predicate | Description | Result |
|----|-----------|-----------|-----------|
|1| `verify(InputFile)` | The program reads the premises `[imp(p,q), neg(q)]` and the goal `neg(p)`. It calls valid_proof(Prems, Goal, Proof).| - |
|2| `valid_proof/3`| Checks whether the **last line** of the proof contains the goal formula. The last line `[6, neg(p), negint(3,5)]` matches `neg(p)`.| Valid |
|3| `valid_lines(Prems, Proof, [])`| Begins line by line verification with an empty `Verified` list. | - |
|4| Line 1: `[1, imp(p,q), Premise]`| `valid_line` checks if `imp(p,q)` is one of the premises. |Valid |
|5| Line 2: `[2, neg(q), premise]`| `valid_line` checks of `neg(q)` is one of the premises. |Valid |
|6| Box `[[3, p, assumption], [4, q, impel(3,1)],[5, cont, negel(4,2)]]`| valid_lines detects a **subproof** (box) and calls itself recursively. The new context includes the assumption `p` and previously verified lines. |- |
|7| Inside the box: `[4, q, impel(3,1)]`| impel(X,Y) checks if lines `[1, imp(p,q), _]` exists in the verified context. Both are found, so `q` is correctly derived. |Valid |
|8| Inside the box: `[5, cont, negel(4,2)]`|`negel(X,Y)` checks if lines `[4, q, _]` and `[2, neg(q), _]` exist in the verified context. Since they do, contradicition `cont` is correctly derived. |Valid |
|9| Box closes, returns to outer proof|The verified box is added to the main `Verified` list. |Box valid |
|10| Line 6: `[6, neg(p), negint(3,5)]`|`negint(X,Y)` searches for a box beginning with `[3, p, assumption]` and ending with `[5, cont, _]`. Found: neg(p) is correctly derived. |Valid |
|Done|All lines verified|`valid_lines`succeeds, `valid_proof` succeeds, and the program prints `yes`. |**Output: yes**|

See: appendix B1

### Example of an invalid proof: My_Invalid.txt
**Expected output:** `no`

**Premises:** `[p, q]`

**Goal:** `imp(u, q)`

**Proof:**
```prolog
[p, q].

imp(u,q).

[
  [1, p, premise],
  [2, q, premise],
  [
    [3, u, assumption],
    [4, and(p, u), andint(3, 1)]
  ],
  [5, imp(u,q), impint(2,4)]
].
```
| Step | Predicate | Description | Result |
|----|-----------|-----------|-----------|
|1|`verify(InputFile)`|The program reads the premises `[p,q]` and goal `imp(u,q)`. It then calls `valid_proof(Prems, Goal, Proof)`.|-|
|2|`valid_proof/3`|Confirms that the last line matches the goal.|Valid|
|3|`valid_lines(Prems, Proof, [])`|Begins line by line verification with an empty `Verified` list. |- |
|4|Line: `[1, p, premise]`|`valid_line` checks if `p` is in the premises list `[p, q]´. |Valid|
|5|Line 2: `[2, q, premise]`|`valid_line` checks if `q` is in the premises list `[p,q]`. |Valid|
|6|Box: `[[3, u, assumption], [4, and(p, u), andint(3, 1)]]`|`valid_lines` detects a **subproof** (box) and verifies it recursively. The new environment includes the assumption `u` and the outer verified lines `[p, q]`. |-|
|7|Inside the box: `[3, u, assumption]`|Recorded as a new assumption, added to the `Verified` list.|Valid|
|8|Inside the box: `[4, and(p,u), andint(3,1)]`|Checks that lines `[3, u, _]` and `[1, p, _]` exist in the verified context. Both are found.|Valid|
|9|Box verification complete|The verified box is added to the main `Verified` list. |Box valid|
|10|Line 5: `[5, imp(u,q), impint(2,4)]`|`impint(X,Y)` looks for a box beginning with `[X, u, assumption]` and ending with a line deriving `q`.|Fails: The box ends with `[4, and(p,u),_]`, not `[_, q, _]`.|
|11|`valid_line` for `impint` fails|Since the box's last line does not match `q`, implication introduction cannot conclude `imp(u,q)`.|Invalid|
|12|`valid_lines` terminates unsuccesfully|Sends failiure up to `valid_proof`, which returns false|**Output: no**|

See appendix B2


## **5. Discussion**
The algorithm correctly accepts valid proofs and rejects invalid ones.
However, during development we encountered several major challenges like difficulties with box handling and the recursive structure of the proof.

**Common pitfalls during development:**

- Incorrect box structure:
Early versions treated each box as a flat list, which caused nested boxes to always return no even when the proof was valid.
- Cross-box referencing:
Lines inside one box were sometimes accessed by another box, violating natural deduction rules.
Only the first (assumption) and last (conclusion) lines of a box should be visible externally.
- Improper appending of boxes:
Using one too many brackets created nested lists that didn’t match what memberchk was searching for.
- Failing to pass Verified into recursive box calls.
- Debugging difficulties:
Lack of debug output made it hard to see the structure of Verified. Adding: `format('DEBUG: ~w~n', [...])`
inside key predicates helped to visualize how data was passed through recursion.

After fixing these, the verifier successfully passed all test cases and custom examples.

## **6. Conclusion**
The Prolog proof verifier meets the lab’s objectives.
It correctly implements natural deduction verification.
All test cases now yield the expected `yes` or `no` results.

## **Appendix**
### Appendix A: Program code:
`Verify.pl`:
```prolog
% Verify.pl
verify(InputFilesName) :-   see(InputFilesName),
                            read(Prems), read(Goal), read(Proof),
                            seen, (valid_proof(Prems, Goal, Proof)
                            -> format('yes~n', [])
                            ;  format('no~n', [])).

% main
valid_proof(Prems, Goal, Proof) :-
    last(Proof, [_, Goal, _]),
    valid_lines(Prems, Proof, []).

% basfall
valid_lines(_, [], _).

% vanliga rader (inte boxar)
valid_lines(Prems, [Line | Rest], Verified) :-
    Line = [_,_,_],                   % exakt tre element = vanlig rad
    valid_line(Prems, Line, Verified),
    append(Verified, [Line], NewVerified),
    valid_lines(Prems, Rest, NewVerified).

% boxar (en lista som börjar med [_,_,assumption])
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
    memberchk([X, and(_, Q), _], Verified).

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

```
### Appendix B: Example proofs
#### B1: Valid proof
```prolog
[imp(p,q), neg(q)].

neg(p).

[
    [1, imp(p,q), premise],
    [2, neg(q), premise],
    [
        [3, p, assumption],
        [4, q, impel(3,1)],
        [5, cont, negel(4,2)]
    ],
    [6, neg(p), negint(3,5)]
].
```

#### B2: Invalid proof
```prolog
[p, q].

imp(u,q).

[
  [1, p, premise],
  [2, q, premise],
  [
    [3, u, assumption],
    [4, and(p, u), andint(3, 1)]
  ],
  [5, imp(u,q), impint(2,4)]
].
```