// SimpleWebApp.go
// Minimal Fiber web app that returns:
// {"message":"My name is <Your Name>","timestamp":1234567890, "version": "<version>"}
// Visit http://localhost:8080 and see the message below

// Still testing

package main

// Import os library for environment variables
// Import fiber library for framework
// Import time library for timestamp
import (
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
)

func main() {

	app := fiber.New()

	// Define GET route for the URL, and send message when the route is accessed
	// GET only retrieves data
	app.Get("/", func(c *fiber.Ctx) error {
		// Get current time for timestamp
		current_time := time.Now()

		// Get current version of the app for the response (found in deployment)
		version := os.Getenv("VERSION")
		if version == "" {
			version = "1.0.0"
		}

		// Set response variable to hold fiber.Map data type, which allows us to use Unix timestamps alongside strings as data types
		// (previously map[string]string was used, and was unable to do this)
		response := (fiber.Map{

			// Set "message" element to print string
			"message": "My name is Montana Pawek",

			// Set "timestamp" element to current_time converted to Unix
			"timestamp": current_time.UnixMilli(),

			// Set "version" element to the current version of the app
			"version": version,
		})

		// Print the response map above as a JSON object
		return c.JSON(response)
	})

	// New version gets port from environment variable, which was necessary for Cloud Run, and defaults to 8080 if not set
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	err := app.Listen(":" + port)
	if err != nil {
		panic(err)
	}
}
