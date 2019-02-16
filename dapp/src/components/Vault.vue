<template>
  <v-layout row>
    <v-flex xs12>
        <v-list subheader two-line >

          <v-list-tile>
            <v-flex sm12>
              <v-list-tile-content>
                <v-text-field v-model="newItem" v-if="addingItem" placeholder="New Item" @keyup.enter="addItem" @keyup.escape="addingItem = false"></v-text-field>
              </v-list-tile-content>
            </v-flex>
            <v-list-tile-action>
              <v-icon @click="addingItem = true">add</v-icon>
            </v-list-tile-action>
          </v-list-tile>

          <template v-for="(vaultItem, index) in vault.items">

            <v-list-tile :key="index" @click="chooseItem(vaultItem)" :class="{ active: selectedItem && selectedItem.name === vaultItem.name }" avatar>

              <v-flex sm12>
                <v-list-tile-content>
                  <v-list-tile-title v-html="vaultItem.name"></v-list-tile-title>
                  <v-list-tile-sub-title v-html="vaultItem.username"></v-list-tile-sub-title>
                </v-list-tile-content>
              </v-flex>

              <v-list-tile-action >
                <v-icon>edit</v-icon>
              </v-list-tile-action>
            </v-list-tile>

            <v-divider v-if="vault.items.length > index + 1" :key="`${index}-divider`"></v-divider>
          </template>
        </v-list>
    </v-flex>
  </v-layout>
</template>

<script>
import VaultItem from './VaultItem'

export default {
  name: 'Vault',
  components: { VaultItem },
  props: {
    vault: Object,
    vaultItem: Object
  },
  data () {
    return {
      selectedItem: null,
      newItem: null,
      addingItem: null
    }
  },
  methods: {
    chooseItem (item) {
      this.selectedItem = item
      this.$emit('item-selected', item)
    },
    addItem () {
      this.vault.items.push({
        name: this.newItem,
        fields: []
      })
      this.addingItem = false
      this.newItem = null
    }
  }
}
</script>

<style scoped>
.active {
  background-color: #fc5090;
}
</style>
