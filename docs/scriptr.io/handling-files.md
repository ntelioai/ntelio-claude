**Handling Files**

**Sending a File to Your Scripts**

Scriptr.io handles multi-part requests with binary data and thus, you can easily upload files to your scripts.

The below is the curl instruction to send to your script in order to upload a file. Notice that you need to give a name to your file field (myFile in the example).

1. curl -X POST -F myFile=@account.png -H 'Authorization: bearer RzM1RkYwQzc4MjpzY3JpcHRyOjQxODBFRDREQTAxQzc2REU4QjcxNTdEMjE4NUZENEUy' '<https://api.scriptrapps.io/multipart>'

**Retrieving a File from the Request in a Script**

All files sent to a script can be retrieved from the files property of the built-in request object. Check the below code to see how easy it is to manipulate files in scriptr.io.

**Example**

1. // Retrieve content of the "files" field from the built-in "request" object.
2. // The "request" object wraps the HTTP request that triggered our script and has a property called "files".
3. // The "files" property of the "request" object is a map where each file sent to the request is mapped to a field with the same name
4. **var** filesInRequest = request.files;
5. **if** (request.files) {
6.    // When we uploaded the file, we associated it to a field called "myFile"
7.    // this field should end up as a field of the "files" property of the "request" object
8.    // in the below, we check if "files" contains the "myFile" field and if the latter is not empty
9.    **if** (filesInRequest.myFile && filesInRequest.myFile.length > 0) {
10.      // Do something with the file
11.    }
12. }
13. **return** "no file";

**Send the File to a Remote API using the http Module**

In the following, we alter the preceding example by adding a call to a remote API and pass the file that was received in the request.

**Example**

1. // Require the http module
2. **var** http = **require**("http");
3. // Retrieve content of the "files" field from the built-in "request" object
4. **var** filesInRequest = request.files;
5. **if** (filesInRequest) {
6.   // When we uploaded the file, we associated it to a field called "myFile"
7.   // this field should end up as a field of the "files" object
8.   // in the below, we check if "files" contains the "myFile" field and if the latter is not empty
9.   **if** (filesInRequest.myFile && filesInRequest.myFile.length > 0) {

11.     **var** requestObject = {
12.         "url": "<https://www.googleapis.com/drive/v1/files>",
13.         "params": {
14.             "kind": "drive#file",
15.             "id": "myFile",
16.             "title": "someTitle"
17.         },
18.         "files": {"myFile": filesInRequest.myFile},
19.         "method": "POST"
20.     }
21.     // send the request by invoking the request function of the http module and store the returned response object
22.     **var** response = http.request(requestObject);
23.     **return** "got a file";
24.   }
25. }
26. **return** "no file";

**Save file in a scriptr.io document - example**
var documents = require("document");

// Retrieve the country flag image file from the request
var countryFlag = request.files["flag"];

// Define the document content
var fields = {
    // set the document key
    "key": "myCountryDocumentKey",
    // add a field containing a string value called name
    "name": "USA",
    // add a field containing a numeric value called totalLandArea
    "totalLandArea": 9147593,
    // add a field containing a date value called independenceDay
    "independenceDay": "1776-07-04",
    // add a field representing the ID of the device that gathers data related to this document
    "deviceId": "31afe00925b6a",
    // add a field representing the device geo-location
    "deviceLocation": "48.8580,2.2951",
    // add a field containing an array of string value called states
    "states": [
        "New York",
        "California",
        "Chicago",
        "Utah"
    ],
    // add a field containing a text value called history
    "history": "The U.S. is a country of 50 states covering a vast swath of North America, with Alaska in the extreme Northwest and Hawaii extending the nation’s presence into the Pacific Ocean. Major cities include New York, a global finance and culture center, and Washington, DC, the capital, both on the Atlantic Coast; Los Angeles, famed for filmmaking, on the Pacific Coast; and the Midwestern metropolis Chicago.",
    // add the country flag image that got retrieved from the request as an attachment to the document
    "attachments": countryFlag,
    ,
    // define the types of the fields added above to match their content types
    "meta.types": {
        "name": "string",
        "totalLandArea": "numeric",
        "independenceDay": "date",
        "states": "string",
        "deviceId": "string",
        "deviceLocation": "geospatial",
        "history": "text"
    }
};

// Persist the document myCountryDocumentKey
return documents.save(fields);