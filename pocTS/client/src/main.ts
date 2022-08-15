import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import { getGrid } from "./utils/getGrid";

let _SOCKET: WebSocket | null = null;

Vue.prototype.$grid = getGrid;
Vue.prototype.$socket = () => {
  if (_SOCKET === null) _SOCKET = new WebSocket("ws://localhost:8081");

  const SOCKET = _SOCKET!;
  return new Promise<WebSocket>((resolve) => {
    if (SOCKET.readyState === WebSocket.OPEN) return resolve(SOCKET);

    SOCKET.onopen = () => {
      resolve(SOCKET);
      SOCKET.onopen = null;
    };
  });
};
Vue.config.productionTip = false;

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");
