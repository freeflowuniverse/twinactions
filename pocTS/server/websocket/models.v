module websocket

import log


struct ServerOpt {
	logger &log.Logger = &log.Logger(
		&log.Log{
			level: .info
		}
	)
}

// general message between client <-> server
struct Message {
	id string
	// event type
	event string

	// data as json
	data string
}

enum Events {
	client_connected
	calculate_address_balance
	calculate_addresses_balances
}

struct InvokeRequest {
	mut:
		function string
		// json encoded args
		args string
}
