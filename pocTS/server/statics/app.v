module statics

import vweb

struct App {
	vweb.Context
}

pub fn serve() {
	mut app := &App{}

	// paths in v are relative to cwd not to file directory
	// since this only expected to run from ../
	app.serve_static('/', 'statics/public/index.html')
	app.handle_static('statics/public', true)
	vweb.run(app, 5000)
}
