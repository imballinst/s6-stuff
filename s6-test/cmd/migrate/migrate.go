package main

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func main() {
	db, err := sql.Open("postgres", "postgres://admin:admin@localhost:5432/testdb?sslmode=disable")
	if err != nil {
		panic(err)
	}
	defer db.Close()

	_, err = db.Query("SELECT * from schema_migrations")
	shouldForceMigrate := false

	if err != nil {
		// Table does not exist.
		shouldForceMigrate = true
	}

	m, err := migrate.New(
		"file:///workspaces/s6-stuff/s6-test/migrations",
		"postgres://admin:admin@localhost:5432/testdb?sslmode=disable")
	if err != nil {
		panic(err)
	}

	if shouldForceMigrate {
		err = m.Force(0)
	} else {
		err = m.Up()
	}

	if err != nil && err != migrate.ErrNoChange {
		panic(err)
	}

	fmt.Println("Migration successful!")
}
