import {
  GridClient,
  NetworkEnv,
  BackendStorageType,
  KeypairType,
} from "grid3_client";
import { HTTPMessageBusClient } from "ts-rmb-http-client";

const RMB = new HTTPMessageBusClient(0, "", "", "");

export function getGrid(mnemonic: string, secret: string) {
  const grid = new GridClient(
    NetworkEnv.dev,
    mnemonic,
    secret,
    RMB,
    undefined,
    BackendStorageType.auto,
    KeypairType.sr25519
  );

  return grid.connect().then(() => grid);
}
