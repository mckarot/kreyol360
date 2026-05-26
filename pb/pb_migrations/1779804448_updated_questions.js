/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4009210445")

  // add field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": true,
    "collectionId": "pbc_93315167",
    "help": "",
    "hidden": false,
    "id": "relation2235355509",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "quiz_id",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text1701136936",
    "max": 0,
    "min": 0,
    "name": "question_text",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "json3493198471",
    "maxSize": 0,
    "name": "options",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "help": "",
    "hidden": false,
    "id": "number3564123840",
    "max": null,
    "min": null,
    "name": "correct_option_index",
    "onlyInt": false,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  // add field
  collection.fields.addAt(5, new Field({
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

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4009210445")

  // remove field
  collection.fields.removeById("relation2235355509")

  // remove field
  collection.fields.removeById("text1701136936")

  // remove field
  collection.fields.removeById("json3493198471")

  // remove field
  collection.fields.removeById("number3564123840")

  // remove field
  collection.fields.removeById("text2284106510")

  return app.save(collection)
})
