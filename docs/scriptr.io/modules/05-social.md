## **facebook Module**

Scriptr.io provides the facebook module that allows you to interact with Facebook. This module's APIs will use by default the configuration that you have saved in your [Settings](https://www.scriptr.io/documentation#documentation-facebooksettings). However, if you need to use the credentials of a different Facebook app, you can pass them as a parameter to any of the APIs as described below.

<table><tbody><tr><th><p><strong>Parameter</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>credentials</p></td><td><p>Optional parameter of type object, holding the Facebook app's credentials to be used instead of the ones saved in the&nbsp;<a href="https://www.scriptr.io/documentation#documentation-facebooksettings">Settings</a>.</p><p>It can contain the following set of key/value pairs:</p><ul><li><strong>apiKey</strong>: key provided by Facebook when creating the application.</li><li><strong>apiSecret</strong>: secret provided by Facebook when creating the application.</li><li><strong>accessToken</strong>*:&nbsp;token identifying the user, obtained as a result of calling getAccessToken and a successful authorization operation.</li></ul><p><em>* not applicable for getAuthorizationUrl and getAccessToken.</em></p></td></tr></tbody></table>

**callApi**

Calls any node and edge in the Facebook Graph API and returns the result in a JSON string.

| **Parameter** | **Description** |
| --- | --- |
| resourceUrl | String representing the URL identifying the API to call. |
| verb | String representing one of the following method: GET, POST or PUT. |
| parameters | Object holding a set of key/value pairs containing API specific parameters. |

**Return value:** JSON object containing the response from the Facebook API call in JSON format. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getApiCall**

Calls any node and edge in the Facebook Graph API and returns a URL that will retrieve the result when called.

| **Parameter** | **Description** |
| --- | --- |
| resourceUrl | String representing the URL identifying the API to call. |
| verb | String representing one of the following method: GET, POST or PUT. |
| parameters | Object holding a set of key/value pairs containing API specific parameters. |

**Return value:** JSON object containing the url/formEncodedParams that needs to be called to get the network's response for the requested API. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getAuthorizationUrl**

Requests a link to the login screen URL from Facebook. The login screen will ask the user to authorize the app to perform certain actions as specified in the scope parameter.

| **Parameter** | **Description** |
| --- | --- |
| callbackUrl | String representing the URL that Facebook will redirect to after the user authorizes the application.<br><br>**Note**: Facebook requires that the URL ends with a “/”. |
| scope | String representing the scope that the user is requesting the token for. The scope defines the set of permissions the application will have. |
| state | String identifying the current user/request. |

**Return value:** JSON object containing the authorization URL. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getAccessToken**

Retrieves the user access token from Facebook that will be sent with all future requests for authentication.

| **Parameter** | **Description** |
| --- | --- |
| callbackUrl | String representing the callbackUrl specified when calling getAuthorizationUrl. <br><br>**Note**: Facebook requires this parameter, and it should be the same as the one set when calling getAuthorizationUrl . |
| oauthVerifier | String representing the verifier parameter returned by Facebook in response to an authorization. This verifier will be sent as a parameter when calling the callbackUrl specified when calling getAuthorizationUrl. |

**Return value:** JSON object containing the access token. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).




**twitter Module**

Scriptr.io provides the twitter module that allows you to interact with Twitter. This module's APIs will use by default the configuration that you saved in your [Settings](https://www.scriptr.io/documentation#documentation-twittersettings). However, if you need to use the credentials of a different Twitter app, you can pass them as a parameter to any of the APIs as described below.

<table><tbody><tr><th><p><strong>Parameter</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>credentials</p></td><td><p>Optional parameter of type object, holding the Twitter app's credentials to be used instead of the ones saved in the&nbsp;<a href="https://www.scriptr.io/documentation#documentation-twittersettings">Settings</a>.</p><p>It can contain the following set of key/value pairs:</p><ul><li><strong>consumerKey</strong>: key provided by Twitter when creating the application.</li><li><strong>consumerSecret</strong>: secret provided by Twitter when creating the application.</li><li><strong>accessToken</strong>*: token to be paired with the accessTokenSecret, identifying the user. It is obtained as a result of calling getAccessToken and a successful authorization operation.&nbsp;</li><li><strong>accessTokenSecret</strong>*: token to be paired with the accessToken, identifying the user. It is obtained as a result of calling getAccessToken and a successful authorization operation.&nbsp;</li></ul><p><em>* not applicable for getRequestToken and getAccessToken.</em></p></td></tr></tbody></table>

**tweet**

Updates the user's status (i.e., tweets on behalf of the user).

