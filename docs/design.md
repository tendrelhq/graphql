## finishing off Yield

- [ ] in progress agg
- [ ] instance parent (location)
- [ ] configurable chain behavior
- [ ] auto assign
- [ ] bug: double constraint in demo
- [ ] export task type tags

The main thing we need to rework is that we can only deal in instances to make
the app work like the mocks want it to. The "trackable" screen should really be
showing you the originator, that is the rock. So the "trackables" query for a
Location parent _is returning_ Tasks but these Tasks are understood to be
so-called chain roots.

What this all boils down to is that we need to generically implement
worktemplatenexttemplate. The question is how.

# Design

## Generic worktemplatenexttemplate engine

Wtnt has four pieces:

1. previous template
2. next template
3. field (+optional constraint)
4. status

This is what we've already done for fsm, except it just needs to be slightly
more generic. We need to implement the field level rules, but I think those can
come second. First is the generic status change. This needs to look at the
current state of the task and if it matches the foreign key, trigger
instantiation of the foreign key (task template).

The most complicated bit is (a) determining the location at which to
instantiate, and (b) de-duplicating existing instances (impl: upsert).

I think for (a) we can just "carry over" the location same as we do assignment.
The implication is that we won't support cross location instantiation, but I
think this is acceptable considering the legacy engine does not support this
either.

(b) is tricky. Unfortunately, I can't think of a unique constraint that we could
enforce for this such that we can make use of a traditional upsert. I suppose we
could write one via a FOR EACH STATEMENT trigger but that would be highly
intrusive to the point that we'd need to gate it by default.

We are left with no choice but to do it the hard way.
First we must check for a matching instance. If we find one then we are done;
the "rule" is already satisfied.[^1]

```sql
select 1
from public.workinstance as i
inner join public.location on location.locationuuid = $2
inner join public.workresult as field_t
    on i.workinstanceworktemplateid = field_t.workresultworktemplateid
    and field_t.workresulttypeid = ??? -- Entity
    and field_t.workresultentitytypeid = ??? -- Location
    and field_t.workresultisprimary = true
inner join public.workresultinstance as field
    on field_t.workresultid = field.workresultinstanceworkresultid
    and i.workinstanceid = field.workinstanceid
    and field.workresultinstancevalue = location.locationid::text
where
    i.workinstanceworktemplateid in (
        select worktemplateid
        from public.worktemplate
        where id = $1
    )
    and i.workinstancestatusid in (
        select systagid
        from public.systag
        where systagparentid = ??? and systagtype = $3
    )
```

Actually, I suppose in reality we don't really need to check for Open
duplicates. This is because this specific use case is not creating Open
instances, but actually jumping straight to InProgress! The question is then:
what is the implication of multiple InProgress instances? How could we get into
such a state? It is entirely ambiguous[^1]. Perhaps we should just make this
configurable. I don't think we have any way to encode this sort of decision in
our existing data model.

Generically, I suppose there are many ways to get into this situation. For
example, it is entirely reasonable that a single task be triggerable from
separate and distinct other tasks? The ol "A or B can trigger C". Naturally,
this is just a (unique) constraint! I _think_ the default right now is that it
is an error, i.e. unique. Maybe we make it configurable: (a) error, (b) no-op,
or (c) ignore. We can make it yet further configurable by allowing you to
specify _where_ the constraint applies, i.e. the constraint scope: chain
(meaning a duplicate with the same originator id) or parent (meaning a duplicate
at the same location). Maybe we hold off on that for now because that really
just wants to be a tree problem, i.e. tell me where to start in the tree when
checking the unique constraint.

IMPORTANT: for the "duplicate" to show up in our query, it must have the same
originator. Therefore the unique constraint can only apply at the chain level.

If we do _not_ find a matching instance we must create one. This is essentially
copyFrom but carrying over the primary location.

Rewinding all the way back, the `advance` method must also be configurable such
that the app can control what happens to the active task. The mocks, for
example, imply that transitioning closes the previously active task such that
there is only ever a single InProgress task. This seems like a pretty bad design
decision IMO since it makes really simple things quite complicated, e.g. how do
you calculate "total time"? No matter, we can leave it up to them to figure it
out (use type tags). Regardless we will make it configurable. This just means
that task_fsm's advance method takes an extra parameter to control this behavior.

So, to summarize:

- [x] demo procedures need to create initial instances
      (ideally via some generic instantiate procedure)
- [x] Location's `tracking()` needs to return chains, not templates
      (and just rely on the rules engine to provide on-demand opens)
      (this is actually _really_ annoying in conjunction with "flat chaining"[^2])
- [ ] task_fsm's advance takes an extra parameter to affect the active task when
      transitioning
      (which allows for "close and start" behavior)
- [ ] transitioning needs to first check whether there is an existing instance
      _in the same chain_ matching the given status
      (doing it this way we can probably skip the location check for now)

The following should cover essentially all of our remaining TODOs for Yield.

Yay!

### design breakdown

It starts with a StateMachine<Task>, representing the wtnt rules. We call this
the "fsm". The fsm is a data structure that holds an "active" task as well as
any number of "transitions". The user is free to operate on both the active
and/or transitions. Operating on the active task is essentially the same thing
as "doing a checklist" or "doing a task (in swk)" - it is the entrypoint into
the task-specific state machine (i.e. a StateMachine<TaskStatus>) that abstracts
the "rules engine". Operating on a transition is essentially just an
instantiation operation. In particular, this is the _same operation_ that the
"rules engine" might choose in the active case.

# Appendix

Pass id to trackable screen. This id is the originator, the root of the chain.

Render FSM. There will always be an active task in the FSM since we are dealing
with chains. Therefore initially the active task will always be the originator,
in an Open state. There will be no initial transitions.

The application is free to create any number of InProgress rules which will
manifest as transitions. The transition api takes two parameters: the chain and
the rule. It also takes a third optional parameter to control
instantiation/chain behavior.

[^1]: There are many ambiguities to deal with here.

[^2]:
    "flat chaining" describes the behavior inherent in the mocks for the
    Runtime app where each transition marks the end of the previous task. The
    alternative is "deep chaining" where the previous task is unaffected by the
    transition, creating a tree-like hierarchy of tasks. Flat chaining is
    annoying because we have to look for "active chains" rather than just
    "active roots", which means we have to materialize the entire chain rather
    than just look at a single node.
