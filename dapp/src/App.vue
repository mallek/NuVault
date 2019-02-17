<template>
  <v-app>
    <v-toolbar color="#25193E" dark app flat>
      <v-toolbar-side-icon></v-toolbar-side-icon>
      <v-toolbar-title>NuVault</v-toolbar-title>

      <v-spacer></v-spacer>

      <v-toolbar-items class="hidden-sm-and-down">
        <v-btn flat>
          <v-avatar>
            <v-icon>account_circle</v-icon>
          </v-avatar>
          {{this.account}}
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-alert class="locked-alert" :value="typeof this.account == 'undefined'" type="error" transition="scale-transition">
      <div class="text-sm-center">Unlock wallet</div>
    </v-alert>

    <v-navigation-drawer app>
      <v-layout row>
        <v-flex xs12>
            <v-list subheader>
              <v-list-tile v-if="!addingVault">
                <v-list-tile-action>
                  <v-icon>lock</v-icon>
                </v-list-tile-action>
                <v-list-tile-title>Vaults</v-list-tile-title>
                <v-list-tile-action>
                  <v-icon @click="addingVault = true">add</v-icon>
                </v-list-tile-action>
              </v-list-tile>

              <v-list-tile v-else>
                <v-flex sm12>
                  <v-list-tile-content>
                    <v-text-field v-model="newVault" placeholder="New Vault" @keyup.enter="addVault" @keyup.escape="addingVault = false"></v-text-field>
                  </v-list-tile-content>
                </v-flex>
              </v-list-tile>

              <v-divider></v-divider>

              <template v-for="(vault, index) in vaults">
                <v-list-tile :key="index" avatar @click="chooseVault(vault)" :class="{ active: selectedVault && selectedVault.name === vault.name }">
                  <v-flex sm12>
                    <v-list-tile-content>
                      <v-list-tile-title v-html="vault.name"></v-list-tile-title>
                    </v-list-tile-content>
                  </v-flex>
                  <v-list-tile-action >
                    <v-icon>edit</v-icon>
                  </v-list-tile-action>
                </v-list-tile>
                <v-divider v-if="vaults.length > index + 1" :key="`${index}-divider`"></v-divider>
              </template>
            </v-list>
        </v-flex>
      </v-layout>
    </v-navigation-drawer>

    <v-content>
      <v-container fluid>
        <router-view v-on:vault-item-changed="syncIpfs" :vault="selectedVault"></router-view>
      </v-container>
    </v-content>
  </v-app>
</template>

<script>
import Web3 from 'Web3'

const IPFS = require('ipfs-api')
const nuVault = require('../../build/contracts/NuVault')
const wait = (condition, delay = 100, timeout = 5000, elapsed = 0) => {
  return new Promise((resolve, reject) => {
    const loop = () => {
      setTimeout(() => {
        if (condition() === true) {
          return resolve()
        } else if (elapsed >= timeout) {
          return reject(new Error(`Timeout after ${timeout} ms.`))
        } else {
          loop()
        }
      }, delay)
    }
    loop()
  })
}

// #fc5090 light pink
// #fb2a78 dark pink
// #120724 white
// #25193E purple
// ipfs hash QmXLrUrmmpZPbRcdVYxpw94LCpTKqJ7Bg8tnd2L26pqY7e

export default {
  name: 'App',
  data () {
    return {
      web3js: null,
      account: null,
      network: null,
      selectedVault: null,
      addingVault: false,
      newVault: null,
      nuVaultContract: null,
      ipfs: new IPFS({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }),
      hash: null,
      vaults: []
    }
  },
  methods: {
    chooseVault (vault) {
      this.selectedVault = vault
    },
    syncIpfs () {
      const data = Buffer.from(JSON.stringify(this.vaults))
      this.ipfs.add(data, {}, async (err, ipfsHash) => {
        if (err) {
          console.error(err)
        } else {
          this.addingVault = false
          this.newVault = null

          if (this.hash !== ipfsHash[0].hash) {
            this.hash = ipfsHash[0].hash
            await this.nuVaultContract.methods.saveHash(ipfsHash[0].hash).send({ from: this.account })
          }
        }
      })
    },
    addVault () {
      this.vaults.push({
        name: this.newVault,
        items: []
      })
    }
  },
  async mounted () {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.ethereum !== 'undefined' || window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this.web3js = new Web3(window['etherem'] || window.web3.currentProvider)
      this.web3js.currentProvider.enable()
    } else {
      // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
      this.web3js = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
    }

    // Pole for account changes
    setInterval(async () => {
      const accounts = await this.web3js.eth.getAccounts()
      this.account = (this.account !== accounts[0]) ? accounts[0] : this.account
    }, 100)

    this.network = await this.web3js.eth.net.getId()

    switch (this.network) {
      case 1:
        console.info('This is mainnet')
        break
      case 2:
        console.info('This is the deprecated Morden test network.')
        break
      case 3:
        console.info('This is the ropsten test network.')
        break
      case 4:
        console.info('This is the Rinkeby test network.')
        break
      case 42:
        console.info('This is the Kovan test network.')
        break
      case 133337:
        console.info('This is the local test network.')
        break
      default:
        console.info('This is an unknown network.')
    }

    this.nuVaultContract = new this.web3js.eth.Contract(nuVault.abi, nuVault.networks['133337'].address)

    await wait(() => this.account !== null)
    this.hash = await this.nuVaultContract.methods.getHash().call({ from: this.account })

    if (this.hash) {
      this.ipfs.get(this.hash, (err, files) => {
        if (err) {
          console.error(err)
        } else {
          this.vaults = JSON.parse(files[0].content)
        }
      })
    }
  }
}
</script>

<style scoped>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  /* color: #2c3e50; */
  margin-top: 60px;
  background: white;
}
.locked-alert {
  margin: 0;
  border: none;
}
.active {
  background-color: #fc5090;
}
</style>
