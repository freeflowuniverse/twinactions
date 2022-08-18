module websocket

import log


struct ServerOpt {
	logger &log.Logger = &log.Logger(
		&log.Log{
			level: .info
		}
	)
}


