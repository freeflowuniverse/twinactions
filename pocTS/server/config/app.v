module config

import vweb
import json

struct App {
	vweb.Context
}

struct Config {
	net string
	mne string
	sec string
}

pub fn serve() {
	mut app := &App{}
	vweb.run(app, 5001)
}

['/profile_config'; get]
pub fn (mut app App) profile_config() vweb.Result {
    config := Config{
		net: $env('NET')
		mne: $env('MNE')
		sec: $env('MNE')
	}
    res := json.encode(config)

	app.add_header("Access-Control-Allow-Origin", "*")
    return app.json(res)
}