import Vue from 'vue'
import Vuex from 'vuex'

import web3data from './modules/web3data'

Vue.use(Vuex)

export const store = new Vuex.Store({
  state: {},

  modules: {
    web3data
  }
})
