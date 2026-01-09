## **user Module**

> **Important Schema Naming**: The user schema in Scriptr.io is named `apsdb_user`. This exact name must be used when referencing the schema programmatically (e.g., in SchemaAdaptor for UI components).

The user module allows you to create and manage users. Each user is associated to the below schema that provides the basic user fields and ACLs. You can modify the schema to meet your needs by [updating](https://www.scriptr.io/documentation#documentation-schema-update) the apsdb_user system [schema](https://www.scriptr.io/documentation#documentation-schemamodule).

```
1. <!--
2. This is the default user schema. Feel free to modify it to your liking.
3. This schema follows all rules and restrictions as all other schemas, as do the documents (users) created out of it.
4. However, it imposes the following restrictions of its own:
5. 1\. The six default fields (groups, name, login, password, locale and isSuspended) are required.
6. 2\. This schema cannot be deleted.
7. Additionally, since this schema is used for user management, the following ACLs are set by default upon creation of each new user document:
8. \- document.readACL = login, creator
9. \- document.writeACL = login, creator
10. \- required.readACL = nobody
11. \- required.writeACL = nobody
12. \- requiredVisibles.readACL = creator
13. \- requiredVisibles.writeACL = nobody
14. \- requiredEditables.readACL = creator
15. \- requiredEditables.writeACL = creator
16. You can specify your own ACLs upon user creation by passing them as parameters to the save() function of the user module as described in the documentation.
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
31.         **&lt;field&gt;**login**&lt;/field&gt;**
32.         **&lt;field&gt;**groups**&lt;/field&gt;**
33.       **&lt;/fields&gt;**
34.     **&lt;/aclGroup&gt;**
35.     **<aclGroup** name="requiredEditables"**\>**
36.       **&lt;read&gt;**creator**&lt;/read&gt;**
37.       **&lt;write&gt;**creator**&lt;/write&gt;**
38.       **&lt;fields&gt;**
39.         **&lt;field&gt;**name**&lt;/field&gt;**
40.         **&lt;field&gt;**password**&lt;/field&gt;**
41.         **&lt;field&gt;**locale**&lt;/field&gt;**
42.       **&lt;/fields&gt;**
43.     **&lt;/aclGroup&gt;**
44.     **&lt;defaultAcl&gt;**
45.       **&lt;read&gt;**creator**&lt;/read&gt;**
46.       **&lt;write&gt;**creator**&lt;/write&gt;**
47.     **&lt;/defaultAcl&gt;**
48.     **&lt;schemaAcl&gt;**
49.       **&lt;read&gt;**creator**&lt;/read&gt;**
50.       **&lt;write&gt;**creator**&lt;/write&gt;**
51.       **&lt;delete&gt;**nobody**&lt;/delete&gt;**
52.     **&lt;/schemaAcl&gt;**
53.   **&lt;/aclGroups&gt;**
54.   **&lt;fields&gt;**
55.     **<field** name="login" type="string"**/>**
56.     **<field** name="name" type="string"**/>**
57.     **<field** name="groups" type="string"**/>**
58.     **<field** name="password" type="string" **/>**
59.     **<field** name="locale" type="string" **/>**
60.     **<field** name="isSuspended" type="string" **/>**
61.   **&lt;/fields&gt;**
62. **&lt;/schema&gt;**
```
**save**

Saves a user with the provided parameters. If the user already exists, it gets updated; otherwise, it gets created.

| **Parameter** | **Description** |
| --- | --- |
| user | A JSON object containing the user fields. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The user object properties are as follows:

<table><tbody><tr><th><p><strong>Property</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>id</p></td><td><p>String representing the unique identifier of the user.</p><p>It accepts alphanumeric characters,&nbsp;at signs (@), underscores (_), periods (.), and dashes (-)&nbsp;and can have a maximum length of 243 characters.</p></td></tr><tr><td><p>name</p></td><td><p>String representing the name of the user. Optional upon update.</p></td></tr><tr><td><p>password</p></td><td><p>String representing the password of the user. Optional upon update.</p></td></tr><tr><td><p>groups</p></td><td><p>Represents the group(s) to which this user will be added. It can have any of the following values:</p><ul><li>a single value.</li><li>an array of strings to specify multiple groups.</li><li>a JSON object representing which values should be appended or deleted upon update (e.g.<em>&nbsp;"groups": {"append":["groupB", "groupC"], "delete":"groupA"}</em>). This JSON object can have the following two properties:<br><ul><li>"<strong>append</strong>": the value of the "append" key should be a string or an array containing the values to be added to the existing field.</li><li>"<strong>delete</strong>": the value of the "delete" key should be a string or an array containing the values to be deleted from the existing field.</li></ul></li></ul><p>Group name accepts alphanumeric characters (a-z A-Z 0-9), dashes (-) and underscores (_), and can have a maximum length of 128 characters.</p><p>Note that passing a null or empty value removes the user from all groups.</p></td></tr><tr><td><p>isSuspended</p></td><td><p>Boolean value specifying whether or not the user is suspended. Optional, defaults to false.</p><p>When set to true, the user will be treated as if it was deleted from the system. It can be reactivated by updating this value to false.</p></td></tr><tr><td><p>globalDateFormat</p></td><td><p>String representing the date format to use to parse any date field values passed as string. Optional, if not specified, the formats "yyyy-MM-dd'T'HH:mm:ssZ" (e.g.&nbsp;<em>2017-01-13T13:01:02+0000</em>) and "yyyy-MM-dd" (e.g.&nbsp;<em>2017-01-13</em>) only will be accepted.</p><p>Refer to&nbsp;<a href="https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html">this</a>&nbsp;document for the accepted date formats.</p></td></tr><tr><td><p>meta.types</p></td><td><p>JSON object containing the list of the document field names to be created/updated along with their corresponding types. The field types can be:</p><ul><li>string</li><li>text</li><li>date</li><li>numeric</li><li>geospatial (a pair of longitude and latitude coordinates represented in decimal degrees)</li></ul><p>Note that any fields omitted from the meta.types will default to type string, unless otherwise specified in the corresponding user schema.</p></td></tr><tr><td><p>&lt;fieldName&gt;</p></td><td><p>Key-value pair representing the name of the field along with its values.</p><p>Each value can be:</p><ul><li>a single value.</li><li>an array of values for multi-value fields.</li><li>a JSON object representing which values should be appended or deleted upon update (e.g.<em>&nbsp;"states": {"append":["New Mexico", "Washington"], "delete":["Utah"]}</em>). This JSON object can have the following two properties:<br><ul><li>"<strong>append</strong>": the value of the "append" key should be a string or an array containing the values to be added to the existing field.</li><li>"<strong>delete</strong>": the value of the "delete" key should be a string or an array containing the values to be deleted from the existing field.</li></ul></li></ul><p>Note that passing a null or empty value deletes the field from the user.</p><p>A field of type file should always be defined in the schema first.</p></td></tr></tbody></table>

**Example**
```
1. **var** users = **require**("user");
2. **var** **params** = {
3.     "id" : "<john.doe@example.com>",
4.     "password" : "1a2afef9b19c975b429a92ec22e873c8",
5.     "name" : "John Doe",
6.     "description" : "Security services employee",
7.     "lastOnline" : **new** Date(),
8.     "groups" : \["groupA", "groupB"\],
9.     "meta.types" : {
10.         "description" : "text",
11.         "lastOnline" : "date"
12.     }
13. };
14. **return** users.save(**params**);
```
**create**

Creates a new user; throws the "DUPLICATE_USER" exception if a user with the same ID already exists, or a "DUPLICATE_DEVICE" exception if a device with the same ID already exists. The create function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-user) function.

