# alice
`nucypher alice run --dev --network eth_denver --teacher-uri 18.217.28.35:9151`

Alice Signing Key 03c9243db3641c85d293b8a141dfaaddb597a851c4e68b2f36539ec416d5774ae8

`/POST http://localhost:8151/derive_policy_pubkey`
```
{
	"label":"RXRoZGVudmVyMjAxOQ=="
}
{
    "result": {"policy_encrypting_pubkey": "03ccd46f3864a66f430b3d3c7f72f31bd6c755236395fcdd4896c7664c1b602e06"}
}
```

`/PUT http://localhost:8151/grant`
```
{
	"bob_signing_key": "02a85ab0f42937f78e2eedbc900da352753893301017eaf00432fbe064b8e6b417",
    "bob_encrypting_key": "033b55b5f0059ee065a2fe2542863016db3f236c1c7cad88193b41c9c5f1eff355",
    "m": 1,
    "n": 1,
    "label": "RXRoZGVudmVyMjAxOQ==",
    "expiration_time": "2019-02-19T12:56:26.976816"
}
{
    "result": {"treasure_map": "R0QR+jGvVaglO0xdDqEUZcbiDX8cGO50YxTZe57QwmnP5Vbyk9sASqJBSevwkxEn8r1GfF6jJob1wtI/zSwORcfOkfOI1hnJ6ot5B6mvDC0FCUJzTfM/qPNN6UWHUrJ2AAABHAP4T3paWkxUuIm85/L5tcpqOX1FsyaSTE5FdlUVCwQwTgL5hWSonZ/DvMvCua4RuXId0lNezmuKfJx/i2YqbyzPP5Y4uZ8xNNgmMvhYDHi3aPwrBKGTS0M79wtSkREg8t5NA8kkPbNkHIXSk7ihQd+q3bWXqFHE5osvNlOexBbVd0roWbXh+inwo9fmvlNq9kd7zKdJSQTb4ynd6q5LWOAFkh39VqTbNeqJ+hVXm2jvi6sv6pwW7YlMSrprEVe3ujvCqS1xh6bGsFZ9qL49uRdvX1obyWlo2lg4zl1wrsF8vBe2+kdCmfcxSsbJ1gM+S18aH2bLkyEWxrCLe8XJMklDHkJkCTNu7qsMfJ9MhHUO0V3jnKjQS/8A1aW3", "policy_encrypting_pubkey": "03ccd46f3864a66f430b3d3c7f72f31bd6c755236395fcdd4896c7664c1b602e06", "alice_signing_pubkey": "03c9243db3641c85d293b8a141dfaaddb597a851c4e68b2f36539ec416d5774ae8", "label": "RXRoZGVudmVyMjAxOQ=="}
}
```

# bob
`nucypher bob run --dev --network eth_denver --teacher-uri 18.217.28.35:9151`

Bob Signing Key 02a85ab0f42937f78e2eedbc900da352753893301017eaf00432fbe064b8e6b417
Bob Encrypting Key 033b55b5f0059ee065a2fe2542863016db3f236c1c7cad88193b41c9c5f1eff355

`/POST http://localhost:11151/retrieve`
```
{
	"label": "RXRoZGVudmVyMjAxOQ==",
	"policy_encrypting_pubkey": "03ccd46f3864a66f430b3d3c7f72f31bd6c755236395fcdd4896c7664c1b602e06",
  "alice_signing_pubkey": "03c9243db3641c85d293b8a141dfaaddb597a851c4e68b2f36539ec416d5774ae8",
  "datasource_signing_pubkey": "DN/io+mSnt0LSz5Ht6hXH0SkWfNH5SlZnd0OQ4Q4/P9x4Nk8omR6ExyvKuYphHUy23RtZAwJM50rrjByFo1zcA==",
  "message_kit": "A2pjbLq536lVwnZlbxztzVO1wkV+X4R3/FHzJjvi8LDEA7OmlMDR9kNTUHSubEmMi2+gBE1DI7snxEFqBHjr8TNotTPnrXeFuSFTUlbYK2QiL4pS6R9YI4vwMj/x+BbnNEACXXmRZTiWOBUtAOei693vR2MdUPnGIp7V6BDBrWbw7nJuVMtuWwB+nHQ1wkhMX33f90V+SlDZYltjRyUSj3gFfpxFxI0WOWMK3FfhZ5Z3d03mcEbiZwWpDwf0XI5dlnWApQC6WlbNNp//B4cGOno6++yDA1ZZw5/PbDYeJ7Sz50RLPhqTpT3qub3kib4+r5NOWX/yv0YhmGRj/sNcInsmVZTpyOjHVVWi3EblEJFdS2k="
}
{
    "result":
    {"plaintext":["dGhlIHF1aWNrIGJyb3duIGZveCBqdW1wZWQgb3ZlciB0aGUgbGF6eSBkb2c="]
    }
}
```

# enrico
`nucypher enrico run --policy-encrypting-key 03ccd46f3864a66f430b3d3c7f72f31bd6c755236395fcdd4896c7664c1b602e06`

Enrico Signing Key 025d799165389638152d00e7a2ebddef47631d50f9c6229ed5e810c1ad66f0ee72

`/POST http://localhost:5151/encrypt_message`
```
{
	"message":"dGhlIHF1aWNrIGJyb3duIGZveCBqdW1wZWQgb3ZlciB0aGUgbGF6eSBkb2c="
}
{
    "result":
    {
    "message_kit": "A2pjbLq536lVwnZlbxztzVO1wkV+X4R3/FHzJjvi8LDEA7OmlMDR9kNTUHSubEmMi2+gBE1DI7snxEFqBHjr8TNotTPnrXeFuSFTUlbYK2QiL4pS6R9YI4vwMj/x+BbnNEACXXmRZTiWOBUtAOei693vR2MdUPnGIp7V6BDBrWbw7nJuVMtuWwB+nHQ1wkhMX33f90V+SlDZYltjRyUSj3gFfpxFxI0WOWMK3FfhZ5Z3d03mcEbiZwWpDwf0XI5dlnWApQC6WlbNNp//B4cGOno6++yDA1ZZw5/PbDYeJ7Sz50RLPhqTpT3qub3kib4+r5NOWX/yv0YhmGRj/sNcInsmVZTpyOjHVVWi3EblEJFdS2k=",
    "signature": "DN/io+mSnt0LSz5Ht6hXH0SkWfNH5SlZnd0OQ4Q4/P9x4Nk8omR6ExyvKuYphHUy23RtZAwJM50rrjByFo1zcA=="
    }
}
```
