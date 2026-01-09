## **device Module**

The device module allows you to create and manage devices. Each device is associated to the below schema that provides the basic device fields and ACLs. You can modify the schema to meet your needs by [updating](https://www.scriptr.io/documentation#documentation-schema-update) the apsdb_device system [schema](https://www.scriptr.io/documentation#documentation-schemamodule).

```
1. <!--
2. This is the default device schema. Feel free to modify it to your liking.
3. This schema follows all rules and restrictions as all other schemas, as do, the documents (devices) created out of it.
4. However, it imposes the following restrictions of its own:
5. 1\. The seven default fields (groups, name, id,token, password, locale and isSuspended) are required.
6. 2\. This schema cannot be deleted.
7. Additionally, since this schema is used for device management, the following ACLs are set by default upon creation of each new device document:
8. \- document.readACL = id, creator
9. \- document.writeACL = id, creator
10. \- required.readACL = nobody
11. \- required.writeACL = nobody
12. \- requiredVisibles.readACL = creator
13. \- requiredVisibles.writeACL = nobody
14. \- requiredEditables.readACL = creator
15. \- requiredEditables.writeACL = creator
16. You can specify your own ACLs upon device creation by passing them as parameters to the save function of the device module as described in the documentation.
17. \-->
18. **&lt;schema&gt;**
19.   **&lt;aclGroups&gt;**
20.     **<aclGroup** name="required"**\>**
21.       **&lt;read&gt;**nobody**&lt;/read&gt;**
22.       **&lt;write&gt;**nobody**&lt;/write&gt;**
23.       **&lt;fields&gt;**
24.         **&lt;field&gt;**isSuspended**&lt;/field&gt;**
25.       **&lt;/fields&gt;**
26.     **&lt;/aclGroup&gt;**
27.     **<aclGroup** name="requiredVisibles"**\>**
28.       **&lt;read&gt;**creator**&lt;/read&gt;**
29.       **&lt;write&gt;**nobody**&lt;/write&gt;**
30.       **&lt;fields&gt;**
31.         **&lt;field&gt;**id**&lt;/field&gt;**
32.         **&lt;field&gt;**groups**&lt;/field&gt;**
33.         **&lt;field&gt;**token**&lt;/field&gt;**
34.       **&lt;/fields&gt;**
35.     **&lt;/aclGroup&gt;**
36.     **<aclGroup** name="requiredEditables"**\>**
37.       **&lt;read&gt;**creator**&lt;/read&gt;**
38.       **&lt;write&gt;**creator**&lt;/write&gt;**
39.       **&lt;fields&gt;**
40.         **&lt;field&gt;**name**&lt;/field&gt;**
41.         **&lt;field&gt;**password**&lt;/field&gt;**
42.         **&lt;field&gt;**locale**&lt;/field&gt;**
43.       **&lt;/fields&gt;**
44.     **&lt;/aclGroup&gt;**
45.     **&lt;defaultAcl&gt;**
46.       **&lt;read&gt;**creator**&lt;/read&gt;**
47.       **&lt;write&gt;**creator**&lt;/write&gt;**
48.     **&lt;/defaultAcl&gt;**
49.     **&lt;schemaAcl&gt;**
50.       **&lt;read&gt;**creator**&lt;/read&gt;**
51.       **&lt;write&gt;**creator**&lt;/write&gt;**
52.       **&lt;delete&gt;**nobody**&lt;/delete&gt;**
53.     **&lt;/schemaAcl&gt;**
54.   **&lt;/aclGroups&gt;**
55.   **&lt;fields&gt;**
56.     **<field** name="id" type="string" **/>**
57.     **<field** name="name" type="string"**/>**
58.     **<field** name="groups" type="string" **/>**
59.     **<field** name="password" type="string" **/>**
60.     **<field** name="locale" type="string" **/>**
61.     **<field** name="isSuspended" type="string" **/>**
62.     **<field** name="token" type="string" **/>**
63.   **&lt;/fields&gt;**
64. **&lt;/schema&gt;**

```

**save**

Saves a device with the provided fields. If the device already exists, it gets updated; otherwise, it gets created.

| **Parameter** | **Description** |
| --- | --- |
| device | A JSON object containing the device fields. |

The device object properties are as follows:

<table><tbody><tr><th><p><strong>Property</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>id</p></td><td><p>String representing the unique identifier of the device. Optional upon device creation, if not provided, a random ID will be generated.</p><p>It accepts alphanumeric characters, at signs (@), underscores (_), periods (.), and dashes (-) can have a maximum length of 243 characters.</p></td></tr><tr><td><p>name</p></td><td><p>String representing the name of the device. Optional upon update.</p></td></tr><tr><td><p>password</p></td><td><p>String representing the password of the device. Optional upon update.</p></td></tr><tr><td><p>groups</p></td><td><p>Represents the group(s) to which this device will be added. It can have any of the following values:</p><ul><li>a single value.</li><li>an array of strings to specify multiple groups.</li><li>a JSON object representing which values should be appended or deleted upon update (e.g.<em>&nbsp;"groups": {"append":["groupB", "groupC"], "delete":"groupA"}</em>). This JSON object can have the following two properties:<br><ul><li>"<strong>append</strong>": the value of the "append" key should be a string or an array containing the values to be added to the existing field.</li><li>"<strong>delete</strong>": the value of the "delete" key should be a string or an array containing the values to be deleted from the existing field.</li></ul></li></ul><p>Group name accepts alphanumeric characters (a-z A-Z 0-9), dashes (-) and underscores (_), and can have a maximum length of 128 characters.</p><p>Note that passing a null or empty value removes the device from all groups.</p></td></tr><tr><td><p>isSuspended</p></td><td><p>Boolean value specifying whether or not the device is suspended. Optional, defaults to false.</p><p>When set to true, the device will be treated as if it was deleted from the system. It can be reactivated by updating this value to false.</p></td></tr><tr><td><p>globalDateFormat</p></td><td><p>String representing the date format to use to parse any date field values passed as string. Optional, if not specified, the formats "yyyy-MM-dd'T'HH:mm:ssZ" (e.g.&nbsp;<em>2017-01-13T13:01:02+0000</em>) and "yyyy-MM-dd" (e.g.&nbsp;<em>2017-01-13</em>) only will be accepted.</p><p>Refer to&nbsp;<a href="https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html">this</a>&nbsp;document for the accepted date formats.</p></td></tr><tr><td><p>meta.types</p></td><td><p>JSON object containing the list of the document field names to be created/updated along with their corresponding types. The field types can be:</p><ul><li>string</li><li>text</li><li>date</li><li>numeric</li><li>geospatial (a pair of longitude and latitude coordinates represented in decimal degrees)</li></ul><p>Note that any fields omitted from the meta.types will default to type string, unless otherwise specified in the corresponding device schema.</p></td></tr><tr><td><p>&lt;fieldName&gt;</p></td><td><p>Key-value pair representing the name of the field along with its values.</p><p>Each value can be:</p><ul><li>a single value.</li><li>an array of values for multi-value fields.</li><li>a JSON object representing which values should be appended or deleted upon update (e.g.<em>&nbsp;"states": {"append":["New Mexico", "Washington"], "delete":["Utah"]}</em>). This JSON object can have the following two properties:<br><ul><li>"<strong>append</strong>": the value of the "append" key should be a string or an array containing the values to be added to the existing field.</li><li>"<strong>delete</strong>": the value of the "delete" key should be a string or an array containing the values to be deleted from the existing field.</li></ul></li></ul><p>Note that passing a null or empty value deletes the field from the device.</p><p>A field of type file should always be defined in the schema first.</p></td></tr></tbody></table>

**Return value:** JSON object containing the "id" of the device that was successfully created/updated. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example - Editing the Device Schema**

1. // We need to edit the device schema to allow adding a field called reports for saving files
2. **var** newSchemaDefinition = '&lt;schema&gt;&lt;aclGroups&gt;&lt;aclGroup name="required"&gt;&lt;read&gt;nobody&lt;/read&gt;&lt;write&gt;nobody&lt;/write&gt;&lt;fields&gt;&lt;field&gt;isSuspended&lt;/field&gt;&lt;/fields&gt;&lt;/aclGroup&gt;&lt;aclGroup name="requiredVisibles"&gt;&lt;read&gt;creator&lt;/read&gt;&lt;write&gt;nobody&lt;/write&gt;&lt;fields&gt;&lt;field&gt;id&lt;/field&gt;&lt;field&gt;groups&lt;/field&gt;&lt;field&gt;token&lt;/field&gt;&lt;/fields&gt;&lt;/aclGroup&gt;&lt;aclGroup name="requiredEditables"&gt;&lt;read&gt;creator&lt;/read&gt;&lt;write&gt;creator&lt;/write&gt;&lt;fields&gt;&lt;field&gt;name&lt;/field&gt;&lt;field&gt;password&lt;/field&gt;&lt;field&gt;locale&lt;/field&gt;&lt;field&gt;reports&lt;/field&gt;&lt;/fields&gt;&lt;/aclGroup&gt;&lt;defaultAcl&gt;&lt;read&gt;creator&lt;/read&gt;&lt;write&gt;creator&lt;/write&gt;&lt;/defaultAcl&gt;&lt;schemaAcl&gt;&lt;read&gt;creator&lt;/read&gt;&lt;write&gt;creator&lt;/write&gt;&lt;delete&gt;nobody&lt;/delete&gt;&lt;/schemaAcl&gt;&lt;/aclGroups&gt;&lt;fields&gt;&lt;field name="id" type="string" /&gt;&lt;field name="name" type="string" /&gt;&lt;field name="groups" type="string" /&gt;&lt;field name="password" type="string" /&gt;&lt;field name="locale" type="string" /&gt;&lt;field name="isSuspended" type="string" /&gt;&lt;field name="token" type="string" /&gt;&lt;field name="reports" type="file" /&gt;&lt;/fields&gt;&lt;/schema&gt;';
3. **var** schema = **require**("schema");
4. **return** schema.update("apsdb_device", newSchemaDefinition);

**Example - Saving a Device**

1. **var** devices = **require**("device");
2. **var** reportA = request.files\["reportA"\]\[0\];
3. **var** reportB = request.files\["reportB"\]\[0\];
4. **var** lastOnline = **new** Date();
5. **var** **params** = {
6.     "id" : "AB825CE1520F",
7.     "password" : "1a2afef9b19c975b429a92ec22e873c8",
8.     "name" : "deviceA",
9.     "level" : 9.8,
10.     "description" : "IoT door monitoring sensor.",
11.     "firmwareVersion" : "v1.0.972",
12.     "lastOnline" : lastOnline,
13.     "location" : "48.8580,2.2951",
14.     "reports" : \[reportA, reportB\],
15.     "meta.types" : {
16.         "description" : "text",
17.         "level" : "numeric",
18.         "lastOnline" : "date",
19.         "firmwareVersion" : "string",
20.         "location" : "geospatial"
21.     }
22. };
23. **return** devices.save(**params**);

**Success Response Example**

1. {  
2.    "result":{  
3.       "device":{  
4.          "id":"AB825CE1520F"
5.       }
6.    },
7.    "metadata":{  
8.       "status":"success"
9.    }
10. }

**create**

Creates a new device; throws the "DUPLICATE_DEVICE" exception if a device with the same ID already exists, or a "DUPLICATE_USER" exception if a user with the same ID already exists. The create function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-device) function.

