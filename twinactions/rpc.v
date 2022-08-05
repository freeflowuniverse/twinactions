module twinactions

import freeflowuniverse.crystallib.resp

// does the rpc request to the handler
// the input is a resp builder, the first element is the cmd e.g. crypto.account.send (as string)
// the rest are the other required arguments
// communication is over websockets & uses json for now (no binary supported), will be resp (redis protocol later)
// its a very simple ping/pong RPC mechanis, send, wait till it comes back
// the StringLine reader can be read as follows
// 			strlinglinereader.get_string()?
// 			strlinglinereader.get_bool()?
// 			strlinglinereader.get_int()?
// TODO complete
pub fn action_send(b resp.Builder) ?resp.StringLineReader {
	// b.data.bytestr() needs to be send over the websockets (TODO)
	// return is also as bytestr for resp no need to decode here, return
	// data=bytestr{} //data is the return

	// TODO: now send over websockets and make sure we get it back as StrinLineReader
	// res := resp....(data)? //this will decode the return and make sure it happens ok
	// return res
	error('not implemented')
}
