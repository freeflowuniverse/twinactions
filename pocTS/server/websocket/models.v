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
	id          int
	eventtype 	string
}

enum Events {
	calculate_address_balance
	calculate_addresses_balances
}

type EventsChoice = Events | string

struct EventsModel {
	id             int
	servicetype    string
}