# Design

## Rules engine

The RE operates in stages:

1. build phase
2. evaluation phase
3. instantiation phase

Each of these stages has its own (public) interface in order to promote granular
test coverage and composability, in addition to developer sanity because... SQL.

Additionally, we provide a high(er) level interface that, internally, invokes
each stage in sequence. This is the canonical "public api" into the RE.

For example;

```sql
select *
from engine.execute($1) -- $1 is a workinstance.id (uuid)
```

> IMPORTANT!
> This interface **assumes** that all modification(s) to $1 and its components
> are visible to the current snapshot.

As previously stated, the above is really just syntactic sugar over the
following sequence of calls:

```sql
with
    -- (1) build phase
    stage1 as (
        select * from engine.build_instantiation_plan($1)
    ),

    -- (2) check phase
    stage2 as (
        select distinct s1.target, s1.target_parent, s1.target_type
        from stage1 s1, engine.evaluate_instantiation_plan(
            target := s1.target,
            target_type := s1.target_type,
            conditions := s1.ops
        ) pc
        where pc.result = true
    ),

    -- (3) execute phase
    stage3 as (
        select pe.*
        from stage2 s2, engine.plan_execute(
            template_id := s2.target,
            location_id := s2.target_parent,
            target_state := s2.target_state,
            target_type := s2.target_type
        ) pe
    )

select s3.instance
from stage3 s3
group by s3.instance;
```

### (1) build phase

The goal of this phase is construct what we call a "decision tree" (DST).

DSTs encode all possible permutations that could result from the current state
of the system. Practically speaking, a DST identifies every template that
_could_ be instantiated. Instantiation does not happen in this phase.

### (2) evaluation phase

The goal of this phase is to identify which permutations are allowed to happen
given the current state of the system. This is where we evaluate conditions and
keep only those for which _some_ condition holds.

### (3) instantiation phase

The goal of this phase is instantiation. For each valid permutation (as
determined by (2)), an instance will be created.

## Instantiation mode, i.e. eager vs lazy

Canonically, the rules engine has always operated in eager instantiation mode.
That is: valid permutations _always_ lead to instantiation. However, this is not
always the case[^1].

Instantiation mode, in the current data model, is derived from
`worktemplatenexttemplatetypeid`. Historically, this column indicates what "Work
Type" a new instance should be given, e.g. Audit, Remediation, Task, On Demand.

In our new world order, the "On Demand" type indicates lazy instantiation while
everything else indicates eager instantiation. Lazy instantiation _never_
happens automatically (by definition). Thus, the execution phase of the engine
will only create instances for which eager instantiation is prescribed.

## Frequency (and scheduling)

Target start time is derived from `workfrequency`. We simply convert the
value/type columns of this table into a standard interval through inversion.
Thus "2 per day" becomes "every 1/2 day" (or "every 12 hours"). "0.5 per day"
becomes "every 2 days". etc.

See `util.compute_rrule_next_occurrence` for the implementation.

## Respawn

Respawn is canonically tied to On Demand vs frequency (i.e. instantiation mode
in the new world order). When a task is On Demand, it is "always available" i.e.
there is always an Open instance. This is where the current data model lets us
down a bit. What we want is an _eager_ instantiation rule that tells us to create
a new, Open instance when the existing instance goes InProgress. But we lose out
on "Work Type"? Perhaps we can say that, in such cases, the new instance gets
the same WT as the previous? This would apply _just_ to respawn rules, i.e.
self referencing rules.

[^1]:
    For example, in Yield we desire lazy instantiation to allow the user to
    explicitly choose which (logical) branch to enter into.