**update**

Updates a user; throws the "INVALID_USER" exception if the user does not exist. The update function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-user) function.

**delete**

Deletes a user based on the specified ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the ID of the user to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**get**

Retrieves a user by ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the user to be retrieved. |
| includeFieldType | Boolean which, when set to true, will return the meta.types property that contains the list of the user document's fields along with their corresponding field types. |

**Return value:** JSON object containing all the fields of the requested user. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**query**

Queries user data according to the conditions passed in the provided filter.

| **Parameter** | **Description** |
| --- | --- |
| filter | JSON object containing the parameters to be sent along with the query request. |

**Return value:** JSON object containing array of users matching the query filter. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The filter object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| query | String representing the query condition to execute. Optional. |
| ftsQuery | String used to refine the search after executing the query condition by performing a full-text search on the returned users. Only the fields that are set to "searchable" in the user schema can be searched against using the ftsQuery. Note that when using the ftsQuery parameter, the sort parameter will be ignored. |
| count | Boolean specifying whether or not to return the total count of users found. Optional, defaults to false. <br><br>Note that if the ftsQuery parameter is sent in the request, the count will be equal to the number of users returned in the first page instead of the total number of hits. |
| fields | String containing a comma separated list of fields that should be returned by the query. Optional if the count property is passed in the filter.<br><br>In order to return all fields, you can pass the \* wildcard.<br><br>The query will always return the user ID in addition to the specified fields.<br><br>Note that in addition to the user defined fields, you can retrieve the system fields: creator, lastModifiedDate, lastModifiedBy, creationDate, versionNumber and latest. |
| sort | String containing a comma separated list of the fields on which to sort. Optional.<br><br>The syntax for sorting fields is: "fieldName_<_fieldType:sortingOrder>". For instance, to sort a document by name and birthday fields, you could pass in the value “_name&lt;string:ASC&gt;, birthday&lt;date:DESC&gt;_”.<br><br>Note that this parameter is ignored when using the ftsQuery parameter. |
| resultsPerPage | Numeric value that determines the number of documents per page to return. Optional, defaults to 50. |
| pageNumber | Numeric value representing the number of the page to be returned. Optional, defaults to 1. |
| includeFieldType | Boolean specifying whether or not to return the meta.types property for each user. The meta.types is a JSON object containing the names and types of the fields returned by the query. Optional, defaults to false. |

