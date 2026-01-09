## **store Module**

In scriptr.io, data and digital assets are persisted in a database container called a store. Individual data items persisted in a store are called [documents](https://www.scriptr.io/documentation#documentation-document).

All documents saved in a store are secured with store level ACLs, allowing developers to decide which devices, users and/or groups are permitted to save, query, delete documents or retrieve attachments from documents in that store.

The store module allows you to manage stores by offering the below functions. Note that free accounts can only have two stores.

When you create a scriptr.io account, a store called "DefaultStore" is automatically created for you. It is strongly advised to not delete the "DefaultStore" as you will lose all your triggers for the scheduled scripts and will no longer be able to schedule scripts.

**create**

Creates a new store along with its ACL. Throws the "DUPLICATE_STORE_NAME" exception if the store already exists.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the store name which is a unique identifier. |
| options | JSON object containing the store's ACL and a full text search flag. Optional. |

**Return value:** A JSON object containing the store name and its properties. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The options object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| acl | JSON object containing the access control list of the store determining who can save, delete, query or get attachments from its documents. Optional, defaults to nobody. |
| isSearchable | Boolean stating whether or not the created store will be searchable when using the full text search query option. A store can only be set to be searchable upon creation. Optional, defaults to false. |

The acl object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| saveDocumentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts saving documents in the store. It defaults to nobody. |
| deleteDocumentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts document deletion from the store. It defaults to nobody. |
| getAttachmentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts retrieval of file attachments from documents in the store. It defaults to nobody. |
| queryACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts access to queries on the store. It defaults to nobody. |

For each acl property above the value could be any of the following:

- A single value of type string if the ACL consists only of one device, user or group.
- An array of strings representing all the devices, users and groups in this ACL.
- A JSON object representing which values should be appended or deleted upon update (e.g. _"saveDocumentACL": {"append":\["admins", "editors"\], "delete":\["nobody"\]}_). This JSON object can have the following two properties:  
  - "**append**": the value of the "append" key should be a string or an array containing the values to be added to the existing ACL.
  - "**delete**": the value of the "delete" key should be a string or an array containing the values to be deleted from the existing ACL.

**Example**
```
1. **var** stores = **require**("store");
2. // Create the "myStore" store with the following ACLs
3. stores.create("myStore", {
4.     "acl" : {
5.         "saveDocumentACL" : "deviceA",
6.         "deleteDocumentACL" : \["deviceA", "group:firstFloor"\],
7.         "queryACL" : "deviceB",
8.         "getAttachmentACL" : "deviceB"
9.     },
10.     "isStoreSearchable" : "true"
11. });
```
**update**

Updates a store; throws the "STORE_NOT_FOUND" exception if the store does not exist. The update function has the same signature as the create function; however, it does not accept the option's isStoreSearchable parameter.

**Example**
```
1. **var** stores = **require**("store");
2. // Updates the deleteDocumentACL of the store "myStore". Note that the other ACLs will remain untouched if you don't pass them during an update.
3. **return** stores.update("myStore", {
4.     "deleteDocumentACL" : {
5.         "append" : "deviceB",
6.         "delete" : \["deviceA", "group:firstFloor"\]
7.     }
8. });
```
**delete**

Deletes a store by name. Deleting a store is a background job and might require some time, the store would be disabled meanwhile. Once done, all the data and digital assets persisted in that store will be deleted.

| **Parameter** | **Description** |
| --- | --- |
| **name** | String representing the name of the store to be deleted. |

**Return value:** no specific result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**
```
1. **var** stores = **require**("store");

3. // Delete the store with name "myStore"
4. **return** stores.**delete**("myStore");
```
**get**

Retrieves a specific store by name.

| **Parameter** | **Description** |
| --- | --- |
| **name** | String representing the name of the store to be retrieved. |

**Return value:** JSON object containing the store name and its properties. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Sample**
```
1. {
2.     "metadata" : {
3.         "status" : "success"
4.     },
5.     "result" : {
6.         "isStoreSearchable": **true**,
7.         "saveDocumentACL" : \[
8.             "deviceA"
9.         \],
10.         "store" : "myStore",
11.         "deleteDocumentACL" : \[
12.             "deviceA",
13.             "group:firstFloor"
14.         \],
15.         "getAttachmentACL" : \[
16.             "deviceB"
17.         \],
18.         "queryACL" : \[
19.             "deviceB"
20.         \]
21.     }
22. }
```
**list**

Retrieves all available stores.

**Return value:** JSON object containing the array of the store names. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Sample**
```
1. {
2.     "result" : {
3.         "stores" : \[{
4.                 "name" : "DefaultStore"
5.             }, {
6.                 "name" : "myStore"
7.             }
8.         \]
9.     },
10.     "metadata" : {
11.         "status" : "success"
12.     }
13. }
```