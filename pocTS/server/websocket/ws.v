module websocket

import net.websocket as ws
import freeflowuniverse.crystallib.twinclient2 as tw
import term
import json
import x.json2

fn echo(mut client tw.TwinClient, log Response)? {
	// print in server
	println(log.log)

	// push logs to client
	payload := json.encode(log)
	client.ws.write_string(payload)?
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
		// 	go fn [mut client]() {
		// 		addrs := [
		// 		"5CoairYXspX6MHeAFaJ9Ki3Fsj2sFXVHf11ymPXcsWX5a7Mw",
		// 		"5D8ByeiGwKJ5YiZZfKAduomE5fezcR4xMVEcwfTxYm67UBSE"
		// 		]
		// 		mut total := 0.0
		// 		for addr in addrs {
		// 			balance := client.get_balance(addr) or {
		// 				println("couldn't get balance: $err")
		// 				return
		// 			}

		// 			total += balance.free
		// 		}
		// 		// here we decided to send the result back
		// 		// but we can do anything with this result
		// 		resp_msg := tw.Message{
		// 			id: "anyidforresponse" // any id for resp
		// 			event: "balance_result"
		// 			data: json.encode(total)
		// 		}

		// 		payload := json.encode(resp_msg)
		// 		client.ws.write_string(payload) or {
		// 			println("cannot send payload: $err")
		// 			return
		// 		}
		// 	}()
	} else if msg.event == "deploy_vm_form" {

		res := Response{
			event: "question"
			question: deploy_machines_form
		}
		
		echo(mut client, res)?
	
	} else if msg.event == "deploy_vm" {
		
		data := json2.raw_decode(msg.data)?
		vm := data.as_map()

		go fn [mut client, vm]() {
			vm_name := vm["vm_name"] or {
				println("Couldn't get vm_name")
				return
			}
			node_id := vm["node_id"] or {
				println("Couldn't get node_id")
				return
			}
			public_ip := vm["public_ip"] or {
				println("Couldn't get public_ip")
				return
			}
			planetary := vm["planetary_ip"] or {
				println("Couldn't get planetary")
				return
			}
			cpu := vm["cpu"] or {
				println("Couldn't get cpu")
				return
			}
			memory := vm["memory"] or {
				println("Couldn't get memory")
				return
			}
			rootfs_size := vm["root_fs"] or {
				println("Couldn't get rootfs_size")
				return
			}
			flist := vm["flist"] or {
				println("Couldn't get flist")
				return
			}
			entrypoint := vm["entrypoint"] or {
				println("Couldn't get entrypoint")
				return
			}
			ssh_key := vm["ssh_key"] or {
				println("Couldn't get ssh_key")
				return
			}


			machines := tw.MachinesModel{
				name: vm_name.str()
				network: tw.Network{
					ip_range: '10.200.0.0/16'
					name: vm_name.str() + 'net'
					add_access: false
					}
				machines: [
					tw.Machine{
						name: vm_name.str()
						node_id: node_id.str().u32()
						disks: []
						qsfs_disks: []
						public_ip: public_ip.bool()
						planetary: planetary.bool()
						cpu: cpu.str().u32()
						memory: memory.str().u64()
						rootfs_size: rootfs_size.str().u64()
						flist: flist.str()
						entrypoint: entrypoint.str()
						env: tw.Env{
							ssh_key: ssh_key.str()
						}
					}
				]
			}

			echo(mut client, Response{
				event: "echo"
				log: json.encode(machines)
			}) or {
				println("Couldn't echo machines")
			}

			response := client.machines_deploy(machines) or {
				println("Couldn't deploy a vm")
				return
			}

			echo(mut client, Response{
				event: "echo"
				log: json.encode(response)
			}) or {
				println("Couldn't echo")
			}

			deployment_info := client.machines_get(vm_name.str()) or {
				println("Coudn't get vm")
				return
			}

			echo(mut client, Response{
				event: "echo_and_question"
				log: json.encode(deployment_info)
				question: list_services_question
			}) or {
				println("Couldn't echo")
			}

		}()
	} else if msg.event == "services_list" {
		
		res := Response{
			event: "question"
			question: list_services_question
		}
		
		echo(mut client, res)?

	} else if msg.event == "get_balance_form" {
		
		res := Response{
			event: "question"
			question: get_balance_question
		}
		
		echo(mut client, res)?
	} else if msg.event == "get_balance" {

		echo(mut client, Response{
			event: "echo"
			log: json.encode("Getting balance")
		}) or {
			println("Couldn't echo balance")
		}

		res := json2.raw_decode(msg.data)?
		data := res.as_map()["acc_address"] or {
			println("Couldn't find acc_address in response")
			return 
		}
		acc_address := data.str()

		go fn [mut client, acc_address]() {
			response := client.stellar_balance_by_address(acc_address) or {
				println("Couldn't get balance")
				return
			}

			echo(mut client, Response{
				event: "echo_and_question"
				log: json.encode(response)
				question: list_services_question
			}) or {
				println("Couldn't echo balance")
			}
		}()

	} else if msg.event == "get_twin_question" {
		
		res := Response{
			event: "question"
			question: get_twin_question
		}
		
		echo(mut client, res)?
	} else if msg.event == "get_twin" {

		echo(mut client, Response{
			event: "echo"
			log: json.encode("Getting Twin")
		}) or {
			println("Couldn't echo twin")
		}

		res := json2.raw_decode(msg.data)?
		data := res.as_map()["twin_id"] or {
			println("Couldn't find twin_id in response")
			return 
		}
		twin_id := data.str().u32()

		go fn [mut client, twin_id]() {
			response := client.twins_get(twin_id) or {
				println("Couldn't get twin_id")
				return
			}

			echo(mut client, Response{
				event: "echo_and_question"
				log: json.encode(response)
				question: list_services_question
			}) or {
				println("Couldn't echo twin")
			}
		}()
	} else if msg.event == "deploy_k8s_question" {

		res := Response{
			event: "question"
			question: deploy_k8s_form
		}
		
		echo(mut client, res)?
	
	} else if msg.event == "deploy_k8s" {
		
		data := json2.raw_decode(msg.data)?
		k8s := data.as_map()

		go fn [mut client, k8s]() {
			cluster_name := k8s["cluster_name"] or {
				println("Couldn't get cluster_name")
				return
			}
			node_id := k8s["node_id"] or {
				println("Couldn't get node_id")
				return
			}
			public_ip := k8s["public_ip"] or {
				println("Couldn't get public_ip")
				return
			}
			planetary := k8s["planetary_ip"] or {
				println("Couldn't get planetary")
				return
			}
			cpu := k8s["cpu"] or {
				println("Couldn't get cpu")
				return
			}
			memory := k8s["memory"] or {
				println("Couldn't get memory")
				return
			}
			rootfs_size := k8s["root_fs"] or {
				println("Couldn't get rootfs_size")
				return
			}
			ssh_key := k8s["ssh_key"] or {
				println("Couldn't get ssh_key")
				return
			}
			mr_number := k8s["mr_number"] or {
				println("Couldn't get mr_number")
				return
			}
			wr_number := k8s["wr_number"] or {
				println("Couldn't get wr_number")
				return
			}

			mut mr_nodes_list := []tw.KubernetesNode{}
			mut wr_nodes_list := []tw.KubernetesNode{}
			
			for i in 0..mr_number.str().int() {
				mr_node := tw.KubernetesNode{
					name: "mr" + i.str()
					node_id: node_id.str().u32()
					cpu: cpu.str().u32()
					memory: memory.str().u32()
					rootfs_size: rootfs_size.str().u32()
					disk_size: 50
					public_ip: public_ip.str().bool()
					planetary: planetary.str().bool()
				}
				mr_nodes_list << mr_node
			}

			for i in 0..wr_number.str().int() {
				wr_node := tw.KubernetesNode{
					name: "wr" + i.str()
					node_id: node_id.str().u32()
					cpu: cpu.str().u32()
					memory: memory.str().u32()
					rootfs_size: rootfs_size.str().u32()
					disk_size: 50
					public_ip: public_ip.str().bool()
					planetary: planetary.str().bool()
				}
				wr_nodes_list << wr_node
			}

			cluster := tw.K8SModel{
				name: cluster_name.str()
				secret: "secret"
				ssh_key: ssh_key.str()
				network: tw.Network{
					ip_range: '10.200.0.0/16'
					name: cluster_name.str() + 'net'
					add_access: false
					}
				masters: mr_nodes_list
				workers: wr_nodes_list
			}

			// echo(mut client, Response{
			// 	event: "echo"
			// 	log: json.encode(cluster)
			// }) or {
			// 	println("Couldn't echo machines")
			// }

			response := client.kubernetes_deploy(cluster) or {
				println("Couldn't deploy a cluster")
				return
			}

			echo(mut client, Response{
				event: "echo"
				log: json.encode(response)
			}) or {
				println("Couldn't echo")
			}

			deployment_info := client.kubernetes_get(cluster_name.str()) or {
				println("Coudn't get cluster")
				return
			}

			echo(mut client, Response{
				event: "echo_and_question"
				log: json.encode(deployment_info)
				question: list_services_question
			}) or {
				println("Couldn't echo")
			}

		}()
	} else {
		println("got a new message: $msg.event")
	}
}
