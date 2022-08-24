module main
import websocket as ws
import vweb

struct App {
	vweb.Context
}

fn main() {

	// // run the websocket server on a routine
	// go ws.serve()

	// // run the http server (for serving frontend)
	// mut app := &App{}
	// app.serve_static('/', 'public/index.html')
	// app.handle_static('public', true)
	// vweb.run(app, 5000)

	ws.serve()?
}
