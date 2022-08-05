// from https://github.com/gorilla/websocket/blob/master/examples/echo/server.go
package main

import (
	"flag"
	"html/template"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var addr = flag.String("addr", "localhost:8080", "http service address")
var upgrader = websocket.Upgrader{} // use default options

func echo(msg String) {
	return msg
}

func rpc_handler(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	for {
		mt, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		log.Printf("recv: %s", message)

		// TODO: Implement message handler for resp rpc's
		res = some_function(message)
		err = c.WriteMessage(mt, res)
		if err != nil {
			log.Println("write:", err)
			break
		}
	}
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/", rpc_handler)
	log.Fatal(http.ListenAndServe(*addr, nil))
}