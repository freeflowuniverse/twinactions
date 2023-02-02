module main

import statics
// import config
import websocket

fn main() {
	go statics.serve()
	// go config.serve()
	websocket.serve()!
}
