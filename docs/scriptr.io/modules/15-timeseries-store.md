# Timeseries-Store module

The ts-store module allows a user to manager stores under their account

The module provides the following methods:

- [createDefault](#Timeseries-Storemodule-createDefault)
- [create](#Timeseries-Storemodule-create)
- [list](#Timeseries-Storemodule-list)
- [clear](#Timeseries-Storemodule-clear)
- [delete](#Timeseries-Storemodule-delete)
- [describe](#Timeseries-Storemodule-describe)
- [update](#Timeseries-Storemodule-update)

# createDefault

Creates a store called "DefaultStore" under the caller's account, where logs can be added, queried, and/or deleted.

Example:
```
var timeseries = require("ts-store");

return timeseries.createDefault();
```
Response:
```
{
    "metadata": {

            "status": "success"

    }
}
```
**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Calling createDefault another time**

{

"metadata": {

"status": "failure",

"statusCode": 400,

"errorCode": "MAX_STORES_EXCEEDED",

"errorDetail": "You cannot create more than one store."

}

}

# create

To be done in phase 2

Note: The name of a field cannot be longer than 63 characters in length.

Creates a store under the caller's account, where logs can be added, queried, and/or deleted.

| **Parameter** | **Description**                                                                                                                                                                            | **Required** | **Default** |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------ | ----------------- |
| storeName           | String representing a store name.`<br><br>`Store name must start with a character, can contain only alpha-numeric characters and underscore, and can be between 3 and 32 characters in length. | Yes                |                   |
| fields              | A JSON array of JSON objects. Each JSON object represents a field, and contains field attributes represented in the table below.                                                                 | Yes                |                   |
| options             | A JSON object containing options of the store                                                                                                                                                    | Yes                |                   |

"fields" object:

| **Attribute name** | **Description**                                                  | **Type** | **Required** | **Default** |
| ------------------------ | ---------------------------------------------------------------------- | -------------- | ------------------ | ----------------- |
| name                     | String representing the name of the field                              | String         | Yes                |                   |
| datatype                 | String representing the datatype of the field                          | String         | Yes                |                   |
| nullable                 | Boolean specifying whether the field can be NULL (true) or not (false) | Boolean        | No                 | true              |

"options" object:

| **Option**    | **Description**                                                                                                                                                | **Type** | **Required** | **Default** |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------ | ----------------- |
| hypertableFieldName | The name of the field containing a timestamp, date, integer, or any value that can increment.                                                                        | String         | No                 |                   |
| constraints         | A string containing constraints to be created on the created store.`<br><br>`Note that any unique constraint must include the "timestamp" field in the constraint. | String         | No                 |                   |

Example:

var timeseriesStore = require("ts-store");

// The following would create:

// id int NOT NULL

// long DOUBLE PRECISION NOT NULL

// description text NULL

var fields = \[

{

"name": "id",

"datatype": "int",

"nullable": false

},

{

"name": "long",

"datatype": "DOUBLE PRECISION",

"nullable": false

},

{

"name": "description",

"datatype": "text"

},

{

"name": "timestamp",

"datatype": "timestamp without time zone"

}

\]

var options = {

"hypertableFieldName": "timestamp",

"constraints": "UNIQUE(id, timestamp), UNIQUE(long, timestamp)"

}

return timeseriesStore.create("TestStore1", fields, options);

Response:

{

"metadata": {

"status": "success"

}

}

# list

Lists all the account's timeseries stores

No allowed parameters

Example:

var timeseriesStore = require("ts-store");

return timeseriesStore.list();

Response:

{

"result": {

"stores": \[

{

"name": "TestStore1"

},

{

"name": "TestStore2"

}

\]

},

"metadata": {

"status": "success"

}

}

# clear

Deletes all records under the timeseries store specified as a parameter

| **Parameter** | **Description**                                         | **Required** | **Default** |
| ------------------- | ------------------------------------------------------------- | ------------------ | ----------------- |
| storeName           | String representing the name of an existing timeseries store. | Yes                |                   |

Example:

var timeseriesStore = require("ts-store");

return timeseriesStore.clear("TestStore1");

Response:

{

"metadata": {

"status": "success"

}

}

# delete

Deletes the timeseries store specified as a parameter

| **Parameter** | **Description**                                         | **Required** | **Default** |
| ------------------- | ------------------------------------------------------------- | ------------------ | ----------------- |
| storeName           | String representing the name of an existing timeseries store. | Yes                |                   |

Example:

var timeseriesStore = require("ts-store");

return timeseriesStore.delete("TestStore1");

Response:

{

"metadata": {

"status": "success"

}

}

# describe

To be done in phase 4

# update

To be done in phase 4
