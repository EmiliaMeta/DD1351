# DD1351: Logic for Computer Scientists (Prolog)

Course assignments from **DD1351 Logic for Computer Scientists** at KTH Royal Institute of Technology.

The course covers mathematical logic and its applications in computer science: propositional logic, predicate logic, natural deduction, induction, temporal logic, Hoare logic, and logic programming in Prolog.

---

## Assignments

### Lab 1: Logic Programming in Prolog
**Concepts:** Unification, recursion, backtracking, graph representation, list processing

Four exercises in Prolog exploring core logic programming concepts:

1. **Unification** — Reasoning about variable bindings in Prolog unification steps
2. **Remove Duplicates** — Implementing `remove_duplicates/2` to filter a list while preserving order; reasoning about why it qualifies as a function
3. **Partstring** — Implementing `partstring/3` to find all consecutive sublists of a given list, using backtracking to generate all solutions
4. **Graph Path Finder** — Designing a graph representation in Prolog and implementing a path predicate that finds routes between nodes without cycles (loop-safe via visited tracking)

All predicates were implemented from scratch using only a small set of pre-approved base predicates (`append`, `member`, `select`, etc.) — no `java.util`-style libraries allowed.

---

### Lab 2: Proof Checker in Prolog
**Concepts:** Natural deduction, recursive algorithms, formal verification, box handling

Implemented a **proof checker** in Prolog that verifies whether a natural deduction proof is correct for a given sequent. The program reads a list of premises, a proof goal, and a full proof from a file, then outputs `yes` or `no`.

Key implementation challenges:
- Verifying each proof line against the correct inference rule (∧i, ∧e, →i, →e, ¬i, ¬e, ¬¬e, ⊥e, copy, lem, pbc, mt, ∨i, ∨e)
- **Box handling** — assumptions open a box; formulas inside a closed box cannot be referenced from outside
- Passing the complete test suite of valid and invalid proofs

The checker was also explored as a potential proof *generator* by leaving the proof argument as an unbound Prolog variable.

---

### Lab 3: CTL Model Checker in Prolog *(group work with Adam Viberg)*
**Concepts:** Computational Tree Logic (CTL), temporal logic, transition systems, loop detection, recursive model checking

Implemented a **model checker** for CTL (Computational Tree Logic) in Prolog. Given a transition system, a labeling function, a start state, and a CTL formula, the program outputs `yes` if the formula holds and `no` otherwise.

**My contributions:** Algorithm design, implementation of the `check/5` predicate and loop detection logic, writing the lab report.

Key implementation aspects:
- Recursive `check/5` predicate with one clause per CTL operator (atom, neg, and, or, AX, EX, AG, EG, AF, EF)
- **U-list for loop detection** — visited states are tracked to ensure termination; AG/EG loops succeed (property holds on all infinite extensions), AF/EF loops fail (target may never be reached)
- `check_all/5` and `check_some/5` helpers for universal vs. existential path quantification

**Example model:** A platform game (Super Mario-style) with states `idle`, `run_left`, `run_right`, `jump`, `fall`, `die` — used to verify CTL properties like *"from any state, it is always possible to eventually reach a safe state"* (which fails due to the absorbing `die` state).

Passed the complete provided test suite.

---

##: Language & Tools

- Prolog (SWI-Prolog / GNU Prolog)

---

## Author

**Emilia Lindqvist** — KTH Information Technology  
[GitHub Profile](https://github.com/EmiliaMeta)
