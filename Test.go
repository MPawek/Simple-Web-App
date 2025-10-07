// The purpose of this code is to see if my understanding of Go and Fiber is correct
// If everything is working properly, I should be able to visit http://localhost:5000 and see the message below

// Program starts here in package main
package main

// Import fiber library
import "github.com/gofiber/fiber/v2"

// Main function
func main() {
	// Create new Fiber application
	app := fiber.New()

	// Define GET route for the URL, and send message when the route is accessed
	// GET only retrieves data, likely what I need for the final version
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("It's working!")
	})

	// The port where the application is listening
	err := app.Listen(":5000")
	if err != nil {
		panic(err)
	}

}
