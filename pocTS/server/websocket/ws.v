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
		channels  map[string]chan Message
}

pub fn init_client (mut ws ws.Client) TwinClient {
	mut tcl := TwinClient{
		ws: ws,
		channels: map[string]chan Message{}
	}

	ws.on_message(fn[mut tcl] (mut c ws.Client, raw_msg &RawMessage)? {
		if raw_msg.payload.len == 0 {
			return
		}

		// println("got a raw msg: $raw_msg")
		msg := json.decode(Message, raw_msg.payload.bytestr()) or {
			// msgstr := raw_msg.payload.bytestr()
			println("cannot decode message payload")
			return
		}

		if msg.event == "invoke_result" {
			println("processing invoke request")
			channel := tcl.channels[msg.id] or {
				println("channel for $msg.id is not there")
				return
			}

			println("pushing msg to channel: $msg.id")
			channel <- msg
		}

	})

	return tcl
}

fn (mut tcl TwinClient) invoke(functionPath string, args string) ?Message {
       id := rand.uuid_v4()

       channel := chan Message{}
       tcl.channels[id] = channel

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
		println("waiting for result...")
		return tcl.wait(id)
}

fn (mut tcl TwinClient) wait(id string) ?Message {
		if channel := tcl.channels[id] {
			res := <-channel
			channel.close()
			tcl.channels.delete(id)
			return res
		}

		return error('wait channel of $id is not present')
}

fn (mut tcl TwinClient) get_my_balance(req RequestWithID) ?Balance {
	ret := tcl.invoke("balance.getMyBalance", "{}")?
	return json.decode(Balance, ret.data)
}

struct RequestWithAddress {
pub:
	address string
}

fn (mut tcl TwinClient) get_balance(req RequestWithAddress) ?Balance {
	ret := tcl.invoke("balance.getMyBalance", json.encode(req))?
	return json.decode(Balance, ret.data)
}



struct Balance {
pub:
	free f64
	reserved f64
	misc_frozen f64 [json: miscFrozen]
	fee_frozen f64 [json: feeFrozen]
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
	if raw_msg.payload.len == 0 {
		return
	}

	println("got a raw msg: $raw_msg.payload $raw_msg.opcode")

	mut client := init_client(mut c)
	msg 	:= json.decode(Message, raw_msg.payload.bytestr()) or {
		println("cannot decode message")
		return
	}


	if msg.event == 'client_connected'{
		println(msg.event)
	} else if msg.event == "sum_balances" {
		addrs := [
			"5CoairYXspX6MHeAFaJ9Ki3Fsj2sFXVHf11ymPXcsWX5a7Mw",
			"5D8ByeiGwKJ5YiZZfKAduomE5fezcR4xMVEcwfTxYm67UBSE"
		]
		mut total := 0.0
		for addr in addrs {
			req := RequestWithAddress{
				address: addr
			}
			balance := client.get_balance(req) or {
				println("couldn't get balance: $err")
				return
			}

			total += balance.free
		}

		// here we decided to send the result back
		// but we can do anything with this result
		resp_msg := Message{
			id: "anyidforresponse" // any id for resp
			event: "balance_result"
			data: json.encode(total)
		}

		payload := json.encode(resp_msg)
		c.write(payload.bytes(), .text_frame) or {
			println("cannot send payload")
			return

		}

	} else {
		println("got a new message: $msg.event")
	}

}
