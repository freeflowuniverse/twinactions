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
			handle_events(msg, mut ws)?
		}
	})
	s.on_close(fn (mut ws ws.Client, code int, reason string) ? {
		println(term.green('client ($ws.id) closed connection'))
	})
	s.listen() or { println(term.red('error on server listen: $err')) }
	unsafe {
		s.free()
	}
}

fn handle_events(msg &ws.Message, mut c ws.Client)? {
	// TODO: handle_events based on event type and id.
	mut data := EventsModel{}
	loaded 	:= json2.raw_decode(msg.payload.bytestr())?
	event 	:= loaded.as_map()['event'] or { panic(no_event) }
	if event.str() == 'client_connected'{
		println(event)
	}
	else if event.str() == 'get_twin_balance'{
		data.function = "balance.getMyBalance"
		data.args = '{}'
		response := ws.Message{
			opcode: msg.opcode
			payload: json.encode(CLMessage{
				event: 'invoke'
				data: data
			}).bytes()
		}
		println(response)
		c.write(response.payload, response.opcode) or { panic(err) } // send back the response to the client.
	} else {
		println(loaded)
	}
}
