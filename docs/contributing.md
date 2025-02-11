# Stuff you'll probably want to know as a contributor

## sql

I am using [sqitch] at the moment. It's pretty nice.
There are two target configured for use with sqitch:

1. the "dev" target, which deploys to postgres://localhost:5432/dev
2. the "ci" target, which deploys to
   postgres://postgres:postgres@localhost:5432/tendrel

Note that the latter target ("ci") is used in [github workflows](../.github/workflows/e2e.yaml).

### local development

- `sqitch deploy` is as it says
- `sqitch rebase -y` when you are making sql changes
- `sqitch revert -y` removes everything

### deploy to production 🚀

```
sqitch deploy --target db:pg://$PGUSER:$PGPASS@$PGHOST:$PGPORT/$PGDATABASE
```

[sqitch]: https://sqitch.org/
