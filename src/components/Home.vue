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
        <tr>
          <td>Sender</td>
          <td>{{ splitterSender.substring(2, 10) }}</td>
          <td>{{ senderBalance.toFixed(2) }}</td>
          <td>-</td>
        </tr>
        <tr>
          <td>Receiver 1 </td>
          <td>{{ receiver1Address.substring(2, 10) }}</td>
          <td>{{ receiver1Balance.toFixed(2) }}</td>
          <td>{{ receiver1BalanceInSplitter.toFixed(2) }}</td>
        </tr>
        <tr>
          <td>Receiver 2</td>
          <td>{{ receiver2Address.substring(2, 10) }}</td>
          <td>{{ receiver2Balance.toFixed(2) }}</td>
          <td>{{ receiver2BalanceInSplitter.toFixed(2) }}</td>
        </tr>
      </table>
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
    <div v-if="from === splitterSender" class="">
      <h3>You are the Sender of the splitter!</h3>
      <div class="w3-row-padding w3-margin-top">
        <div class="w3-col m8">
          <input class="w3-input" v-model="receiver1ToSet">
        </div>
        <div class="w3-col m4 ">
          <button @click="setReceiver1" class="w3-button w3-blue w3-round-large">Set Receiver 1</button>
        </div>
      </div>
      <div class="w3-row-padding w3-margin-top">
        <div class="w3-col m8">
          <input class="w3-input" v-model="receiver2ToSet">
        </div>
        <div class="w3-col m4 ">
          <button @click="setReceiver2" class="w3-button w3-blue w3-round-large">Set Receiver 2</button>
        </div>
      </div>
    </div>

    <div v-if="isReceiver1 || isReceiver2" class="">
      <h3>You are one of the receivers of the splitter, and you have {{ receiverBalanceInSplitter }} ether available!</h3>
      <div class="w3-row-padding w3-margin-top">
        <div class="w3-col s12 ">
          <button @click="withDrawReceiverFunds()" class="w3-button w3-blue w3-round-large">Get my funds!</button>
        </div>
      </div>
    </div>

    <div class="w3-row-padding w3-margin-top">
      <div class="w3-col m8">
        <input class="w3-input" type="number" v-model="valueToSend">
      </div>
      <div class="w3-col m4 ">
        <button @click="sendFunds()" class="w3-button w3-blue w3-round-large">Send To Splitter</button>
      </div>
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
      receiver1ToSet: '',
      receiver2ToSet: '',
      receiver1Address: '',
      receiver2Address: '',
      splitterBalance: 0,
      splitterAddressBalance: 0,
      senderBalance: 0,
      receiver1Balance: 0,
      receiver2Balance: 0,
      valueToSend: 0,
      receiver1BalanceInSplitter: 0,
      receiver2BalanceInSplitter: 0
    }
  },

  computed: {
    isReceiver1 () {
      return this.from === this.receiver1Address
    },
    isReceiver2 () {
      return this.from === this.receiver2Address
    },
    receiverBalanceInSplitter () {
      if (this.isReceiver1) {
        return this.receiver1BalanceInSplitter
      }

      if (this.isReceiver2) {
        return this.receiver2BalanceInSplitter
      }

      return 0
    }
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
    updateAll () {
      this.updateReceiver1()
      this.updateReceiver2()
      this.updateAllBalances()
    },
    updateReceiver1 () {
      this.splitterInstance.receiver1().then((receiver1) => {
        this.receiver1Address = receiver1
        this.updateBalanceOf(this.receiver1Address)
      })

      this.splitterInstance.receiver1Balance().then((balance) => {
        this.receiver1BalanceInSplitter = Number(web3.fromWei(balance))
      })
    },
    updateReceiver2 () {
      this.splitterInstance.receiver2().then((receiver2) => {
        this.receiver2Address = receiver2
        this.updateBalanceOf(this.receiver2Address)
      })

      this.splitterInstance.receiver2Balance().then((balance) => {
        this.receiver2BalanceInSplitter = Number(web3.fromWei(balance))
      })
    },
    updateAllBalances () {
      this.updateBalanceOf(this.splitterInstance.address)
      this.updateBalanceOf(this.splitterSender)
      this.updateBalanceOf(this.receiver1Address)
      this.updateBalanceOf(this.receiver2Address)
    },
    updateBalanceOf (address) {
      if (address === '0x0000000000000000000000000000000000000000') {
        return
      }
      web3.eth.getBalance(address, (err, balance) => {
        if (err) {
          console.log(err)
        } else {
          var balanceInEth = Number(web3.fromWei(balance))
          switch (address) {
            case this.splitterInstance.address:
              this.splitterAddressBalance = balanceInEth
              break

            case this.splitterSender:
              this.senderBalance = balanceInEth
              break

            case this.receiver1Address:
              this.receiver1Balance = balanceInEth
              break

            case this.receiver2Address:
              this.receiver2Balance = balanceInEth
              break
          }
        }
      })
    },
    sendFunds () {
      web3.eth.sendTransaction({
        from: this.from,
        to: this.splitterInstance.address,
        value: web3.toWei(this.valueToSend, 'ether')
      }, (err, txn) => {
        if (err) {
          console.log(err)
        }
        this.updateAll()
      })
    },
    withDrawReceiverFunds () {
      this.splitterInstance.getMyFunds({ from: this.from }).then(() => {
        this.updateAll()
      })
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

button {
  width: 100%;
}

</style>
