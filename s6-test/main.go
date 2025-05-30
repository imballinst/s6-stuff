package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	var srv *http.Server
	errorCode := -1

	port, ok := os.LookupEnv("SERVER_PORT")
	if !ok {
		port = "8080"
	}

	router := gin.Default()
	router.GET("/albums", func(c *gin.Context) {
		c.IndentedJSON(http.StatusOK, []map[string]any{})
	})
	router.GET("/panic", func(c *gin.Context) {
		fmt.Println(srv)

		errorCode = '1'
		srv.Shutdown(context.TODO())
	})

	srv = &http.Server{
		Addr:    fmt.Sprintf(":%s", port),
		Handler: router.Handler(),
	}

	// service connections
	if err := srv.ListenAndServe(); err != nil && errorCode != -1 {
		log.Fatalf("listen: %s\n", err)
	}
}
