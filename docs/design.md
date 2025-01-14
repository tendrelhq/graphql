## finishing off Yield

- [x] in progress agg
- [x] instance parent (location)
- [x] configurable chain behavior
- [x] auto assign
- [x] bug: double constraint in demo
- [ ] export task type tags

The main thing we need to rework is that we can only deal in instances to make
the app work like the mocks want it to. The "trackable" screen should really be
showing you the originator, that is the rock. So the "trackables" query for a
Location parent _is returning_ Tasks but these Tasks are understood to be
so-called chain roots.

What this all boils down to is that we need to generically implement
worktemplatenexttemplate. The question is how.

- [x] implement respawn on in-progress
- [x] demo rules should be on status = in-progress

Let's think about the generic implementation. We have basically two modes of
execution, related to instantiation: lazy and eager. The difference between
these two is _intent_. Lazy instantiation allows the user to _choose their own
path_. This is what we do in Yield. Eager instantiation is a _reaction to user
interaction_; it happens "behind the scenes". This is how "audits",
"remediations" and the like work in SWK.

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
> have already been _committed_.

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

This is really two things:

1. Scheduling, e.g. "every weekday at 2pm"
2. Rate limiting, e.g. "twice per week"

The former (1) is in play during stage 3: we know we want to instantiate, we
just don't know _when_ the instance should "start".

The latter (2) is actually stage 2: it is a condition. Instantiation should not
proceed if the "quota" has already been filled. I don't think we support this
right now.

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
