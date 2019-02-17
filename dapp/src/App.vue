<template>
  <v-app>
    <v-toolbar color="#25193E" extension-height="7" dark app flat clipped-left>
      <v-toolbar-side-icon></v-toolbar-side-icon>
      <v-toolbar-title>NuVault</v-toolbar-title>

      <v-spacer></v-spacer>

      <!-- <v-toolbar-items class="hidden-sm-and-down"> -->
        <v-btn flat>
          <v-avatar>
            <v-icon large>account_circle</v-icon>
          </v-avatar>
          {{this.account}}
        </v-btn>
      <!-- </v-toolbar-items> -->
      <v-progress-linear :active="isLoading" slot="extension" :indeterminate="true" class="ma-0"></v-progress-linear>
    </v-toolbar>

    <v-alert class="locked-alert" :value="typeof this.account == 'undefined'" type="error" transition="scale-transition">
      <div class="text-sm-center">Unlock wallet</div>
    </v-alert>

    <v-navigation-drawer app clipped>
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
      isLoading: false,
      web3js: null,
      account: null,
      network: null,
      selectedVault: null,
      addingVault: false,
      newVault: null,
      nuVaultContract: null,
      policyEncryptingKey: null,
      ipfs: new IPFS({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' }),
      hash: null,
      vaults: []
    }
  },
  methods: {
    chooseVault (vault) {
      this.selectedVault = vault
    },
    async syncIpfs () {
      this.isLoading = true

      // Call out to Enrico
      const body = JSON.stringify({
        message: JSON.stringify(this.vaults)
        // message: 'hello world'
      })
      console.log('body', body)
      const enricoRes = await fetch('http://localhost:5151/encrypt_message', {
        method: 'POST',
        body: body
      })
        .then((resp) => resp.json())
      console.log('enrico res', enricoRes)

      // Get Bob's keys
      const bobRes = await fetch('http://localhost:11151/public_keys').then((resp) => resp.json())
      console.log('bob res', bobRes)

      const aliceGrantRes = await fetch('http://localhost:8151/grant', {
        method: 'PUT',
        body: JSON.stringify({
          bob_signing_key: bobRes.result.bob_signing_key,
          bob_encrypting_key: bobRes.result.bob_encrypting_key,
          m: 1,
          n: 1,
          label: this.account,
          // label: 'the_label',
          expiration_time: '2019-02-19T12:56:26.976816'
        })
      }).then((resp) => resp.json())

      console.log('alice grant res', aliceGrantRes)

      const data = Buffer.from(JSON.stringify({
        policyEncryptingKey: this.policyEncryptingKey,
        aliceSigningKey: aliceGrantRes.result.alice_signing_key,
        enricoSignature: enricoRes.result.signature,
        vaults: enricoRes.result.message_kit
      }))

      this.ipfs.add(data, {}, async (err, ipfsHash) => {
        if (err) {
          console.error(err)
        } else {
          this.addingVault = false
          this.newVault = null

          if (this.hash !== ipfsHash[0].hash) {
            this.hash = ipfsHash[0].hash
            await this.nuVaultContract.methods.saveHash(ipfsHash[0].hash).send({ from: this.account })
            this.isLoading = false
          }
        }
      })
    },
    async addVault () {
      this.vaults.push({
        name: this.newVault,
        items: []
      })

      console.log('here', this.vaults.length)
      if (this.vaults.length === 1) {
        const res = await fetch(`http://localhost:8151/derive_policy_pubkey/${this.account}`, { method: 'POST' })
        // const res = await fetch('http://localhost:8151/derive_policy_pubkey/the_label', { method: 'POST' })
          .then((resp) => resp.json())
        this.policyEncryptingKey = res.result.policy_encrypting_key
      }
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
      this.ipfs.get(this.hash, async (err, files) => {
        if (err) {
          console.error(err)
        } else {
          const json = JSON.parse(files[0].content)
          console.log('ipfs json', json)
          this.vaults = json.vaults
          this.policyEncryptingKey = json.policyEncryptingKey

          const bobRes = await fetch('http://localhost:11151/retrieve', {
            method: 'POST',
            body: JSON.stringify({
              label: this.account,
              policy_encrypting_key: json.policyEncryptingKey,
              alice_signing_key: json.aliceSigningKey,
              datasource_signing_pubkey: json.enricoSignature,
              message_kit: json.vaults
            })
          }).then((resp) => resp.json())

          console.log('bobRes', bobRes)
          this.vaults = JSON.parse(Buffer.from(bobRes.result.plaintext[0], 'base64').toString('utf-8'))
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
