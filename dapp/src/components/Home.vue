<template>
  <v-container>
    <v-layout row>
      <v-flex xs4>
        <Vault v-if="vault" :vault="vault" v-on:item-selected="selectItem"></Vault>
      </v-flex>
      <v-flex xs1>
        <v-spacer></v-spacer>
      </v-flex>
      <v-flex xs6>
        <VaultItem v-if="vaultItem" :item="vaultItem" :vault="vault"></VaultItem>
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
    }
  }
}
</script>

<style scoped>
</style>
