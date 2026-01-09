## **document Module**

In scriptr.io, data is represented as document entities where each document has a unique key and a collection of fields. Each field consists of a name, multiple values and a type.

As documents are saved in a [store](https://www.scriptr.io/documentation#documentation-store) in scriptr.io, every instance of the document module is associated with a specific store allowing you to perform actions against that store. When you require the document module inside your script, it will always return the instance associated with the "DefaultStore"; therefore, all calls you make using that instance will be executed on the default store. If you want to manipulate documents on a different store, you can use the [getInstance(_storeName_)](https://www.scriptr.io/documentation#documentation-getInstance-document) method to retrieve an instance of the document module associated with a specific one, and then perform your actions using that instance.

All documents are secured individually with ACLs, allowing developers to specify the Devices and/or Groups that can view, update or delete a document_,_ or more granularly individual fields within that document.

**getInstance**

Returns an instance of the document module associated with a specific store. All actions performed against this instance, such as saving or deleting documents, will be executed against its associated store.

| **Parameter** | **Description** |
| --- | --- |
| storeName | String representing a store name. |

**Return value:**  object representing the instance of the document module associated with the specified store.

**Example - Retrieve a document from a specific store**
```
1. // Get an instance of the DefaultStore using the require() function
2. **var** defaultStoreDocuments = **require**("document");
3. // Get an instance of your custom store called "myStore"
4. **var** myStoreDocuments = defaultStoreDocuments.getInstance("myStore");
5. // Retrieve the document "myDocument" that is saved in "myStore"
6. **return** myStoreDocuments.**get**("myDocument");
```
**save**

Saves a document along with its content. If the document already exists, it gets updated; otherwise, it gets created.

| **Parameter** | **Description** |
| --- | --- |
| document | JSON object containing the fields to be persisted in the document. |

The document object properties are as follows:
```
<table><tbody><tr><th><p><strong>Property</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>key</p></td><td><p>String representing the unique document identifier. If not provided, it will be generated automatically. Optional upon document creation.</p></td></tr><tr><td><p>&lt;field&gt;</p></td><td><p>Key-value pair representing the name of the field along with its values.</p><p>Each value can be:</p><ul><li>a single value.</li><li>an array of values for multi-value fields.</li><li>a JSON object representing which values should be appended or deleted upon update (e.g.<em>&nbsp;"states": {"append":["New Mexico", "Washington"], "delete":["Utah"]}</em>). This JSON object can have the following two properties:<br><ul><li>"<strong>append</strong>": the value of the "append" key should be&nbsp;a string or&nbsp;an array containing the values to be added to the existing field.</li><li>"<strong>delete</strong>": the value of the "delete" key should be&nbsp;a string or&nbsp;an array containing the values to be deleted from the existing field.</li></ul></li></ul><p>Note that passing a null or empty value deletes the field from the document.</p></td></tr><tr><td><p>attachments&nbsp;&nbsp;</p></td><td><p>Array of file objects to be attached to a document. Optional.</p></td></tr><tr><td><p>meta.types</p></td><td><p>JSON object containing the list of the document field names to be created/updated along with their corresponding types. The field types can be:</p><ul><li>string</li><li>text</li><li>date</li><li>numeric</li><li>geospatial (a pair of longitude and latitude coordinates represented in decimal degrees)</li></ul><p>Note that any fields omitted from the meta.types will default to type string, unless otherwise specified in the corresponding document schema.</p></td></tr><tr><td><p>meta.schema</p></td><td><p>Represents the name of a preset schema to apply to the document. Optional.</p></td></tr><tr><td><p>meta.newVersion</p></td><td><p>Boolean specifying whether this call will create a new version of the document (if set to true) instead of updating the existing one (if set to false). Note that versioning can only be used when the document has a schema. Optional.</p></td></tr><tr><td><p>meta.latestVersion</p></td><td><p>Numeric that&nbsp;indicates the latest version of the document that the user expects to be modifying to manage concurrent updates. If the document has a different latest version number than the one specified, then the update will fail. Note that it can only be sent when a document is versioned. Optional.</p></td></tr><tr><td><p>meta.ftsFields</p></td><td><p>Represents the name(s) of the field(s) that will be searchable using full-text queries. It accepts either a string or an array of strings. Optional.</p></td></tr></tbody></table>
```
**Return value:** JSON object containing the key and the version number of the document. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example: Create a document using the save() function**
```
1. **var** documents = **require**("document");
2. // Retrieve the country flag image file from the request
3. **var** countryFlag = request.files\["flag"\];
4. // Define the document content
5. **var** fields = {
6.     // set the document key
7.     "key": "myCountryDocumentKey",
8.     // add a field containing a string value called name
9.     "name": "USA",
10.     // add a field containing a numeric value called totalLandArea
11.     "totalLandArea": 9147593,
12.     // add a field containing a date value called independenceDay
13.     "independenceDay": "1776-07-04",
14.     // add a field representing the ID of the device that gathers data related to this document
15.     "deviceId": "31afe00925b6a",
16.     // add a field representing the device geo-location
17.     "deviceLocation": "48.8580,2.2951",
18.     // add a field containing an array of string value called states
19.     "states": \[
20.         "New York",
21.         "California",
22.         "Chicago",
23.         "Utah"
24.     \],
25.     // add a field containing a text value called history
26.     "history": "The U.S. is a country of 50 states covering a vast swath of North America, with Alaska in the extreme Northwest and Hawaii extending the nation’s presence into the Pacific Ocean. Major cities include New York, a global finance and culture center, and Washington, DC, the capital, both on the Atlantic Coast; Los Angeles, famed for filmmaking, on the Pacific Coast; and the Midwestern metropolis Chicago.",
27.     // add the country flag image that got retrieved from the request as an attachment to the document
28.     "attachments": countryFlag,
29.     // enable full text-search on the history field
30.     "meta.ftsFields":"history",
31.     // define the types of the fields added above to match their content types
32.     "meta.types": {
33.         "name": "string",
34.         "totalLandArea": "numeric",
35.         "independenceDay": "date",
36.         "states": "string",
37.         "deviceId": "string",
38.         "deviceLocation": "geospatial",
39.         "history": "text"
40.     }
41. };
42. // Persist the document myCountryDocumentKey
43. **return** documents.save(fields);
```
**Example: Update a document using the save() function**
```
1. **var** documents = **require**("document");
2. // Define the document content to be updated
3. **var** fields = {
4.     // specify the document key
5.     "key": "myCountryDocumentKey",
6.     // Update the states field by appending and deleting some values
7.     "states": {"append":\["New Mexico", "Washington"\], "delete":\["Utah"\]},
8.     // delete the history field by setting it to an empty string
9.     "history": "",
10.     // add a new field to the document called connected of type string
11.     "connected": "true",
12.     // specify the type of the newly added field
13.     "meta.types": {
14.         "connected": "string"
15.     }
16. };
17. **return** documents.save(fields);
```

**Example of a Success Response**
```
1. {  
2.     "result":{  
3.         "document":{  
4.             "key":"myCountryDocumentKey",
5.             "versionNumber":"1.0"
6.         }
7.     },
8.     "metadata":{  
9.         "status":"success"
10.     }
11. }
```
**create**

Creates a new document; throws the "DUPLICATE_DOCUMENT_KEY" exception if a document with the same key already exists. The create function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-document) function.

