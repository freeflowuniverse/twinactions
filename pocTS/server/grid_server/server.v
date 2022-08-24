module main

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

fn main() {

	mut app := &App{}
	vweb.run(app, 5001)

}

['/profile_config'; get]
pub fn (mut app App) profile_config() vweb.Result {
    config := Config{
		net: "dev"
		mne: "mom picnic deliver again rug night rabbit music motion hole lion where"
		sec: "secret"
	}
    res := json.encode(config)

	app.add_header("Access-Control-Allow-Origin", "*")
    return app.json(res)
}