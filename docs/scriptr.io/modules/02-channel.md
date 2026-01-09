## **channel Module**

As an alternative to managing channels visually from the Workspace (under the **Settings** | **Channels** tab), scriptr.io offers the channel module which allows you to programmatically manage your channels from within your scripts. These channels are used by the [pubsub](https://www.scriptr.io/documentation#documentation-publishsubscribemodule) and [queue](https://www.scriptr.io/documentation#documentation-queuemodule) modules as topics and queues respectively to exchange messages or invoke scripts.

**create**

Creates a new channel; throws the "DUPLICATE_CHANNEL" exception if a channel with the same name already exists.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name that serves as a unique identifier for the channel. |
| acls | JavaScript object containing the different ACLs that can be set on the channel. Optional. |

The acls object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| subscribeACL | Controls whether you want anonymous or authenticated requests to subscribe to the channel. It can be set to either "AUTHENTICATED" or "ANONYMOUS", it defaults to "AUTHENTICATED". |
| publishACL | Controls whether you want anonymous or authenticated requests to publish to the channel. It can be set to either "AUTHENTICATED" or "ANONYMOUS", it defaults to "AUTHENTICATED". |

**Return value:** JSON object containing the channel name. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** channels = **require**("channel");
2. **var** options = {
3.   "subscribeACL": "anonymous",
4.   "publishACL": "authenticated"
5. }
6. **return** channels.create("myChannel", options);

&nbsp;For free accounts, the maximum allowed number of channels is 20.

**delete**

Deletes a specified channel by name.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name that serves as a unique identifier for the channel. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**get**

Retrieves a specified channel by name.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the channel name. |

**Return value:** JSON object containing the channel. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Example**

1. {
2.     "result" : {
3.         "name" : "MyChannel",
4.         "subscribeACL" : "authenticated",
5.         "publishACL" : "authenticated",
6.         "creationTime" : "2015-08-17T18:17:49.530Z",
7.         "lastModifiedTime" : "2015-08-17T18:17:49.530Z"
8.     },
9.     "metadata" : {
10.         "status" : "success"
11.     }
12. }

**list**

Retrieves the list of all existing channels.

**Return value:** JSON object containing an array that contains all the existing channels along with their details. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Response Example**

1. {
2.     "result" : {
3.         "count" : "2",
4.         "channels" : \[{
5.                 "name" : "channelX",
6.                 "subscribeACL" : "anonymous",
7.                 "publishACL" : "authenticated",
8.                 "creationTime" : "2015-06-30T07:54:18.416Z",
9.                 "lastModifiedTime" : "2015-06-30T07:55:30.063Z"
10.             }, {
11.                 "name" : "channelY",
12.                 "subscribeACL" : "anonymous",
13.                 "publishACL" : "authenticated",
14.                 "creationTime" : "2015-06-30T07:54:18.416Z",
15.                 "lastModifiedTime" : "2015-06-30T07:55:30.063Z"
16.             }
17.         \]
18.     },
19.     "metadata" : {
20.         "status" : "success"
21.     }
22. }

**update**

Updates a channel's ACLs.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name that serves as a unique identifier for the channel. |
| acls | Optional JavaScript object containing the different ACLs that can be set on the channel. |

The acls object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| subscribeACL | Controls whether you want anonymous or authenticated requests to subscribe to the channel. It can be set to either "AUTHENTICATED" or "ANONYMOUS", it defaults to "AUTHENTICATED". |
| publishACL | Controls whether you want anonymous or authenticated requests to publish to the channel. It can be set to either "AUTHENTICATED" or "ANONYMOUS", it defaults to "AUTHENTICATED". |

**Return value:** JSON object containing the channel name. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** channels = **require**("channel");
2. **var** options = {
3.   "subscribeACL": "anonymous",
4.   "publishACL": "authenticated"
5. }

7. **return** channels.update("myChannel", options);
