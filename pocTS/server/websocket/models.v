module websocket

import log


struct ServerOpt {
	logger &log.Logger = &log.Logger(
		&log.Log{
			level: .info
		}
	)
}

struct CLMessage {
	event string
	data EventsModel
}

enum Events {
	client_connected
	calculate_address_balance
	calculate_addresses_balances
}

type EventsChoice = Events | string

struct EventsModel {
	mut: 
		function string
		args string
}