module websocket

import net.websocket as ws
import freeflowuniverse.crystallib.twinclient2 as tw
import term
import json

__global (

id=0
)

pub fn serve()?{
	mut s := ws.new_server(.ip6, 8081, '/')
	s.on_connect(fn (mut s ws.ServerClient) ?bool {
		if s.resource_name != '/' {
			return false
		}
		println('Client has connected...')
		return true
	})?
	s.on_message(fn (mut ws ws.Client, msg &tw.RawMessage) ? {
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

struct Log {
	id int
	msg string
}
 
struct Response {
	logs Log
	question Form
}


fn handle_events(raw_msg &tw.RawMessage, mut c ws.Client)? {
	if raw_msg.payload.len == 0 {
		return
	}

	println("got a: $raw_ms")
	println("got a raw msg: $raw_msg.payload $raw_msg.opcode")

	mut client := tw.init_client(mut c)
	msg 	:= json.decode(tw.Message, raw_msg.payload.bytestr()) or {
		println("cannot decode message")
		return
	}

	if msg.event == 'client_connected'{
		println(msg.event)

	} else if msg.event == "task" {

		/*
		cp the dist
		client.deploy_vm(specs)
		send mini-form Q to client >> construct the data to vm specs
		*/

		println(msg.event)

		logs := Log{
			id: 0
			msg: "Fill Form"
		}

		/*
		name
		node_id
		public_ip
		planetary
		cpu
		memory
		rootfs_size
		flist
		entrypoint
		env
		*/
		
		qs := websocket.Form{
			q_type: websocket.q_types.form,
			question: '# Deploy a Virtual Machine',
			chat_id: "0",
			id: 10,
			description: 'VM Deployment Spces',
			form: [
				websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### What is the name of your VM?',
                descr: 'VM Name',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
				symbol: 'name'
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Node ID',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
              websocket.QuestionYn{
                q_type: websocket.q_types.yn,
                chat_id: "0",
                question: '### Public Ip',
                id: id++,
                answer: '',
              },
			  websocket.QuestionYn{
                q_type: websocket.q_types.yn,
                chat_id: "0",
                question: '### Planetry Ip',
                id: id++,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### CPU Cores',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Memory in MB',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Root FS in GB',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Flist',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Entrypoint',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },
			  websocket.QuestionInput{
                q_type: websocket.q_types.input,
                id: id++,
                question: '### Environment Variables',
                descr: '',
                returntype: 'string',
                regex: '.*',
                regex_errormsg: '',
                min: 0,
                max: 0,
                sign: false,
                answer: '',
              },

			],
			sign: false
		}

		res_form := Response{
			logs: logs,
			question: qs
		}
		

	
		payload := json.encode(res_form)
		client.ws.write_string(payload) or {
			println("cannot send payload: $err")
			return
		}
		
	} else if msg.event == "sum_balances" {
		
		// machine := tw.Machine{'test2411822',
		// 	2,
		// 	[], 
		// 	[], 
		// 	false, 
		// 	true, 
		// 	2, 
		// 	1024, 
		// 	1, 
		// 	"https://hub.grid.tf/tf-official-apps/base:latest.flist",
		// 	"/sbin/zinit init",
		// 	tw.Env{ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCa5srzZwh3ulajtY2EZ1SiPY1JNelcaP8O/FZqrnJi6OxAPijl0KzoNrzgemqxhAS/eIglBYbgQuw/Po15MtdMgXmfrtNgrZjQQtLxGFz5KmUbzawPGI7iRkN40LEo0y0hcGLV1G+YiNO+3YU7K5I+gos+04OUJe4HYjcp92nAEviqxa40po2f67KgP5xrZxaOpELZA/hIf1wCzCyTsdvu3k+hw1QlSTIso6WTcUw7LLssvxAs7JZ31kgx+L740xQJWsiVv/go3td0GuETfRSbfjBtOD/wIEHG5UtazOrR+8ukotqQ/ERWuyx1abaEKwro3fLunmjhfgDbnJYy7As1 ahmed@ahmed-Inspiron-3576"}
		// 	}
		// machines := tw.Machines {
		// 	"test2411822", tw.Network{
		// 		"10.20.0.0/16",
		// 		"test24",
		// 		false
		// 	},
		// 	[machine],
		// 	"",
		// 	""
		// }
		// response := client.import_wallet(name: "test241182", address: "", secret: "SACLKHTVC3K36GCW6EPN7DAXNLLWPWLSFDAMM4EV22KRF62JK342QISI")?

		// response := client.deploy_machines(machines)? 
		// println("address $response.address")
		// response2 := client.balance_by_name("test241182")?
		// println(response2[0].amount)
		// response3 := client.list_wallets()?
		// println(response3)
		go fn [mut client]() {
			addrs := [
			"5CoairYXspX6MHeAFaJ9Ki3Fsj2sFXVHf11ymPXcsWX5a7Mw",
			"5D8ByeiGwKJ5YiZZfKAduomE5fezcR4xMVEcwfTxYm67UBSE"
			]
			mut total := 0.0
			for addr in addrs {
				balance := client.get_balance(addr) or {
					println("couldn't get balance: $err")
					return
				}

				total += balance.free
			}
			// here we decided to send the result back
			// but we can do anything with this result
			resp_msg := tw.Message{
				id: "anyidforresponse" // any id for resp
				event: "balance_result"
				data: json.encode(total)
			}

			payload := json.encode(resp_msg)
			client.ws.write_string(payload) or {
				println("cannot send payload: $err")
				return
			}
		}()

	} else if msg.event == "echo" {
		println("deployvm")
		println("resp: $msg.data")

		/*
		- send symbol with the q
		- {id: { symbol: "memory", value: answer}}
		- encode to defined structs
		- construct the machine(s)
		
		*/

		// resp := msg.data.
		// println(resp)
	// machine := tw.Machine{'test2411822',
	// 			2,
	// 			[], 
	// 			[], 
	// 			false, 
	// 			true, 
	// 			2, 
	// 			1024, 
	// 			1, 
	// 			"https://hub.grid.tf/tf-official-apps/base:latest.flist",
	// 			"/sbin/zinit init",
	// 			tw.Env{ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCa5srzZwh3ulajtY2EZ1SiPY1JNelcaP8O/FZqrnJi6OxAPijl0KzoNrzgemqxhAS/eIglBYbgQuw/Po15MtdMgXmfrtNgrZjQQtLxGFz5KmUbzawPGI7iRkN40LEo0y0hcGLV1G+YiNO+3YU7K5I+gos+04OUJe4HYjcp92nAEviqxa40po2f67KgP5xrZxaOpELZA/hIf1wCzCyTsdvu3k+hw1QlSTIso6WTcUw7LLssvxAs7JZ31kgx+L740xQJWsiVv/go3td0GuETfRSbfjBtOD/wIEHG5UtazOrR+8ukotqQ/ERWuyx1abaEKwro3fLunmjhfgDbnJYy7As1 ahmed@ahmed-Inspiron-3576"}
	// 			}
	// 		machines := tw.Machines {
	// 			"test2411822", tw.Network{
	// 				"10.20.0.0/16",
	// 				"test24",
	// 				false
	// 			},
	// 			[machine],
	// 			"",
	// 			""
	// 		}

	
	} else {
		println("got a new message: $msg.event")
	}

}
