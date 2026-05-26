/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3098668462")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text122901928",
    "max": 0,
    "min": 0,
    "name": "creole",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text3026797935",
    "max": 0,
    "min": 0,
    "name": "translation",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text2284106510",
    "max": 0,
    "min": 0,
    "name": "explanation",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "exceptDomains": null,
    "help": "",
    "hidden": false,
    "id": "url2593671949",
    "name": "audio_url",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "url"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3098668462")

  // remove field
  collection.fields.removeById("text122901928")

  // remove field
  collection.fields.removeById("text3026797935")

  // remove field
  collection.fields.removeById("text2284106510")

  // remove field
  collection.fields.removeById("url2593671949")

  return app.save(collection)
})
