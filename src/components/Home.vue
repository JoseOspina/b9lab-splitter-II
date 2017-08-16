<template>
  <div class='hello'>
    <h1>Splitter App</h1>
  </div>
</template>

<script>
import { Splitter } from '@/web3-loader.js'

export default {
  name: 'home',
  data () {
    return {
      splitterInstance: null,
      aliceAddress: '',
      bobAddress: '',
      carolAddress: '',
      splitterBalance: 0,
      splitterAddressBalance: 0,
      aliceBalance: 0,
      bobBalance: 0,
      carolBalance: 0
    }
  },

  computed: {
  },

  methods: {
  },

  mounted () {
    Splitter.deployed().then((instance) => {
      this.splitterInstance = instance
    }).catch((err) => {
      console.log(err)
    })
  }
}
</script>

<!-- Add 'scoped' attribute to limit CSS to this component only -->
<style scoped>

</style>
