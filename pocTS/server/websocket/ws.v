module websocket

import net.websocket as ws
import term
import json
import x.json2

import rand


struct TwinClient {
	pub mut:
		ws ws.Client
		channels  map[string]chan Message
}

pub fn init_client (mut ws ws.Client) TwinClient {
	mut channels := map[string]chan Message{}
	ws.on_message(fn[channels] (mut c ws.Client, ws_msg &ws.Message)? {
		println("got a message: $ws_msg")
		msg := json.decode(Message, ws_msg.payload.bytestr()) or {
			msgstr := ws_msg.payload.bytestr()
			println("cannot decode message:  $msgstr")
			return
		}
		if msg.event == "invoke_result" {
			channels[msg.id] <- msg
		}
	})
	return TwinClient {
		ws: ws
		channels: channels
	}
}

fn (mut tcl TwinClient) invoke(functionPath string, args string) ?string {
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
		println("sent req: $req")

		ret_msg := tcl.wait(id)
        return ret_msg.data
}

fn (mut tcl TwinClient) wait(id string) Message {
		channel := tcl.channels[id]
		res := <-channel
		channel.close()
		tcl.channels.delete(id)
		return res
}

struct Balance {
pub:
	free f64
	reserved f64
	misc_frozen f64 [json: miscFrozen]
	fee_frozen f64 [json: feeFrozen]
}

fn (mut tcl TwinClient) get_my_balance(req RequestWithID) ?Balance {
	data := tcl.invoke("balance.getMyBalance", "{}")?
	return json.decode(Balance, data)
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
	s.on_message(fn (mut ws ws.Client, msg &ws.Message) ? {
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

fn handle_events(ws_msg &ws.Message, mut c ws.Client)? {
	// TODO: handle_events based on event type and id.
	msg 	:= json.decode(Message, ws_msg.payload.bytestr())?
	println("msg: $msg")
	println("msg.event: $msg.event")
	if msg.event == 'client_connected'{
		println(msg.event)
	}

	else if msg.event == "get_my_balance" {
		mut client := init_client(mut c)
		req := json.decode(RequestWithID, msg.data) or {
			println("cannot decode req params: $msg.data")
			return
		}

		println("handling req: $req")
		balance := client.get_my_balance(req) or {
			println("couldn't get balance: $err")
			return err
		}

		data := json.encode(balance)
		resp_msg := Message{
			id: "anyidforresponse" // any id for resp
			event: "balance_result"
			data: data
		}

		payload := json.encode(resp_msg)
		c.write(payload.bytes(), ws_msg.opcode)?
	} else {
		println("unsupported type of event: $msg")
	}
}
