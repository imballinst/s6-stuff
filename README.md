# codespaces-template

## Checklist

- [x] Test s6 with Go build
- [x] Test Node Prisma initial set up with migrations
- [x] Test Go Postgres initial set up with the same migrations, same database name, etc (check if there is conflict)
- [x] Test running side-by-side

## Notes

### Convert latest Prisma schema to a single SQL for initiation

```sh
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > baseline.sql
```
