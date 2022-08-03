# module twinactions


# Twin actions

set of actions as can be executed by twin, can be done by different executors e.g.

- vlang
- golang
- javascript

most of them right now are done in golang



## Contents
- [action_send](#action_send)

## action_send
```v
fn action_send(b resp.Builder) ?resp.StringLineReader
```

does the rpc request to the handler the input is a resp builder, the first element is the cmd e.g. crypto.account.send (as string) the rest are the other required arguments communication is over websockets & uses json for now (no binary supported), will be resp (redis protocol later) its a very simple ping/pong RPC mechanis, send, wait till it comes back the StringLine reader can be read as follows 			strlinglinereader.get_string()? 			strlinglinereader.get_bool()? 			strlinglinereader.get_int()? TODO complete

[[Return to contents]](#Contents)

#### Powered by vdoc.
