<template>
  <v-layout v-if="!editing" row>
    <v-flex xs12>
        <v-list subheader two-line>

          <v-list-tile>
            <v-flex sm12>
              <v-subheader>
                Vault: {{vault.name}}
              </v-subheader>
            </v-flex>
            <v-list-tile-action>
              <v-icon @click="editing = true">edit</v-icon>
            </v-list-tile-action>
          </v-list-tile>

          <template v-for="(key, index) in Object.keys(item.fields)">
            <v-list-tile :key="index" avatar>

              <v-flex sm12>
                <v-list-tile-content>
                  <v-list-tile-title v-html="key"></v-list-tile-title>
                  <v-list-tile-sub-title v-html="item.fields[key]"></v-list-tile-sub-title>
                </v-list-tile-content>
              </v-flex>
            </v-list-tile>
            <v-divider v-if="Object.keys(item.fields).length > index + 1" :key="`${index}-divider`"></v-divider>
          </template>
        </v-list>
    </v-flex>
  </v-layout>

  <v-layout v-else row>
    <v-flex xs12>
        <v-list>

          <v-list-tile>
            <v-flex sm12>
              <v-subheader>
                Vault: {{vault.name}}
              </v-subheader>
            </v-flex>
            <v-list-tile-action>
              <v-icon @click="addingField = true">add</v-icon>
            </v-list-tile-action>
          </v-list-tile>

          <template v-for="(key) in Object.keys(item.fields)">
            <v-flex :key="key" xs6>
              <v-text-field v-model="item.fields[key]" :label="key" ></v-text-field>
            </v-flex>
          </template>
          <v-flex v-if="addingField" sm6>
            <v-text-field v-model="addFieldKey" placeholder="key"></v-text-field>
            <v-text-field v-model="addFieldValue" placeholder="value"></v-text-field>
          </v-flex>
          <v-btn color="primary" @click="save">Done</v-btn>
        </v-list>
    </v-flex>
  </v-layout>
</template>

<script>
export default {
  name: 'VaultItem',
  props: {
    item: Object,
    vault: Object
  },
  data () {
    return {
      editing: false,
      addingField: false,
      addFieldKey: null,
      addFieldValue: null
    }
  },
  methods: {
    save () {
      if (this.addFieldKey && this.addFieldValue) {
        this.item.fields[this.addFieldKey] = this.addFieldValue
      }

      this.editing = false
    }
  }
}
</script>

<style scoped>

</style>
