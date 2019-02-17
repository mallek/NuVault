<template>
  <v-container>
    <v-layout row>
      <v-flex xs4>
        <Vault v-if="vault" :vault="vault" v-on:item-selected="selectItem" v-on:vault-changed="vaultChanged"></Vault>
      </v-flex>
      <v-flex xs1>
        <v-spacer></v-spacer>
      </v-flex>
      <v-flex xs6>
        <VaultItem v-if="vaultItem" :item="vaultItem" :vault="vault" v-on:vault-item-changed="vaultItemChanged"></VaultItem>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
import Vault from './Vault'
import VaultItem from './VaultItem'

export default {
  name: 'Home',
  components: { Vault, VaultItem },
  props: {
    vault: Object
  },
  data () {
    return {
      vaultItem: null
    }
  },
  methods: {
    selectItem (item) {
      this.vaultItem = item
    },
    vaultChanged () {
      this.$emit('vault-changed')
    },
    vaultItemChanged () {
      this.$emit('vault-item-changed')
    }
  }
}
</script>

<style scoped>
</style>
