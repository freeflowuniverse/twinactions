module websocket

const deploy_machines_form = websocket.Form{
	q_type: "form",
	question: '# Deploy a Virtual Machine',
	chat_id: get_id(),
	id: get_id(),
	description: 'VM Deployment Spces',
	form: [
		websocket.QuestionInput{
			chat_id: get_id(),
			q_type: "input",
			id: get_id(),
			question: '### What is the name of your VM?',
			descr: 'VM Name',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'vm_name',
			answer: 'testvm',
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### Node ID',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'node_id',
			answer: '11',
		},
		websocket.QuestionYn{
			q_type: "yn",
			chat_id: get_id(),
			id: get_id(),
			question: '### Public Ip',
			symbol: 'public_ip',
			answer: false,
		},
		websocket.QuestionYn{
			q_type: "yn",
			chat_id: get_id(),
			id: get_id(),
			question: '### Planetry Ip',
			symbol: 'planetary_ip',
			answer: true,
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### CPU Cores',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'cpu',
			answer: 1,
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### Memory in MB',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'memory',
			answer: 1024,
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### Root FS in GB',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'root_fs',
			answer: 1,
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### Flist',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'flist',
			answer: 'https://hub.grid.tf/tf-official-apps/threefoldtech-ubuntu-20.04.flist',
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### Entrypoint',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'entrypoint',
			answer: '/init.sh',
		},
		websocket.QuestionInput{
			q_type: "input",
			chat_id: get_id(),
			id: get_id(),
			question: '### SSH Key',
			descr: '',
			returntype: 'string',
			regex: '.*',
			regex_errormsg: '',
			min: 0,
			max: 0,
			sign: false,
			symbol: 'ssh_key',
			answer: '',
		},

	],
	symbol: "vm_specs"
	sign: false
}

const list_services_question = QuestionChoice{
  q_type: "choices",
  question: "Choose a services",
  chat_id: get_id(),
  id: get_id()
  descr: "services"
  sorted: true
  choices: [
	Choice{
		value: "deploy_vm_form",
		title: "Deploy VM",
	},
	Choice{
		value: "ping",
		title: "Ping",
	}
  ]
  multi: false,
  sign: false,
  symbol: "service",

  answer: "",
}