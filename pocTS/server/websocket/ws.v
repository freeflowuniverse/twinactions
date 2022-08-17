module websocket

import net.websocket as ws
import term
import json

import rand


type ResultHandler = fn (Message)
type RawMessage = ws.Message

struct TwinClient {
	pub mut:
		ws ws.Client
		callbacks  map[string]ResultHandler
}

pub fn init_client (mut ws ws.Client) TwinClient {
	mut callbacks := map[string]ResultHandler{}
	ws.on_message(fn[mut callbacks] (mut c ws.Client, raw_msg &RawMessage)? {
		msg := json.decode(Message, raw_msg.payload.bytestr()) or {
			msgstr := raw_msg.payload.bytestr()
			println("cannot decode message:  $msgstr")
			return
		}
		if msg.event == "invoke_result" {
			callback := callbacks[msg.id] or {
				println("callback for $msg.id is not there")
				return
			}
			callback(msg)
		}
	})
	return TwinClient {
		ws: ws
		callbacks: callbacks
	}
}

fn (mut tcl TwinClient) invoke(functionPath string, args string, callback ResultHandler) ? {
       id := rand.uuid_v4()

		mut  req := InvokeRequest{}
	   	req.function = "balance.getMyBalance"
		req.args = args

		payload := json.encode(
			Message{
				id: id,
				event: 'invoke'
				data: json.encode(req)
			}
		).bytes()

		tcl.ws.write(payload, .text_frame)?
		tcl.register_callback(id, callback)
}

fn (mut tcl TwinClient) register_callback(id string, callback ResultHandler) {
	// might have a callback wrapper that removes the callback after calling it
	// without errors

	// this does not compile
	// tcl.callbacks[id] = fn[mut tcl, id, callback](msg Message) {
	// 	callback(msg)
	// 	tcl.callbacks.delete(id)
	// }

	tcl.callbacks[id] = callback
}

struct Balance {
pub:
	free f64
	reserved f64
	misc_frozen f64 [json: miscFrozen]
	fee_frozen f64 [json: feeFrozen]
}

fn (mut tcl TwinClient) get_my_balance(req RequestWithID, callback ResultHandler) ? {
	tcl.invoke("balance.getMyBalance", "{}", callback)?
}

pub fn serve()?{
	mut s := ws.new_server(.ip6, 8081, '/')
	s.on_connect(fn (mut s ws.ServerClient) ?bool {
		if s.resource_name != '/' {
			return false
		}
		println('Client has connected...')
		return true
	})?
	s.on_message(fn (mut ws ws.Client, msg &RawMessage) ? {
		handle_events(msg, mut ws)?
	})
	s.on_close(fn (mut ws ws.Client, code int, reason string) ? {
		println(term.green('client ($ws.id) closed connection'))
	})
	s.listen() or { println(term.red('error on server listen: $err')) }
	unsafe {
		s.free()
	}
}

struct RequestWithID {
pub:
	id string
}

fn handle_events(raw_msg &RawMessage, mut c ws.Client)? {
	msg 	:= json.decode(Message, raw_msg.payload.bytestr())?

	if msg.event == 'client_connected'{
		println(msg.event)
	} else if msg.event == "get_my_balance" {
		mut client := init_client(mut c)
		req := json.decode(RequestWithID, msg.data) or {
			println("cannot decode req params: $msg.data")
			return
		}

		callback := fn[mut c](msg Message) {
			// here we decided to send the result back
			// but we can do anything with this result
			resp_msg := Message{
				id: "anyidforresponse" // any id for resp
				event: "balance_result"
				data: msg.data
			}

			payload := json.encode(resp_msg)
			c.write(payload.bytes(), .text_frame) or {
				println("cannot send payload")
				return
			}
		}

		client.get_my_balance(req, callback) or {
			println("couldn't get balance: $err")
			return err
		}

	} else {
		println("got a new message: $msg.event")
	}
}