| **Parameter** | **Description** |
| --- | --- |
| tweetString | String representing the new status to post to Twitter. |

**Return value:** JSON object containing the result of the tweet. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. // Require the twitter module in order to be able to call the APIs
2. **var** tw = **require**("twitter");
3. // In this example, we are tweeting to Twitter using the configuration saved in Settings.
4. tw.tweet("Hello from scriptr.io!");
5. // In this example, we are tweeting to Twitter using a different set of configuration than the one saved in Settings.
6. **var** credentials= {
7.    "consumerKey": "yourConsumerKey",
8.    "consumerSecret": "yourConsumerSecret",
9.    "accessToken": "yourAccessToken",
10.    "accessTokenSecret": "yourAccessTokenSecret"
11.  };
12. **return** tw.tweet("Hello from scriptr.io!", credentials);

**getHomeTimeLine**

Retrieves the most recent tweets/retweets existing on the user's timeline. It uses the default options of Twitter's home_timeline API.

**Return value:** JSON object containing the home timeline of the user. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getHomeTimeLineUrl**

Retrieves a URL that when called, returns the most recent tweets/retweets existing on the user's timeline.

**Return value:** JSON object containing the URL to call in order to obtain the home time line of the user. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**callApi**

Calls any API in the Twitter REST APIs and returns the result in a JSON string.

| **Parameter** | **Description** |
| --- | --- |
| resourceUrl | String representing the URL identifying the API to call. |
| verb | String representing one of the following method: GET, POST or PUT. |
| parameters | Object holding a set of key/value pairs containing API specific parameters. |

**Return value:** JSON object containing the response from the Twitter API call in JSON format. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getApiCall**

Calls any API in the Twitter REST APIs and returns a URL which, when called, retrieves the result in a JSON string.

| **Parameter** | **Description** |
| --- | --- |
| resourceUrl | String representing the URL identifying the API to call. |
| verb | String representing one of the following method: GET, POST or PUT. |
| parameters | Object holding a set of key/value pairs containing API specific parameters. |

**Return value:** JSON object containing the url/formEncodedParams that needs to be called to get the network's response for the requested API. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getRequestToken**

Requests a link to the login screen URL from Twitter.

| **Parameter** | **Description** |
| --- | --- |
| callbackUrl | String representing the URL that Twitter will redirect to after the application authorization step. |

**Return value:** JSON object containing the authorization URL and a pair of request token/secret. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**getAccessToken**

Retrieves the user access token from Twitter that will be sent with all future requests for authentication purpose.

| **Parameter** | **Description** |
| --- | --- |
| requestToken | String representing the token identifying the user's request (returned by getRequestToken). |
| requestTokenSecret | String representing the token secret identifying the user's request (returned by getRequestToken). |
| oAuthVerifier | String representing the verifier parameter returned by Twitter in response to an authorization. This verifier will be sent as a parameter when calling the callbackUrl specified when calling getRequestToken. |

**Return value:** JSON object containing a pair of access token/access token secret. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).


## **mobile-push Module**

The mobile-push module offers a mechanism for users to manage their mobile devices' tokens by organizing them into groups.

**getGroup**

Retrieves a specified mobile push notifications group by ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | A unique identifier for the group to retrieve. |

**Return value:** JSON object containing the group properties. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Example**

1. {
2.     "result" : {
3.         "group" : {
4.             "id" : "xxxxx",
5.             "platform" : "iOS",
6.             "configurationId" : "xxxxxxx",
7.             "pushTokens" : \[
8.                 "003DAB991FF6C1EFA5854B504D1B7AFAB8F11187BD37B9EA2D82152884B97B91",
9.                 "933C14E952BD20F68AC2F213BDA266CC5F56F10CA795F8139D5AA3965B9AD717"
10.             \],
11.             "invalidPushTokens" : \[
12.             \]
13.         }
14.     },
15.     "metadata" : {
16.         "status" : "success"
17.     }
18. }

**listGroups**

Retrieves the list of all existing groups. This operation takes no parameters.

**Return value:** JSON object containing an array that contains all the existing groups along with their details. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Example**

