// The purpose of this code is to see if my understanding of Go and Fiber is correct.
// This version is attempting to integrate the JSON file
// If everything is working properly, I should be able to visit http://localhost:5000 and see the message below

// Program starts here in package main
package main

// Import fiber library for framework
// Import time library for timestamp
import (
	"time"
	"github.com/gofiber/fiber/v2"
)

// Main function
func main() {
	// Create new Fiber application
	app := fiber.New()

	// Define GET route for the URL, and send message when the route is accessed
	// GET only retrieves data, likely what I need for the final version
	app.Get("/", func(c *fiber.Ctx) error {
		// Get current time for timestamp
		current_time := time.Now()

		// Set response variable to hold fiber.Map data type, which allows us to use Unix timestamps alongside strings as data types (previously map[string]string was used, and was unable to do this)
		response := (fiber.Map{
			// Set "message" element to print string
			"message": "My name is Montana Pawek",
			// Set "timestamp" element to current_time converted to Unix
			"timestamp": current_time.Unix(),
		})

		// Print the response map above as a JSON object
		return c.JSON(response)
	})

	// The port where the application is listening
	err := app.Listen(":5000")
	if err != nil {
		panic(err)
	}

}
