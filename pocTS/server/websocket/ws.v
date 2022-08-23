module websocket

import net.websocket as ws
import freeflowuniverse.crystallib.twinclient2 as tw
import term
import json
import x.json2


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

fn handle_events(raw_msg &tw.RawMessage, mut c ws.Client)? {

	// println("got a raw msg: $raw_msg.payload $raw_msg.opcode")

	mut client := tw.init_client(mut c)

	if raw_msg.payload.len == 0 {
		return
	}
	msg 	:= json.decode(tw.Message, raw_msg.payload.bytestr()) or {
		println("cannot decode message")
		return
	}
	println("msg.event: $msg.event")



	if msg.event == 'client_connected'{
		println(msg.event)

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
	} else if msg.event == "deploy_vm_form" {

		logs := Log{
			id: 0
			msg: "Fill Form"
		}
		
		qs := deploy_machines_form

		res_form := Response{
			logs: logs,
			question: qs
		}
		
		payload := json.encode(res_form)
		client.ws.write_string(payload) or {
			println("cannot send payload: $err")
			return
		}
	
	} else if msg.event == "deploy_vm" {

		println(msg.data)
		
		data := json2.raw_decode(msg.data)?
		vm := data.as_map()

		machines := tw.Machines{
			name: vm["vm_name"]?.str()
			network: tw.Network{
				ip_range: '10.200.0.0/16'
				name: 'net3'
				add_access: false
				}
			machines: [
				tw.Machine{
					name: vm["vm_name"]?.str()
					node_id: vm["node_id"]?.str().u32()
					disks: []
					qsfs_disks: []
					public_ip: vm["public_ip"]?.bool()
					planetary: vm["planetry_ip"]?.bool()
					cpu: vm["cpu"]?.str().u32()
					memory: vm["memory"]?.str().u64()
					rootfs_size: vm["root_fs"]?.str().u64()
					flist: vm["flist"]?.str()
					entrypoint: vm["entrypoint"]?.str()
					env: tw.Env{
						ssh_key: vm["ssh_key"]?.str()
					}
				}
			]
		}
		println(machines)

    	response := client.deploy_machines(machines)?
		println(response)

	} else {
		println("got a new message: $msg.event")
	}
}
