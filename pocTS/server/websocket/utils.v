module websocket

import rand

// ERROR handlera
const (
	no_event = "There is no event to do this action."
	no_data = "You must provide a data."
)

fn get_id() string {
	return rand.uuid_v4().split('-')[0]
}