**update**

Updates a device; throws the "INVALID_DEVICE" exception if the device does not exist. The update function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-device) function.

**delete**

Deletes a device based on the specified ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the ID of the device to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**get**

Retrieves a device by ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the device to be retrieved. |
| includeFieldType | Boolean which, when set to true, will return the meta.types property that contains the list of the device document's fields along with their corresponding field types. |

**Return value:** JSON object containing all the fields of the requested device. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**query**

The query function takes the same parameter "filter" as the user module's [query](https://www.scriptr.io/documentation#documentation-query-user) function.

**getAttachment**

Retrieves an attachment from a specific device.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the device. |
| fileName | String representing the name of the requested file attachment. |
| fieldName | String representing the name of the field under which the requested file is saved. |

**Return value:** JSON object containing the properties and content of the file attachment. In case of a failure the appropriate error code and details will be returned in a metadata property.

**generateToken**

Generates a token for the specified device. You can only generate one token per device.

The generated token does not expire, therefore, it is called eternal token.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the device for which the token should be generated. |

**Return value:** JSON object containing the generated token. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** devices = **require**("device");
2. // Generate the eternal token for device "myDevice"
3. **return** devices.generateToken("myDevice");

**Example of a Success Response**

1. {
2.     "result": {
3.         "token": "TjA2QjI2MTc0MTpnZ25EMMMyOjhDNjdENTFFRUVDOTEwBjkxMUE0NEZENDlPRkQ4Q0Iw"
4.     },
5.     "metadata": {
6.         "status": "success"
7.     }
8. }

**regenerateToken**

Regenerates a token for the specified device.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the device for which the token should be regenerated. |

**Return value:** JSON object containing the newly generated token. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** devices = **require**("device");
2. // Regenerate the eternal token for device "myDevice"
3. **return** devices.regenerateToken("myDevice");

**revokeToken**

Deletes the token of the specified device.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the device for which the token should be revoked. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** devices = **require**("device");
2. // Revoke the eternal token for device "myDevice"
3. **return** devices.revokeToken("myDevice");
