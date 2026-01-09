# **Built-in Objects & Functions**

Below are all the built-in objects and functions that are directly available in your scripts without having to require them.

## **console**

The console logger is a scriptr.io built-in object used to debug your scripts allowing you to output your logs directly to the console.

The available logging functions are error(), warn(), info(), log() and debug() (note that the info and log functions have the same log level). You will also need the setLevel() function that allows you to control the minimum level that will be output to the console. By default, the level is set to DEBUG.

**Example**

1. console.setLevel("INFO"); //levels are ERROR | WARN | INFO | DEBUG | OFF

3. console.error("This is the error message of the script");
4. console.warn("This is the warning message of the script");
5. console.info("This is the info message of the script");
6. console.debug("This is the debug message of the script");

## **isGroupInAcl**

This built-in function checks if a group is granted permission by a specific ACL.

| **Parameter** | **Description** |
| --- | --- |
| groupId | String representing a group name. |
| acl | String representing an ACL policy, which consists of a semi-colon separated list of users, devices and/or groups. |

**Returned result:** a boolean value specifying whether or not the group is granted permission.

**Example**

1. **return** isGroupInAcl("subscribers", **require**("pubsub").getChannel("myChannel").result.subscribeACL);

## **isIdInAcl**

This function checks if a device or user is granted permission by a specific ACL.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing a user or device identifier. |
| acl | String representing an ACL policy, which consists of a semi-colon separated list of users, devices and/or groups. |

**Returned result:** a boolean value specifying whether or not the resource is granted permission.

**Example**

1. **var** pubsub = **require**("pubsub");
2. // Check if the current user has permission to publish messages to the channel called "myChannel"
3. **if** (isIdInAcl(request.user.id, pubsub.getChannel("myChannel").result.publishACL)) {
4.     // publish message to "myChannel"
5.     pubsub.publish("myChannel", "Hello Device!");
6. }

## **jsonToXml**

This function converts a JSON object or string to an XML string.

| **Parameter** | **Description** |
| --- | --- |
| json | A JSON object or string to be converted to an XML string. |

**Return value:** an XML string.

## **publish**

Publishes a message to a specified channel that will be sent to its subscribers.

| **Parameter** | **Description** |
| --- | --- |
| channelName | &nbsp;String representing the name that serves as a unique identifier for the channel. |
| message | JSON, including objects, strings, and numbers, representing the message to be distributed to subscribers. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **return** publish("myChannel", "Hello Device!");

## **push**

The built-in push function empowers your scripts to push notifications to iOS and Android devices.

