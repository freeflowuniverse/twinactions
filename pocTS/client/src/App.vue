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

      <button type="submit" :disabled="!mnemonic || !secret || loading">
        Calculate My Balance
      </button>

    </form>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";

interface IData {
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
      JSON.stringify({ event: "client_connected", data: {"id": 12} })
    );
    socket.send(
      JSON.stringify({ event: "get_twin_balance", data: {"id": 12} })
    );

    this.loading = false;
  }

  async created() {
    const socket = await this.$socket();

    socket.onmessage = async ({ data: _data }: { data: { data: IData } }) => {
      console.log(_data);
      
      const { data } = JSON.parse(_data as unknown as string) as {
        data: IData;
      };
      console.log(data);

      const grid = await this.$grid(this.mnemonic, this.secret);
      const result = await grid.invoke(data.function, JSON.parse(data.args));

      socket.send(JSON.stringify({ event: "hamada", data: result }));
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
