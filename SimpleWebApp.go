// SimpleWebApp.go
// Minimal Fiber web app that returns:
// {"message":"My name is <Your Name>","timestamp":1234567890, "version": "<version>"}
// Visit http://localhost:8080 and see the message below

package main

// os library for environment variables
// fiber library for framework
// time library for timestamp
import (
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
)

func main() {

	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {

		// Version is determined during deployment and set to environment variable, and defaults to 1.0.0 if not set
		version := os.Getenv("VERSION")
		if version == "" {
			version = "1.0.0"
		}

		response := (fiber.Map{

			"message": "My name is Montana Pawek",

			"timestamp": time.Now().UnixMilli(),

			"version": version,

			"update": "This is the new version",
		})

		return c.JSON(response)
	})

	// Gets port from environment variable, which was necessary for Cloud Run, and defaults to 8080 if not set
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	err := app.Listen(":" + port)
	if err != nil {
		panic(err)
	}
}
