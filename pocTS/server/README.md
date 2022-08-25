# Servers

1. Uncommnet the servers you want to run in `main.v`

   - `websocket`: start a websocket server on port `8081`.
   - `config`: start http server on port `5001` with endpoint `/profile_config` that returns your config from envars.
      ```bash
      # Required Environment Variables
      NET= # it can be one of (dev, qa, test, main)
      MNE= # your mnemonics for your tfchain twin
      SEC= # secret
      ```
   - `statics`: start http server on port `5000` serves build files of the chatbot from `./statics/public` directory.

2. Run the `main.v`
   ```bash
   v run main.v
   ```