**update**

Updates a document; throws the "DOCUMENT_NOT_FOUND" exception if the document does not exist. The update function takes the same parameter as the [save](https://www.scriptr.io/documentation#documentation-save-document) function.

**delete**

Deletes a document based on the specified key.

| **Parameter** | **Description** |
| --- | --- |
| key | String representing the key of the document to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**
```
1. **var** documents = **require**("document");

3. // Delete the document with key "myCountryDocumentKey"
4. **return** documents.**delete**("myCountryDocumentKey");
```
**query**

Queries document data from the current store according to the conditions passed in the provided filter.

| **Parameter** | **Description** |
| --- | --- |
| filter | JSON object containing the parameters to be sent along with the query request. |

**Return value:** JSON object containing the array of documents matching the query filter. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The filter object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| query | String representing the query condition to execute. Optional. |
| ftsQuery | String used to refine the search after executing the query condition by performing a full-text search on the returned documents. Note that when using the ftsQuery parameter, the sort and aggregateExpression parameters will be ignored. |
| count | Boolean specifying whether or not to return the total count of documents found. Optional, defaults to false. <br><br>Note that if the ftsQuery parameter is sent in the request, the count will be equal to the number of documents returned in the first page instead of the total number of hits. |
| fields | String containing a comma separated list of fields that should be returned by the query. Optional if the count property is passed in the filter.<br><br>Note that in addition to the user defined fields, you can query on the system fields: creator, lastModifiedDate, lastModifiedBy, creationDate, versionNumber and latest.<br><br>In order to return all fields, you can pass the \* wildcard.<br><br>The query will always return the document key and the versionNumber in addition to the specified fields. |
| sort | String containing a comma separated list of the fields on which to sort. Optional.<br><br>The syntax for sorting fields is: "fieldName_<_fieldType:sortingOrder>". For instance, to sort a document by name and birthday fields, you could pass in the value “_name&lt;string:ASC&gt;, birthday&lt;date:DESC&gt;_”.<br><br>Note that this parameter is ignored when using the ftsQuery parameter. |
| resultsPerPage | Numeric value that determines the number of documents per page to return. Optional, defaults to 50. |
| pageNumber | Numeric value representing the number of the page to be returned. Optional, defaults to 1. |
| includeFieldType | Boolean specifying whether or not to return the meta.types property for each document. The meta.types is a JSON object containing the names and types of the fields returned by the query. Optional, defaults to false. |
| aggregateExpression | Contains the aggregate expression to execute. Note that this parameter is ignored when using the ftsQuery parameter. Optional. |
| aggregateGroupBy | Groups the aggregate result by one or more fields. Optional.<br><br>The syntax for grouping by field is: "fieldName_<_fieldType>". For instance, to group the results per deviceType and category, you pass in the value “_deviceType&lt;String&gt;, category&lt;numeric&gt;_”. |
| aggregatePage | Specifies whether or not the aggregate function will be executed on the documents that are displayed on the current page. Optional, defaults to true. |
| aggregateGlobal | Specifies whether or not the aggregate function will be executed on all documents returned by the query on all pages. Optional, defaults to false. |
| saveDocumentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts saving the document. It defaults to nobody. |
| deleteDocumentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts deleting the document. It defaults to nobody. |
| getAttachmentACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts retrieval of file attachments from the document. It defaults to nobody. |
| queryACL | [Value](https://www.scriptr.io/documentation#documentation-aclvalue) representing the access control list that restricts access to querying the document. It defaults to nobody. |

**Example 1 - Regular or FTS Queries**
```
1. **var** documents = **require**("document");
2. **var** results;
3. /\* Search for the documents where the states field contains "Chicago" and "California",
4.  \* sort by creationDate (ASC) and totalLandArea (DESC),
5.  \* return the states, totalLandArea and creationDate fields.
6.  \*/
7. results = documents.query({"query":'states in \["Chicago", "California"\]', "sort":"creationDate&lt;date:ASC&gt;, totalLandArea&lt;numeric:DESC&gt;", "fields":"states, totalLandArea, creationDate"});
8. // Search for documents having the words "Washington" and "DC" in any of their full-text indexed fields
9. results = documents.query({"fields":"\*", "ftsQuery":"Washington DC"});
```
**Example of a Success Response for Regular or FTS Queries**
```
1. {
2.         "result": {
3.             "documents": \[
4.                 {
5.                     "key": "myCountryDocumentKey",
6.                     "versionNumber": "1.0",
7.                     "states": \[
8.                         "New York",
9.                         "Chicago",
10.                         "California",
11.                         "New Mexico",
12.                         "Washington"
13.                     \],
14.                     "totalLandArea": "9147593.0",
15.                     "creationDate": "2016-11-15T15:59:29+0000"
16.                 }
17.             \]
18.         },
19.         "metadata": {
20.             "status": "success"
21.         }
22. }
```
**Example 2 - Aggregate Queries**
```
1. **var** documents = **require**("document");
2. **var** results;
3. // Get the average temperature of all sensors
4. results = documents.query({"query":'deviceType = "sensor"', "aggregateExpression":"avg($temperature)", "fields": "temperature"});
5. // Get the average temperature grouped by device type and category number for the first page and for all pages (global)
6. results = documents.query({"aggregateExpression":"avg($temperature)", "aggregateGroupBy":"deviceType&lt;String&gt;, category&lt;numeric&gt;", "aggregatePage":**true**, "aggregateGlobal":**true**});
7. // You can similarly use other aggregates such as MIN, MAX, SUM, AVG, or COUNT, in a similar fashion. Another example:
8. results = documents.query({"aggregateExpression":"max($totalLandArea)", "aggregatePage":**true**, "aggregateGlobal":**true**, "fields": "totalLandArea"});
9. **return** results;
```
**Example of a Success Response for Aggregate Queries**
```
1. {
2.     "result" : {
3.         "aggregate" : {
4.             "pageScope" : {
5.                 "value" : "9147593.0"
6.             },
7.             "globalScope" : {
8.                 "value" : "9147593.0"
9.             }
10.         },
11.         "documents" : \[{
12.                 "key" : "myCountryDocumentKey",
13.                 "versionNumber" : "1.0",
14.                 "totalLandArea" : "9147593.0"
15.             }, {
16.                 "key" : "anotherCountryDocumentKey",
17.                 "versionNumber" : "1.0",
18.                 "totalLandArea" : "10542.0"
19.             }
20.         \]
21.     },
22.     "metadata" : {
23.         "status" : "success"
24.     }
25. }
```
**Example 3 - Geospatial Queries**
```
1. **var** documents = **require**("document");
2. // Search for documents which devices are located within 200 meters of the reference point '48.8588, 2.2965' and return the distance between these devices and the reference point.
3. **return** documents.query({
4.     "query" : 'name&lt;string&gt;="USA" and deviceLocation&lt;geospatial&gt; within (48.8588, 2.2965, 0.200)',
5.     "includeFieldType" : "true",
6.     "fields" : "key, deviceLocation, distance(deviceLocation,'48.8588', '2.2965')",
7.     "sort" : "distance(deviceLocation,48.8588,2.2965)&lt;ASC&gt;"
8. });
```
To query on geospatial fields, the "within" operator should be used. It allows queries to search for geospatial locations that lie within a specified distance from a reference point. Consequently, this operator requires 2 parameters: a geospatial reference point (represented as a pair of latitude/longitude decimal degrees), and a distance value (in kilometers). As an example, the following query condition can be used to find all locations that are 200m away from the Eiffel Tower: location&lt;geospatial&gt; within (48.8580, 2.2951, 0.200).

When returning fields, the distance formula can be expressed in several ways:

- It can be passed a pair of geospatial points, each represented as a latitude and longitude pair. (Example: distance ('1.0', '2.0', '3.0', '4.0') returns the distance between the geopatial coordinates (1.0, 2.0) and (3.0, 4.0)).
- It can be passed a pair of geospatial fields. (Example: distance (gpsLocation1, gpsLocation2)).
- It can be passed a geospatial field and a geospatial point. (Example: distance(gpsLocation, '1.0', '2.0')).

In all cases, the value returned will be the distance in kilometers between the two geospatial locations.

**Example of a Success Response for Geospatial Queries**
```
1. {
2.     "result" : {
3.         "documents" : \[{
4.                 "key" : "myCountryDocumentKey",
5.                 "versionNumber" : "1.0",
6.                 "deviceLocation" : "48.858,2.2951",
7.                 "\_derivedFields" : {
8.                     "distance(deviceLocation,'48.8588', '2.2965')" : "0.1357"
9.                 },
10.                 "meta.types" : {
11.                     "deviceLocation" : "geospatial"
12.                 }
13.             }
14.         \]
15.     },
16.     "metadata" : {
17.         "status" : "success"
18.     }
19. }
```
**get**

Retrieves a document by key.

| **Parameter** | **Description** |
| --- | --- |
| key | String representing the key of the document to be retrieved. |
| versionNumber | Numeric representing the version number of the document. Optional, defaults to 1. |

**Return value:** JSON object containing all the fields of the requested document. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example: Retrieve a document by key**
```
1. **var** documents = **require**("document");

3. // Return the second version of document with key "myCountryDocumentKey"
4. **return** documents.**get**("myCountryDocumentKey", 2);
```

**Example of a Success Response**
```
1. {  
2.     "result":{  
3.         "key":"myCountryDocumentKey",
4.         "versionNumber":"2.0",
5.         "independenceDay":"1776-07-04T00:00:00+0000",
6.         "attachments":"flag.gif",
7.         "history":"The U.S. is a country of 50 states covering a vast swath of North America, with Alaska in the extreme Northwest and Hawaii extending the nation’s presence into the Pacific Ocean. Major cities include New York, a global finance and culture center, and Washington, DC, the capital, both on the Atlantic Coast; Los Angeles, famed for filmmaking, on the Pacific Coast; and the Midwestern metropolis Chicago.",
8.         "states":\[  
9.             "New York",
10.             "Chicago",
11.             "California",
12.             "Utah"
13.         \],
14.         "name":"USA",
15.         "totalLandArea":"9147593.0",
16.         "creator":"scriptr",
17.         "lastModifiedDate":"2016-08-12T14:29:29+0000",
18.         "lastModifiedBy":"scriptr",
19.         "creationDate":"2016-08-12T14:29:29+0000",
20.         "latest":"1.0",
21.         "meta.types":{  
22.             "independenceDay":"date",
23.             "attachments":"file",
24.             "history":"text",
25.             "states":"string",
26.             "name":"string",
27.             "totalLandArea":"numeric",
28.             "creator":"string",
29.             "lastModifiedDate":"date",
30.             "lastModifiedBy":"string",
31.             "creationDate":"date",
32.             "versionNumber":"numeric",
33.             "key":"string",
34.             "latest":"numeric"
35.         }
36.     },
37.     "metadata":{  
38.         "status":"success"
39.     }
40. }
```

**getAttachment**

Retrieves an attachment from a specific document.

| **Parameter** | **Description** |
| --- | --- |
| key | String representing the key of the document. |
| fileName | String representing the name of the requested file attachment. |
| options | JSON object containing additional options. Optional. |

**Return value:** JSON object containing the properties and content of the file attachment. In case of a failure the appropriate error code and details will be returned in a metadata property.

The options object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| fieldName | String representing the name of the document field that contains the attachment. Optional, defaults to "attachments". |
| versionNumber | Numeric representing the version number of the document from which to retrieve the attachment. Optional, defaults to 1. |

**Example: Retrieve a document attachment**
```
1. **var** documents = **require**("document");
2. **var** getDocument = documents.**get**("myCountryDocumentKey");
3. **if**(getDocument.metadata.status == "success"){
4.     // Get the name of the file to be retrieved
5.     **var** filename = getDocument.result.attachments;
6.     // Retrieve the attachment
7.     **var** result = documents.getAttachment("myCountryDocumentKey", filename, {"fieldName": "attachments", "versionNumber": "1"});
8.     // As a best practice, always check the status of the previous call
9.     **if** (result.metadata && result.metadata.status == "failure") {
10.         **return** result.metadata.errorDetail;
11.     } **else** { // write the file to the response

13.         // you can also choose to trigger the browser's save as/download feature by uncommenting the following line:
14.         //response.setHeader("content-disposition", "attachment;filename=" + filename);

16.         response.setHeader("content-type","image/png");
17.         response.setStatus(200);
18.         // Add the CORS headers
19.         response.addHeaders(configuration.crossDomainHeaders);
20.         response.write(result);
21.     }
22. }
```