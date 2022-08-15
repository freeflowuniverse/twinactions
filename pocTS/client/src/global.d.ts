import { GridClient } from "grid3_client";
import { Socket } from "socket.io";
import Vue from "vue";

declare module "vue/types/vue" {
  interface Vue {
    $socket: () => Promise<WebSocket>;
    $grid: (mnemonic: string, secret: string) => Promise<GridClient>;
  }
}