| **Parameter** | **Description** |
| --- | --- |
| devices | Array of device tokens to which you want to send the notification to. |
| message | String representing the payload containing the notification message to be sent. For iOS payload details, please refer to the [The Notification Payload](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW1) [tutorial.](http://developer.apple.com/library/mac/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1)<br><br>For Android, the payload needs to be sent in the following format '{\\"key1\\":\\"value1\\",\\"key2\\":\\"value2\\", ...}'. |
| platform | The targeted platform, _i.e._ the platform of the devices (iOS or Android). |
| isProduction | This parameter is ignored if the notification is meant to be sent to some Android devices and will only be taken into consideration for iOS devices. It is a boolean value indicating if the push notification should be sent to your production or development application. Defaults to true. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Start by [setting up your account](https://www.scriptr.io/documentation#documentation-pushnotification) and then simply follow these examples:

**iOS Example**

1. **var** message = '{"aps": { "alert" : "The notification you want to send", "badge" : 5, "sound" : "default"}}';
2. **var** arrayDevices = \["45866802973125d73b144b6c5d9c17b24fb4b09cf4d7bff855e2dd8e852a49c6","4565656d3423e455b45355c34243f3553f3255b235352c55454dd3255e324b24"\];
3. **var** deviceType = "ios";
4. //this is a push to iOS using the development certificate.
5. **var** isProduction = "false";
6. **return** push(arrayDevices, message, deviceType, isProduction);
7. //this is a push to iOS using the production certificate.
8. isProduction = "true";
9. **return** push(arrayDevices, message, deviceType, isProduction);

**Android Example**

1. **var** message = '{"Content":"The notification you want to send"}';  
2. **var** arrayDevices = \["APA91bHBCTUA8vITavb-yaB2xZlB93xQB1WcquAyzYBjSAJpiEWslvjl-er-1kdvO2VVu52CpgI-ATcMrMs7rKnjInKO2di7pR9njJLJQxd4AK4vpZvGgkxQB2G5fVurKJgiwFKi7Zyyatd0lVy_8GnhieEHUMUbhagURgSTJ7l-dBES00H2eVI"\];
3. **var** deviceType = "android";
4. **return** push(arrayDevices, message, deviceType);

## **pushToGroup**

The built-in pushToGroup function allows you to push notifications directly from within a script to iOS and Android devices, by passing the following parameters:

| **Parameter** | **Description** |
| --- | --- |
| groupId | String representing the identifier for sending push notifications to a particular mobile application. |
| message | String or JSON representing the message you want to send to the devices through your application. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

For information about how to create a group of mobile device tokens, see section [Groups Sub-tab](https://www.scriptr.io/documentation#documentation-pushnotificationgroups).

## **request**

You can use the request built-in object to retrieve the HTTP request parameters as well as other useful information.

| **Property** | **Description** |
| --- | --- |
| files | A map containing file objects representing the files sent as request's parameters. Each file object has the following attributes: "paramName", "fileName", "size", "contentType", and "content". |
| headers | A map containing the HTTP request headers: "host", "content-length", "accept", "origin", "user-agent", "authorization", "content-type", "referrer", "accept-encoding", "accept-language", "x-forwarded-for", "x-forwarded-scheme", "connection". |
| id  | Request identifier. |
| method | Name of the HTTP method used for the request. |
| parameters | A map containing the request's parameters. |
| pathInfo | String containing the part of the URI starting after the script name. |
| queryString | Query string passed to the request. |
| rawBody | The HTTP request body that carries the actual message data. |
| scriptName | String representing the script name. |
| URI | String containing the request URI starting from the script name. |

## **require**

The built-in require function allows you to include a module inside your script in order to be able to use its functions and objects. Refer to the [modules](https://www.scriptr.io/documentation#documentation-modules) section for more details.

| **Parameter** | **Description** |
| --- | --- |
| moduleName | The name of the module to include in the current script. |

When adding a core module to your script, you should require it by name (i.e., require("http")) while requiring your own modules should be done by specifying an absolute path (i.e., require("/myOwnModule")) or the relative path (i.e., require("../../anotherModule") ).

**Example**

1. // require the "http" module
2. **var** http = **require**("http");
3. // After requiring the module "http" you can use its function "request"
4. **var** response = http.request({"url": "<http://api.openweathermap.org/data/2.5/weather","params>": {"q":"london,uk"}});
5. **return** response;

## **response**

You can use the response built-in object to intercept the HTTP response stream and manipulate it before it gets sent to the client. However, make sure to set the response CORS headers whenever you call any of the response object's methods.

**Example**

1. response.write("hello");
2. // whenever you manipulate the response object make sure to add your CORS settings to the header
3. response.addHeaders(configuration.crossDomainHeaders);
4. response.close();

The response object supports the following methods:

### **addHeaders**

This method allows adding a set of headers to the response.

| **Parameters** | **Description** |
| --- | --- |
| headers | Map of HTTP response headers represented as a JSON object. |

### **close**

This method flushes the data to the stream then closes it. No data can be written to the response after this operation.  

### **flush**

This method flushes the output stream and forces any buffered output bytes to be written out.

### **setHeader**

This method allows setting the value of a specified response header.

| **Parameters** | **Description** |
| --- | --- |
| name | String representing the header name. |
| value | String representing the header value. |

### **setStatus**

This method allows setting the status code of the response.

| **Parameters** | **Description** |
| --- | --- |
| status | Integer representing the HTTP response status code. |

### **write**

This method allows writing a string to the body of the response.

| **Parameters** | **Description** |
| --- | --- |
| body | String representing the body content of the response. |

## **runAs**

By default, everything you do within a script runs with owner privileges. However, if you wish to execute APIs using limited privileges, you can wrap your code inside a function, pass it to runAs() and specify the ID of the device that will be used to invoke that code.

| **Parameter** | **Description** |
| --- | --- |
| function | Function wrapping the code you need to run using the privileges of the device with the specified id. |
| id  | String representing the ID of the device to be used to run the function. |

**Return value:** null.

**Example**

1. /\* In the following example, executing this script as the scriptr device will succeed.
2.  \* However, if you use a different device that doesn't have the permission to save a document in the DefaultStore,
3.  \* the documents.create() function will fail with a PERMISSION_DENIED exception.
4.  \*/
5. **var** documents = **require**("document");
6. **var** stores = **require**("store");
7. // Retrieve the id of the device issuing the request
8. **var** userId = request.user.id;
9. // Update the ACL on the DefaultStore to allow the scriptr device to create documents
10. stores.update("DefaultStore", {"saveDocumentACL":"scriptr"});
11. // The code wrapped in the following function will be executed using the privileges of the device issuing the request (userId)
12. runAs(**function**(){
13. // Create a document with the privileges of the device issuing the request
14.  documents.create({"myfieldName":"value"});
15. }, userId);

## **schedule**

The built-in function schedule allows you to schedule a script to be executed at a specific date or periodically at fixed dates or intervals. Scheduling a script creates a document in the "[DefaultStore](https://www.scriptr.io/documentation#documentation-store)" store representing the trigger for the script.

| **Parameter** | **Description** |
| --- | --- |
| scriptName | String representing the name of the script to execute. |
| trigger | String or Date object indicating when the script will be executed. The script can be scheduled to run at a specific date by passing a Date object or a date string with an ECMA standard ISO date format yyyy-MM-dd'T'HH:mm:ss.SSS'Z' (ex. 2015-09-08T14:28:41.093Z). Alternatively, it can be scheduled to run periodically at fixed dates or intervals by passing a string representing a [cron expression](https://www.scriptr.io/documentation#documentation-CronExpressionSpecs). |

**Return value:** handle to the trigger which can be used later to cancel it. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. schedule("myScript", "2016-09-08T14:28:41.093Z"); // "myScript" will run on the 8th of September 2016 at 14:28 UTC
2. schedule("myScript", "30 7 ? \* MON-FRI"); // "myScript" will run every weekday at 7:30 AM

## **sendMail**

The built-in sendMail function allows you to easily send emails from your scripts by directly calling it using the following parameters:

| **Parameter** | **Description** |
| --- | --- |
| to  | Recipient's email address. |
| fromName | Sender's name _e.g._, John Smith. |
| subject | Email's subject. |
| body | Email's body (sent as content type text/html). |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** time = **new** Date();
2. **var** mailBody = "Hello,&lt;br&gt;An intrusion was detected at " + time + "&lt;br&gt;";
3. mailBody += "&lt;a href='<https://api.scriptrapps.io/discard?id=>" + request.id + "'&gt;Click here to discard the alert&lt;/a&gt;";
4. **var** emailConfig = {
5.   "to": "<joe.developer@scriptr.io>",
6.   "fromName": "Joe",
7.   "subject": "Intrusion alert",
8.   "body": mailBody
9. };
10. **return** sendMail(emailConfig.to, emailConfig.fromName, emailConfig.subject, emailConfig.body);

## **storage**

script.io provides developers with means to persist data from their scripts using the built-in storage object that exposes two levels of persistence: local and global.

| **Property** | **Description** |
| --- | --- |
| local | Allows you to store data that is only available to the script that persisted the data. |
| global | Allows you to store data that is available to all your scripts. |

**Local Storage**

The local storage is accessible through "storage.local". To manipulate data contained in the local store of a script use the following notations:

**Example**

1. // we persist (create/update) the "vehicleCount" field
2. // in the local storage
3. storage.**local**.vehicleCount = 100;
4. // we read the persisted "vehicleCount" field
5. // from the local storage
6. **var** vehicles = storage.**local**.vehicleCount;
7. // we delete the "vehicleCount" field
8. // from the local storage
9. **delete** storage.**local**.vehicleCount;

**Example**

1. **var** vehiclesPerSecond = request.parameters.vehiclesPerSecond;
2. **var** lastCount = storage.**local**.lastCount;
3. **if** (lastCount && lastCount < vehiclesPerSecond) {
4.     storage.**local**.lightDuration = storage.**local**.lightDuration - 10;
5. }
6. **if** (lastCount && lastCount > vehiclesPerSecond) {
7.     storage.**local**.lightDuration = storage.**local**.lightDuration + 10;
8. }
9. broadcast(storage.**local**.lightDuration);
10. storage.**local**.lastCount = vehiclesPerSecond;
11. **return** storage.**local**.lastCount;
12. **function** broadcast(value) {
13.     // broadcast this value to all traffic lights
14. }

**Global Storage**

The global storage is accessible through storage.global. To manipulate global fields within your scripts use the following notations:

**Example**

1. // we persist (create/update) the "traffic" field
2. // in the global storage
3. storage.**global**.traffic = **new** Array();
4. // we read the persisted "traffic" field
5. // from the global storage
6. **var** traffic = storage.**global**.traffic;
7. // we delete the "traffic" field
8. // from the global storage
9. **delete** storage.**global**.traffic;

**Example**

1. **var** vehiclesPerSecond = request.parameters.vehiclesPerSecond;
2. **var** lastCount = storage.**local**.lastCount;
3. **if** (lastCount && lastCount < countOfVehiclesPerSecond) {
4.     storage.**local**.lightDuration = storage.**local**.lightDuration - 10;
5. }
6. **if** (lastCount && lastCount > countOfVehiclesPerSecond) {
7.     storage.**local**.lightDuration = storage.**local**.lightDuration + 10;
8. }
9. broadcast(storage.**local**.lightDuration);
10. storage.**local**.lastCount = vehiclesPerSecond;
11. // We need to persist the evolution of the traffic as a global field, i.e. shared by all scripts
12. **if** (!storage.**global**.traffic) {
13.   storage.**global**.traffic = **new** Array();
14. }
15. **var** data = {
16.   "time": **new** Date().getHours(),
17.   "vehicles": storage.**local**.lastCount
18. }
19. **var** traffic = \[data\].concat(storage.**global**.traffic);
20. storage.**global**.traffic = traffic;
21. **return** storage.**local**.lastCount;
22. **function** broadcast(value) {
23.     // broadcast this value to all traffic lights
24. }

## **tweet**

The built-in tweet function allows you to tweet directly from within a script by passing the following parameter:

| **Parameter** | **Description** |
| --- | --- |
| tweetString | String representing the new status to post to Twitter using the app's credentials configured in your [Settings](https://www.scriptr.io/documentation#documentation-twittersettings). |

**Return value:** JSON object containing the result of the tweet. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

## **unschedule**

The built-in function unschedule deletes the script's trigger corresponding to the unique handle passed as a parameter. A handle to a script's trigger is returned by the [schedule](https://www.scriptr.io/documentation#documentation-schedule) function upon scheduling this script. Deleting a script's trigger removes its associated document from the "[DefaultStore](https://www.scriptr.io/documentation#documentation-store)" store.  

| **Parameter** | **Description** |
| --- | --- |
| handle | String representing the script's trigger to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. unschedule("5B1EB7D483D3CEE3B443AA841607C132");

## **xmlToJson**

This function converts an XML string to a JSON object.

| **Parameter** | **Description** |
| --- | --- |
| xml | XML string to be converted to a JSON object. |

**Return value:** JSON object.