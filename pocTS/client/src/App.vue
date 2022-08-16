<template>
  <div id="app">
    <form @submit.prevent="onSubmit()">
      <div>
        <label>
          <p>Mnemonic</p>
          <input type="password" placeholder="Mnemonic" v-model="mnemonic" />
        </label>
      </div>

      <br />

      <div>
        <label>
          <p>Secret</p>
          <input type="password" placeholder="Secret" v-model="secret" />
        </label>
      </div>

      <br />

      <button type="submit">Calculate My Balance</button>
    </form>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";

interface IMessage {
  id: string;
  event: string;
  data: string;
}

interface IInvokeRequest {
  function: string;
  args: string;
}

@Component({
  name: "App",
})
export default class App extends Vue {
  mnemonic = "";
  secret = "";
  loading = false;

  async onSubmit() {
    this.loading = true;
    const { mnemonic, secret } = this;
    const grid = await this.$grid(mnemonic, secret);
    const socket = await this.$socket();
    socket.send(
      JSON.stringify({ event: "client_connected", data: `{ "id": 12 }` })
    );
    socket.send(
      JSON.stringify({ event: "get_my_balance", data: `{ "id": 12 }` })
    );

    this.loading = false;
  }

  async created() {
    const socket = await this.$socket();

    socket.onmessage = async (event: MessageEvent) => {
      const data = JSON.parse(event.data) as IMessage;
      console.log(data);

      if (data.event == "invoke") {
        const req = JSON.parse(data.data) as IInvokeRequest;
        const grid = await this.$grid(this.mnemonic, this.secret);
        const result = await grid.invoke(req.function, JSON.parse(req.args));
        // const result = {
        //   free: 1.2,
        //   reserved: 87.3,
        //   miscFrozen: 2323.32,
        //   feeFrozen: 23232.3232,
        // };

        socket.send(
          JSON.stringify({
            id: data.id,
            event: "invoke_result",
            data: JSON.stringify(result),
          })
        );

        console.log("result sent: ", result);
      }
    };
  }
}
</script>

<style lang="scss">
* {
  padding: 0;
  margin: 0;
  box-sizing: border-box;
  color: #333;
}

form {
  display: block;
  margin: 50px;
}
</style>
