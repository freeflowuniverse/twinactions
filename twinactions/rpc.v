module twinactions

import os
import net.websocket
import term
import freeflowuniverse.crystallib.resp2

// does the rpc request to the handler
// the input is a resp builder, the first element is the cmd e.g. crypto.account.send (as string)
// the rest are the other required arguments
// communication is over websockets & uses resp (redis protocol)
// its a very simple ping/pong RPC mechanis, send, wait till it comes back
// the StringLine reader can be read as follows
// 			strlinglinereader.get_string()?
// 			strlinglinereader.get_bool()?
// 			strlinglinereader.get_int()?

fn start_client() ?&websocket.Client {
	mut ws := websocket.new_client('ws://localhost:30000')?
	// mut ws := websocket.new_client('wss://echo.websocket.org:443')?
	// use on_open_ref if you want to send any reference object
	ws.on_open(fn (mut ws websocket.Client) ? {
		println(term.green('websocket connected to the server and ready to send messages...'))
	})
	// use on_error_ref if you want to send any reference object
	ws.on_error(fn (mut ws websocket.Client, err string) ? {
		println(term.red('error: $err'))
	})
	// use on_close_ref if you want to send any reference object
	ws.on_close(fn (mut ws websocket.Client, code int, reason string) ? {
		println(term.green('the connection to the server successfully closed'))
	})
	// on new messages from other clients, display them in blue text
	ws.on_message(fn (mut ws websocket.Client, msg &websocket.Message) ? {
		if msg.payload.len > 0 {
			message := msg.payload.bytestr()
			println(term.blue('$message'))
		}
	})

	ws.connect() or { println(term.red('error on connect: $err')) }

	go ws.listen() // or { println(term.red('error on listen $err')) }
	return ws
}

// TODO complete
pub fn action_send(b resp2.Builder) ?resp.StringLineReader {
	// b.data.bytestr() needs to be send over the websockets (TODO)
	// return is also as bytestr for resp no need to decode here, return
	// data=bytestr{} //data is the return
	// ? b.prepend(resp.r_string(cmd)) // will prepend the cmd at the start ?

	// TODO: currently initializes new ws instance each time, must use one
	mut ws := start_client()
	ws.write_string(b.data.bytestr())?
	ws.on_message(fn (mut ws websocket.Client, msg &websocket.Message) ? {
		if msg.payload.len > 0 {
			res := msg.payload
			return resp.StringLineReader(res)
		}
	})

	// TODO: now send over websockets and make sure we get it back as StrinLineReader
	// res := resp....(data)? //this will decode the return and make sure it happens ok
	// return res
	error('not implemented')
}
