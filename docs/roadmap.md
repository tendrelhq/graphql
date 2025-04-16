# Roadmap

## Runtime reason codes

See [./runtime.md](/docs/runtime.md).

- [ ] API to create a reason code (i.e. custag)
  - Name + "Category" (which is really template)
  - Under the hood creates a result-level constraint
- [ ] API to list reason codes
- [ ] API to list allowed values/completions for a field

## Runtime batch tracking

See [./runtime.md](/docs/runtime.md).

- [ ] API to create a batch (template)
- [ ] API to list batches (templates and instances)
- [ ] API to "re-parent" a chain, i.e. set its originator
- [ ] API for cross-location instantiation

How does cross-location instantiation work? We are missing the concept of
"target location" in worktemplatenexttemplate. Sure would be easier if these
templates were distinct per location... but alas.