1. {
2.     "result" : {
3.         "count" : "2",
4.         "groups" : \[{
5.                 "id" : "xxxxx",
6.                 "platform" : "iOS",
7.                 "configurationId" : "xxxxxxx",
8.                 "pushTokens" : \[
9.                     "003DAB991FF6C1EFA5854B504D1B7AFAB8F11187BD37B9EA2D82152884B97B91",
10.                     "933C14E952BD20F68AC2F213BDA266CC5F56F10CA795F8139D5AA3965B9AD717"
11.                 \],
12.                 "invalidPushTokens" : \[
13.                 \],
14.                 "creationTime" : "2015-06-30T07:54:18.416Z",
15.                 "lastModifiedTime" : "2015-06-30T07:55:30.063Z"
16.             }, {
17.                 "id" : "yyyyy",
18.                 "platform" : "iOS",
19.                 "configurationId" : "xxxxxxx",
20.                 "pushTokens" : \[
21.                     "003DAB991FF6C1EFA5854B504D1B7AFAB8F11187BD37B9EA2D82152884B97A91",
22.                     "933C14E952BD20F68AC2F213BDA266CC5F56F10CA795F8139D5AA3965B9AC717"
23.                 \],
24.                 "invalidPushTokens" : \[
25.                 \],
26.                 "creationTime" : "2015-06-30T07:54:18.416Z",
27.                 "lastModifiedTime" : "2015-06-30T07:55:30.063Z"
28.             }
29.         \]
30.     },
31.     "metadata" : {
32.         "status" : "success"
33.     }
34. }

**deleteGroup**

Deletes a specified mobile push notifications group by ID.

| **Parameter** | **Description** |
| --- | --- |
| id  | The unique identifier of the group to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**addToGroup**

Adds push tokens to a group.

| **Parameter** | **Description** |
| --- | --- |
| id  | The unique identifier of the group. |
| pushTokens | An array containing the push notification tokens to be persisted in the created group. This group will later be used to send notifications to all the push notification tokens that it contains.<br><br>_\* Please note that the maximum number of push tokens allowed is 500._ |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**push**

The push function empowers your scripts to push notifications to iOS and Android devices.

| **Parameter** | **Description** |
| --- | --- |
| devices | Array of device tokens to which you want to send the notification to. |
| message | String representing the payload containing the notification message to be sent. For iOS payload details, please refer to the [The Notification Payload](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW1) [tutorial.](http://developer.apple.com/library/mac/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1)<br><br>For Android, the payload needs to be sent in the following format '{\\"key1\\":\\"value1\\",\\"key2\\":\\"value2\\", ...}'. |
| platform | The targeted platform, _i.e._ the platform of the devices (iOS or Android). |
| isProduction | Boolean value indicating if the push notification should be sent to your production or development application. This parameter is ignored if the notification is meant to be sent to some Android devices and will only be taken into consideration for iOS devices. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**iOS Example**

1. **var** mobpush = **require**("mobile-push");

3. **var** message = '{"aps": { "alert" : "The notification you want to send", "badge" : 5, "sound" : "default"}}';
4. **var** arrayDevices = \["45866802973125d73b144b6c5d9c17b24fb4b09cf4d7bff855e2dd8e852a49c6","4565656d3423e455b45355c34243f3553f3255b235352c55454dd3255e324b24"\];
5. **var** deviceType = "ios";
6. //this is a push to iOS using the development certificate.
7. **var** isProduction = "false";
8. **return** mobpush.push(arrayDevices, message, deviceType, isProduction);
9. //this is a push to iOS using the production certificate.
10. isProduction = "true";
11. **return** mobpush.push(arrayDevices, message, deviceType, isProduction);

**Android Example**

1. **var** mobpush = **require**("mobile-push");

3. **var** message = "The notification you want to send";  
4. **var** arrayDevices = \["APA91bHBCTUA8vITavb-yaB2xZlB93xQB1WcquAyzYBjSAJpiEWslvjl-er-1kdvO2VVu52CpgI-ATcMrMs7rKnjInKO2di7pR9njJLJQxd4AK4vpZvGgkxQB2G5fVurKJgiwFKi7Zyyatd0lVy_8GnhieEHUMUbhagURgSTJ7l-dBES00H2eVI"\];
5. **var** deviceType = "android";
6. **return** mobpush.push(arrayDevices, message, deviceType, **false**);

**pushToGroup**

The pushToGroup function allows you to push notifications directly from within a script to iOS and Android devices.

| **Parameter** | **Description** |
| --- | --- |
| groupId | String representing the identifier for sending push notifications to a particular mobile application. |
| message | String or JSON representing the message you want to send to the devices through your application. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

For information about how to create a group of mobile device tokens, see section [Groups Sub-tab](https://www.scriptr.io/documentation#documentation-pushnotificationgroups).

**removeFromGroup**

Removes push tokens from a group.

| **Parameter** | **Description** |
| --- | --- |
| id  | The unique identifier of the group. |
| pushTokens | An array containing the push notification tokens to be persisted in the created group. This group will later be used to send notifications to all the push notification tokens found in it. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).