**Example**

1. **var** users = **require**("user");
2. // Look for users in "groupA"
3. **return** users.query({"query":'groups in \["groupA"\]', "fields":"\*", "sort":"name&lt;string:ASC&gt;, lastOnline&lt;date:DESC&gt;"});
4. // OR
5. **return** users.query({"query":'groups = "groupA"', "fields":"\*", "sort":"name&lt;string:ASC&gt;, lastOnline&lt;date:DESC&gt;"});

**Example of a Success Response**
```
1. {
2.     "result" : {
3.         "users" : \[{
4.                 "description" : "Security services employee",
5.                 "groups" : \[
6.                     "groupA",
7.                     "groupB"
8.                 \],
9.                 "login" : "<john.doe@example.com>",
10.                 "name" : "John Doe",
11.                 "id" : "<john.doe@example.com>",
12.                 "creator" : "scriptr@L22826DC91",
13.                 "versionNumber" : "1.0",
14.                 "latest" : "1.0",
15.                 "lastModifiedBy" : "scriptr",
16.                 "creationDate" : "2017-01-10T15:00:20+0000",
17.                 "lastModifiedDate" : "2017-01-10T15:12:59+0000"
18.             }
19.         \]
20.     },
21.     "metadata" : {
22.         "status" : "success"
23.     }
24. }
```
**getAttachment**

Retrieves an attachment from a specific user.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the user. |
| fileName | String representing the name of the requested file attachment. |
| fieldName | String representing the name of the field under which the requested file is saved. |

**Return value:** JSON object containing the properties and content of the file attachment. In case of a failure the appropriate error code and details will be returned in a metadata property.

**generateToken**

Generates a token for the specified user. You can generate 20 tokens per user.

The generated token expires based on the values that you set.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the user for which the token should be generated. |
| options | JSON object containing additional options. If not passed, the default values will apply. |

**Return value:** JSON object containing the generated token and its properties. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The options object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| password | String representing the user's password to trigger an additional verification step for performing this operation. If not provided, this security check will be omitted. |
| expiry | Integer or string representing the relative time, in seconds, after which the token expires and becomes unusable. <br><br>The default expiry is 1800 seconds (30 minutes).<br><br>It should always be less or equal to 86400 seconds (24 hours). |
| lifeTime | Integer or string representing the relative time, in seconds, after which the token cannot be renewed.<br><br>The default lifeTime is 7200 seconds (2 hours).<br><br>It should always be less or equal to 604800 seconds (1 week). |
| bindToReferrer | Boolean or string that determines whether or not the tokens will be bound to the issuing request's referrer. It defaults to true.<br><br>When a token is bound to a referrer, requests signed by this token can only work with this provided referrer. |

**Example**

1. **var** users = **require**("user");
2. // Generate a token for user "myUser"
3. **return** users.generateToken("myUser", {"password": "password", "expiry": 1800, "lifeTime": 7200, "bindToReferrer": "false"});  

**Example of a Success Response**
```
1. {
2.     "result": {
3.         "token": "TjA2QjI2MTc0MTpnZ25EMMMyOjhDNjdENTFFRUVDOTEwBjkxMUE0NEZENDlPRkQ4Q0Iw"
4.     },
5.     "metadata": {
6.         "status": "success"
7.     }
8. }
```
**renewToken**

Renews a token for the specified user.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the user for which the token should be renewed. |
| token | String representing the token that needs to be renewed. |

**Return value:** JSON object containing the newly generated token and its properties. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** users = **require**("user");
2. // Renew the provided token for user "myUser"
3. **return** users.renewToken("myUser", "TjA2QjI2MTc0MTpnZ25EMMMyOjhDNjdENTFFRUVDOTEwBjkxMUE0NEZENDlPRkQ4Q0Iw");

**revokeToken**

Deletes the token of the specified user.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the identifier of the user for which the token should be revoked. |
| token | String representing the token that needs to be revoked. |

**Return value:** no value is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**revokeTokens**

Revokes all the tokens of the specified users.

| **Parameter** | **Description** |
| --- | --- |
| idList | Either a string or an array of strings containing the identifiers of the users for which the tokens will be revoked. |

**Return value:** no value is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**
```
1. **var** users = **require**("user");
2. users.revokeTokens(\["id1","id2"\]);
3. **return** users.revokeTokens("id3");
```