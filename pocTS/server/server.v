module main
import websocket as ws
import vweb

struct App {
	vweb.Context
}

fn main() {

	go ws.serve()
	// implement the same functionality of nest.ts server

	mut app := &App{}

	app.serve_static('/', 'public/index.html')
	app.handle_static('public', true)

	vweb.run(app, 5000)
}
