<template>
  <div v-if="splitterInstance" class="w3-container">
    <h1>Splitter App</h1>
    <h2>Data</h2>
    <div class="w3-row">
      <table class="w3-table w3-striped w3-bordered w3-centered">
        <tr>
          <th>Data</th>
          <th>Address</th>
          <th>Balance In Chain</th>
          <th>Balance in Splitter</th>
        </tr>
        <tr>
          <td>Contract</td>
          <td>{{ splitterInstance.address.substring(2, 10) }}</td>
          <td>{{ splitterAddressBalance.toFixed(2) }}</td>
          <td>-</td>
        </tr>
        <tr v-for="account in accounts">
          <td>User</td>
          <td>{{ account.address.substring(2, 10) }}</td>
          <td>{{ account.balance.toFixed(2) }}</td>
          <td>{{ account.balanceInSplitter.toFixed(2) }}</td>
        </tr>
      </table>
    </div>

    <br>
    <h2>Interact</h2>
    <div class="w3-row">
      <label class="w3-left"><b>from:</b></label>
      <select class="w3-input" v-model="from">
        <option v-for="account in accounts">
          {{ account.address }}
        </option>
      </select>
    </div>
    <div class="w3-row">
      <div class="w3-margin-top">
        <label class="w3-left"><b>to:</b></label>
        <select class="w3-input" v-model="receiver1">
          <option v-for="account in accounts">
            {{ account.address }}
          </option>
        </select>
      </div>
      <div class="w3-margin-top">
        <label class="w3-left"><b>and:</b></label>
        <select class="w3-input" v-model="receiver2">
          <option v-for="account in accounts">
            {{ account.address }}
          </option>
        </select>
      </div>
    </div>

    <div class="w3-row w3-margin-top">
      <div class="w3-col s8">
        <input class="w3-input" type="number" v-model="valueToSend">
      </div>
      <div class="w3-col s4 ">
        <button @click="sendFunds()" class="w3-button w3-blue w3-round-large">Send funds</button>
      </div>
    </div>

    <div class="w3-row w3-margin-top">
      <button @click="withdrawFunds()" class="w3-button w3-blue w3-round-large">Get my funds!</button>
    </div>

    <br>
    <h2>Log</h2>
    <div class="w3-row">
      <h4 v-if="events.length === 0">(empty)</h4>
      <ul class="w3-ul w3-card-2">
        <li v-for="event in events">{{ event }}</li>
      </ul>
    </div>

  </div>
</template>

<script>
import { Splitter, web3 } from '@/web3-loader.js'

export default {
  name: 'home',
  data () {
    return {
      splitterInstance: null,
      accounts: [],
      from: '',
      receiver1: '',
      receiver2: '',
      splitterAddressBalance: 0,
      valueToSend: 0,
      events: []
    }
  },

  computed: {
  },

  methods: {

    updateAll () {
      web3.eth.getAccountsPromise().then((accounts) => {
        this.accounts = []
        for (var ix in accounts) {
          this.accounts.push({
            address: accounts[ix],
            balance: 0,
            balanceInSplitter: 0
          })
        }

        /* correct way to loop with promises it to use recursion */
        const getBalances = (ix) => {
          web3.eth.getBalancePromise(this.accounts[ix].address).then((balance) => {
            this.accounts[ix].balance = Number(web3.fromWei(balance))
            return this.splitterInstance.getBalanceOf(this.accounts[ix].address, { from: this.from })
          }).then((balance) => {
            this.accounts[ix].balanceInSplitter = Number(web3.fromWei(balance))
            if (ix < this.accounts.length - 1) {
              getBalances(ix + 1)
            }
          })
        }

        getBalances(0)
      })
    },
    sendFunds () {
      this.splitterInstance.split(this.receiver1, this.receiver2, { from: this.from, value: web3.toWei(this.valueToSend, 'ether') })
      .then((success) => {
        this.updateAll()
      })
    },
    withdrawFunds () {
      this.splitterInstance.getMyFunds({ from: this.from }).then(() => {
        this.updateAll()
      })
    }
  },

  mounted () {
    Splitter.deployed().then((instance) => {
      this.splitterInstance = instance
      this.updateAll()

      /* check events */
      this.splitterInstance.LogFundsReceived({}, { fromBlock: 0 })
      .watch((err, event) => {
        if (err) {
          console.log(err)
        }
        this.events.push(Number(web3.fromWei(event.args.amount)) + ' ether sent by ' + event.args.sender + ' to ' + event.args.receiver1 + ' and ' + event.args.receiver2)
      })

      this.splitterInstance.LogFundsWithdrawn({}, { fromBlock: 0 })
      .watch((err, event) => {
        if (err) {
          console.log(err)
        }
        this.events.push(Number(web3.fromWei(event.args.amount)) + ' ether withdrawn by ' + event.args.receiver)
      })
    })
  }
}
</script>

<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style scoped>

button {
  width: 100%;
}

</style>
