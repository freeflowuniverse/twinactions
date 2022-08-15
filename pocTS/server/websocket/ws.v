module websocket

import net.websocket as ws
import term
import json
import x.json2

pub fn serve()?{
	mut s := ws.new_server(.ip6, 8081, '/')
	s.on_connect(fn (mut s ws.ServerClient) ?bool {
		if s.resource_name != '/' {
			return false
		}
		println('Client has connected...')
		return true
	})?
	s.on_message(fn (mut ws ws.Client, msg &ws.Message) ? {
		if msg.payload != [] {
			response := handle_message(msg)?
			ws.write(response.payload, response.opcode) or { panic(err) } // send back the response to the client.
		}
	})
	s.on_close(fn (mut ws ws.Client, code int, reason string) ? {
		println(term.green('client ($ws.id) closed connection'))
	})
	s.listen() or { println(term.red('error on server listen: $err')) }
	unsafe {
		s.free()
	}

	// addresses := [
	// 	"GB37FSNVWTMEOL4VD3SCMMTDVAB6VIA6STL4BUHB3FF3CVYXNNHWRJU2",
	// 	"GARPUGX3FM6RWC2Q3CVNHD62XJAY36QWFSPF6P67GOBWLSK5WHSRZOLV",
	// 	"GDLGVXZMILA5HE2X34FLIPGB7OWQMHESFFFAEBE5PUQSPFYRIJ4TON7K"
	// ]
}

fn handle_message(msg &ws.Message) ?&ws.Message {
	println('Received new message: ${msg.payload.bytestr()}')
	payload := handle_events(msg.payload)?
	response := ws.Message{
		opcode: msg.opcode
		payload: payload
	}

	return &response
}

fn handle_events(payload []u8)? []u8 {
	// TODO: handle_events based on event type and id.
	mut result 	:= map[string]string
	loaded 	:= json2.raw_decode(payload.bytestr())?
	event 	:= loaded.as_map()['event'] or { panic(no_event) }
	data 	:= loaded.as_map()['data'] or { panic(no_data) }
	if event.str() == 'client_connected' {
		result['data'] = data.str()
		result['function'] = "getTwinBalance"
	}
	else if event.str() == 'getTwinBalance'{
		println(data)
	}
	response := json.encode(CLMessage{
		event: 'client_connected'
		data: result
	})
	return response.bytes()
}
