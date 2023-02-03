module websocket

import net.websocket as ws
import freeflowuniverse.crystallib.twinclient as tw
import term
import json

pub fn serve() ! {
	mut s := ws.new_server(.ip6, 8081, '/')
	s.on_connect(fn (mut s ws.ServerClient) !bool {
			if s.resource_name != '/' {
					return false
			}
			println('Client has connected...')
			return true
	})!

	s.on_message(fn (mut ws_client ws.Client, msg &tw.RawMessage) ! {
			handle_events(msg, mut ws_client)!
	})

	s.on_close(fn (mut ws ws.Client, code int, reason string) ! {
			println(term.green('client (${ws.id}) closed connection'))
	})

	s.listen() or { println(term.red('error on server listen: ${err}')) }

	unsafe {
			s.free()
	}
}

fn handle_events(raw_msg &tw.RawMessage, mut ws_client ws.Client) ! {
	if raw_msg.payload.len == 0 {
		return
	}

	mut transport := tw.WSTwinClient{}
	transport.init(mut ws_client)!
	mut grid := tw.grid_client(transport)!
	msg := json.decode(tw.Message, raw_msg.payload.bytestr()) or {
		println('cannot decode message')
		return
	}
	println("msg.event: $msg.event")

	if msg.event == 'algorand_list' {
		spawn fn [mut grid] () ! {
			grid.algorand_list()!
		}()
	} else {
		println('got a new message: ${msg.event}')
	}
}
