## **schema Module**

Schemas are used when saving a document to define the kind of data you expect to store for a certain business entity, along with the validation and security rules. For example, you might want to have a vehicle entity in your fleet management application. You can define a schema for that entity, specifying that vehicleId, carType, registrationCertificate, lastServiceDate, fuelPercentage and currentLocation represent the data to be collected for each vehicle. For each of these vehicle attributes, you can associate validation and security rules. Hence, a schema provides a uniform way of dealing with your vehicles. Note that vehicle attributes that are not defined in the schema can still be persisted as part of the vehicle document; however, no specific validation nor security rules can be applied to them.

Scriptr.io does not enforce the use of schemas. Alternatively, you can always persist data without specifying a schema, however, no field-level security nor validation rules can be applied. This "schema-less" mode is meant for prototyping and experimenting purposes. We recommend that business applications be built in a "schema-full" mode.

Please refer to [Document Schema Definitions](https://www.scriptr.io/resources/schema-definition.xsd) to view the schema syntax (XSD) that you should use to create your schemas. An example of a schema is as follows:

1. **<schema** versioning="enabled"**\>**
2.     **&lt;aclGroups&gt;**
3.         **<aclGroup** name="admin"**\>**
4.             **&lt;read&gt;**userA;group:admin**&lt;/read&gt;**
5.             **&lt;write&gt;**group:admin**&lt;/write&gt;**
6.             **&lt;fields&gt;**
7.                 **&lt;field&gt;**vehicleId**&lt;/field&gt;**
8.                 **&lt;field&gt;**carType**&lt;/field&gt;**
9.                 **&lt;field&gt;**registrationCertificate**&lt;/field&gt;**
10.                 **&lt;field&gt;**lastServiceDate**&lt;/field&gt;**
11.             **&lt;/fields&gt;**
12.         **&lt;/aclGroup&gt;**
13.         **<aclGroup** name="devices"**\>**
14.             **&lt;read&gt;**authenticated**&lt;/read&gt;**
15.             **&lt;write&gt;**authenticated**&lt;/write&gt;**
16.             **&lt;fields&gt;**
17.                 **&lt;field&gt;**fuelPercentage**&lt;/field&gt;**
18.                 **&lt;field&gt;**currentLocation**&lt;/field&gt;**
19.             **&lt;/fields&gt;**
20.         **&lt;/aclGroup&gt;**
21.         **&lt;defaultAcl&gt;**
22.             **&lt;read&gt;**authenticated**&lt;/read&gt;**
23.             **&lt;write&gt;**authenticated**&lt;/write&gt;**
24.             **&lt;delete&gt;**group:admin**&lt;/delete&gt;**
25.         **&lt;/defaultAcl&gt;**
26.         **&lt;schemaAcl&gt;**
27.             **&lt;read&gt;**nobody**&lt;/read&gt;**
28.             **&lt;write&gt;**nobody**&lt;/write&gt;**
29.             **&lt;delete&gt;**nobody**&lt;/delete&gt;**
30.         **&lt;/schemaAcl&gt;**
31.     **&lt;/aclGroups&gt;**
32.     **&lt;fields&gt;**
33.         **<field** searchable="false" name="vehicleId" type="numeric" **\>**
34.             **&lt;validation&gt;**
35.                 **<cardinality** min="1" max="1" **/>**
36.             **&lt;/validation&gt;**
37.         **&lt;/field&gt;**
38.         **<field** searchable="true" name="carType" type="string" **\>**
39.             **&lt;validation&gt;**
40.                 **<cardinality** min="1" max="1" **/>**
41.             **&lt;/validation&gt;**
42.         **&lt;/field&gt;**
43.         **<field** searchable="false" name="fuelPercentage" type="numeric"**\>**
44.             **&lt;validation&gt;**
45.                 **<cardinality** min="1" max="1" **/>**
46.                 **<range** min="0" max="100" **/>**
47.             **&lt;/validation&gt;**
48.         **&lt;/field&gt;**
49.         **<field** name="currentLocation" type="geospatial" **/>**
50.         **<field** searchable="true" name="registrationCertificate" type="file" **/>**
51.         **<field** name="lastServiceDate" type="date" **/>**
52.     **&lt;/fields&gt;**
53. **&lt;/schema&gt;**

Note that document versioning is only available when using schemas. In order to enable it, set the versioning status at the beginning of the schema. The possible values are "disabled", "enabled", or "forced"; it defaults to "disabled".

**create**

Creates a schema.

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the schema to be created. |
| content | The XML content of the schema. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** schema = **require**("schema");
2. **return** schema.create("vehicleSchema", '&lt;schema versioning="enabled"&gt;&lt;aclGroups&gt;&lt;aclGroup name="admin"&gt;&lt;read&gt;userA;group:admin&lt;/read&gt;&lt;write&gt;group:admin&lt;/write&gt;&lt;fields&gt;&lt;field&gt;vehicleId&lt;/field&gt;&lt;field&gt;carType&lt;/field&gt;&lt;field&gt;registrationCertificate&lt;/field&gt;&lt;field&gt;lastServiceDate&lt;/field&gt;&lt;/fields&gt;&lt;/aclGroup&gt;&lt;aclGroup name="devices"&gt;&lt;read&gt;authenticated&lt;/read&gt;&lt;write&gt;authenticated&lt;/write&gt;&lt;fields&gt;&lt;field&gt;fuelPercentage&lt;/field&gt;&lt;field&gt;currentLocation&lt;/field&gt;&lt;/fields&gt;&lt;/aclGroup&gt;&lt;defaultAcl&gt;&lt;read&gt;authenticated&lt;/read&gt;&lt;write&gt;authenticated&lt;/write&gt;&lt;delete&gt;group:admin&lt;/delete&gt;&lt;/defaultAcl&gt;&lt;schemaAcl&gt;&lt;read&gt;nobody&lt;/read&gt;&lt;write&gt;nobody&lt;/write&gt;&lt;delete&gt;nobody&lt;/delete&gt;&lt;/schemaAcl&gt;&lt;/aclGroups&gt;&lt;fields&gt;&lt;field searchable="false" name="vehicleId" type="numeric" &gt;&lt;validation&gt;&lt;cardinality min="1" max="1" /&gt;&lt;/validation&gt;&lt;/field&gt;&lt;field searchable="true" name="carType" type="string" &gt;&lt;validation&gt;&lt;cardinality min="1" max="1" /&gt;&lt;/validation&gt;&lt;/field&gt;&lt;field searchable="false" name="fuelPercentage" type="numeric"&gt;&lt;validation&gt;&lt;cardinality min="1" max="1" /&gt;&lt;range min="0" max="100" /&gt;&lt;/validation&gt;&lt;/field&gt;&lt;field name="currentLocation" type="geospatial" /&gt;&lt;field searchable="true" name="registrationCertificate" type="file" /&gt;&lt;field name="lastServiceDate" type="date" /&gt;&lt;/fields&gt;&lt;/schema&gt;');

**update**

Updates the content of a schema.

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the schema to be updated. |
| content | The new XML content of the schema. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**delete**

Deletes an existing schema.

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the schema to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**rename**

Renames a schema. All existing documents with the old schema name will be updated to have the new schema name.

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the schema to be renamed. |
| newName | The new name of the schema. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**list**

Retrieves the list of all existing schemas.

**Return value:** JSON object containing an array of the schema names. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Sample**

1. {
2.     "metadata": {
3.             "status": "success"
4.         },
5.     "result": {
6.         "schemas": \[
7.             {
8.                 "name": "vehicleSchema"
9.             }
10.         \]
11.     }
12. }

**get**

Retrieves a specific schema by name.

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the schema to be retrieved. |

**Return value:** JSON object containing the content of the schema. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** schema = **require**("schema");
2. **return** schema.**get**("vehicleSchema");
