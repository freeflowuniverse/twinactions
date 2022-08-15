module main

import net.websocket as ws
import log
import term



struct ServerOpt {
	logger &log.Logger = &log.Logger(&log.Log{
	level: .info
})
}

fn main() {
	new_server()?
}

fn new_server()?{
	mut s := ws.new_server(.ip6, 8081, '')
	// s.setup_callbacks()
	s.ping_interval = 100
	s.on_connect(fn (mut s ws.ServerClient) ?bool {
		if s.resource_name != '/' {
			return false
		}
		println('Client has connected...')
		return true
	})?
	s.on_message(fn (mut ws ws.Client, msg &ws.Message) ? {
		response := handle_message(msg)?
		ws.write(response.payload, response.opcode) or { panic(err) }
	})
	s.on_close(fn (mut ws ws.Client, code int, reason string) ? {
		println(term.green('client ($ws.id) closed connection'))
	})
	s.listen() or { println(term.red('error on server listen: $err')) }
	unsafe {
		s.free()
	}

	addresses := [
		"GB37FSNVWTMEOL4VD3SCMMTDVAB6VIA6STL4BUHB3FF3CVYXNNHWRJU2",
		"GARPUGX3FM6RWC2Q3CVNHD62XJAY36QWFSPF6P67GOBWLSK5WHSRZOLV",
		"GDLGVXZMILA5HE2X34FLIPGB7OWQMHESFFFAEBE5PUQSPFYRIJ4TON7K"
	]
}

type Handler = fn ([]u8) []u8

fn handle_message(msg &ws.Message) ?&ws.Message {
	println('Received new message: ${msg.payload.bytestr()}')
	mut payload := []u8{}
	response := ws.Message{
		opcode: msg.opcode
		payload: payload
	}
	return &response
}

struct MCMessage {
	id          int
	servicetype string
	descr       string
	choices     []string
	multi       bool
	sorted      bool
	sign        bool
}