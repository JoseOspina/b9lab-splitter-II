<template>
  <div v-if="splitterInstance" class="w3-container">
    <h1>Splitter App</h1>
    <h2>Data</h2>
    <div class="w3-row">
      <div class="w3-table w3-striped w3-bordered w3-centered">
        <tr>
          <th>Data</th>
          <th>Value</th>
        </tr>
        <tr>
          <td>Address</td>
          <td>{{ splitterInstance.address }}</td>
        </tr>
        <tr>
          <td>Sender</td>
          <td>{{ splitterSender }}</td>
        </tr>
        <tr>
          <td>Receiver 1</td>
          <td>{{ receiver1Address }}</td>
        </tr>
        <tr>
          <td>Receiver 2</td>
          <td>{{ receiver2Address }}</td>
        </tr>
      </div>
    </div>

    <br>
    <h2>Interact</h2>
    <div class="w3-row">
      <label class="w3-left"><b>from:</b></label>
      <select class="w3-input" v-model="from">
        <option v-for="account in accounts">
          {{ account }}
        </option>
      </select>
    </div>
    <div class="w3-row w3-margin-top">
      <input class="w3-col m8 w3-input" v-model="receiver1ToSet">
      <button @click="setReceiver1" class="w3-col m4 w3-button w3-blue w3-round-large">Set Receiver 1</button>
    </div>
    <div class="w3-row w3-margin-top">
      <input class="w3-col m8 w3-input" v-model="receiver2ToSet">
      <button @click="setReceiver2" class="w3-col m4 w3-button w3-blue w3-round-large">Set Receiver 2</button>
    </div>

    <br>
  </div>
</template>

<script>
import { Splitter, web3 } from '@/web3-loader.js'

export default {
  name: 'home',
  data () {
    return {
      splitterInstance: null,
      splitterSender: '',
      accounts: [],
      from: '',
      senderAddress: '',
      receiver1ToSet: '',
      receiver2ToSet: '',
      receiver1Address: '',
      receiver2Address: '',
      splitterBalance: 0,
      splitterAddressBalance: 0,
      senderBalance: 0,
      receiver1Balance: 0,
      receiver2Balance: 0
    }
  },

  computed: {
  },

  methods: {
    setReceiver1 () {
      var ok = true
      if (this.receiver1ToSet === '') {
        ok = false
      }
      if (ok) {
        this.splitterInstance.setReceiver1(this.receiver1ToSet, { from: this.from }).then((res) => {
          return this.updateReceiver1()
        })
      }
    },
    setReceiver2 () {
      var ok = true
      if (this.receiver2ToSet === '') {
        ok = false
      }
      if (ok) {
        this.splitterInstance.setReceiver2(this.receiver2ToSet, { from: this.from }).then((res) => {
          return this.updateReceiver2()
        })
      }
    },
    updateReceiver1 () {
      this.splitterInstance.receiver1().then((receiver1) => {
        this.receiver1Address = receiver1
      })
    },
    updateReceiver2 () {
      this.splitterInstance.receiver2().then((receiver2) => {
        this.receiver2Address = receiver2
      })
    },
    updateAll () {
      this.updateReceiver1()
      this.updateReceiver2()
    }
  },

  mounted () {
    Splitter.deployed().then((instance) => {
      this.splitterInstance = instance
      return this.splitterInstance.sender()
    })
    .then((sender) => {
      this.splitterSender = sender
      this.updateAll()
    })
    .catch((err) => {
      console.log(err)
    })

    web3.eth.getAccountsPromise().then((accounts) => {
      this.accounts = accounts
      this.from = accounts[0]
    })
  }
}
</script>

<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style scoped>

</style>
