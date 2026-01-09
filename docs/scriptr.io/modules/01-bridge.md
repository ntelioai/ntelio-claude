## **bridge Module**

In scriptr.io, a bridge is a connector that receives data from a [remote endpoint](https://www.scriptr.io/documentation#documentation-external-endpoints) (previously configured in the [External Endpoint](https://www.scriptr.io/documentation#documentation-external-endpoints) tab) and publishes it to a scriptr.io channel. Once published, the data can be consumed by any subscriber on that [channel](https://www.scriptr.io/documentation#documentation-channel-modulechannelModule).

The bridge module provides scripting functions for managing your bridges.

The Bridge feature is a premium add-on that is disabled by default on the free-mium tier.

**create**

Creates a bridge that receives data from an external endpoint and publishes it to a scriptr.io channel using the specified token. If the Bridge feature is not enabled on the account, the error "BRIDGES_DISABLED" is returned.

Note that during your free trial period, you can only have one active bridge at a time.

| **Parameter** | **Description** |
| --- | --- |
| externalEndpointConfiguration | String representing the name of an external endpoint configuration (previously created in the [External Endpoint](https://www.scriptr.io/documentation#documentation-external-endpoints) tab). |
| channel | String representing the name of the channel that will receive the data pulled from the external endpoint. |
| token | String representing the user/device token that will be used by the bridge to publish data to the channel. |

**Return value:** JSON object containing the "id" of the created bridge, as well as the "externalEndpointConfiguration", "channel" and "token" that were used to create it. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** bridge = **require**("bridge");
2. **return** bridge.create("myConfigurationName", "myChannelName", "QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu");

**Response Example**

1. {
2.     "result" : {
3.         "id" : "&lt;YOUR_BRIDGE_ID&gt;",
4.         "channel" : "myChannelName",
5.         "token" : "QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
6.         "externalEndpointConfiguration" : "myConfigurationName"
7.     },
8.     "metadata" : {
9.         "status" : "success"
10.     }
11. }

**delete**

Deletes a bridge by ID. If the Bridge feature is not enabled on the account, the error "BRIDGES_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the unique identifier of the bridge to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** bridge = **require**("bridge");
2. **return** bridge.**delete**("&lt;YOUR_BRIDGE_ID&gt;");

**get**

Retrieves a bridge by ID. If the Bridge feature is not enabled on the account, the error "BRIDGES_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| id  | String representing the unique identifier of the bridge to be retrieved. |

**Return value:** JSON object containing the "id" of the retrieved bridge along with its properties and status information. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** bridge = **require**("bridge");
2. **return** bridge.**get**("&lt;YOUR_BRIDGE_ID&gt;");

**Response Example**

1. {
2.    "result":{
3.       "id":"&lt;YOUR_BRIDGE_ID&gt;",
4.       "channel":"myChannel",
5.       "status":"Up 10 seconds",
6.       "state":"running",
7.       "token":"QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
8.       "externalEndpointConfiguration":"myEndpoint"
9.    },
10.    "metadata":{
11.       "status":"success"
12.    }
13. }

**list**

Lists all bridges that match the conditions passed in the provided filter. If the Bridge feature is not enabled on the account, the error "BRIDGES_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| filter | JSON object containing the parameters to be sent along with the list request. |

The filter object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| count | Boolean specifying whether or not to return the total count of bridges matching the filter. Optional, defaults to false. |
| resultsPerPage | Numeric value that determines the number of bridges per page to return. Optional, defaults to 50. |
| pageNumber | Numeric value representing the number of the page to be returned. Optional, defaults to 1. |
| channel | String representing the name of an existing channel. If passed, only bridges publishing to this channel will be listed. Optional. |
| externalEndpointConfiguration | String representing the name of an existing external endpoint configuration. If passed, only bridges subscribed to this external endpoint will be listed. Optional. |

**Return value:** JSON object containing the array of bridges matching the specified filter. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example - List all bridges without passing a filter**

1. **var** bridge = **require**("bridge");
2. **return** bridge.list();

**Example - List all bridges publishing to channel "myChannel" and subscribed to the external endpoint called "myEndpoint"**

1. **var** bridge = **require**("bridge");
2. **var** filter = {
3.                 "count":**true**,
4.                 "resultsPerPage": 2,
5.                 "pageNumber": 1,
6.                 "channel":"myChannel",
7.                 "externalEndpointConfiguration":"myEndpoint"
8.             };

10. **return** bridge.list(filter);

**Response Example**

1. {
2.    "result":{
3.       "count":"2",
4.       "bridges":\[
5.          {
6.             "channel":"myChannel",
7.             "token":"QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
8.             "externalEndpointConfiguration":"myEndpoint",
9.             "creationTime":"2019-09-05T05:31:01.232Z",
10.             "lastModifiedTime":"2019-09-05T05:31:01.232Z",
11.             "id":"&lt;YOUR_FIRST_BRIDGE_ID&gt;"
12.          },
13.          {
14.             "channel":"myChannel",
15.             "token":"QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
16.             "externalEndpointConfiguration":"myEndpoint",
17.             "creationTime":"2019-09-16T15:32:01.242Z",
18.             "lastModifiedTime":"2019-09-25T10:31:07.272Z",
19.             "id":"&lt;YOUR_SECOND_BRIDGE_ID&gt;"
20.          }
21.       \]
22.    },
23.    "metadata":{
24.       "status":"success"
25.    }
26. }

**listStatuses**

Lists the bridges and information about their states if they match the conditions passed in the provided filter. If the Bridge feature is not enabled on the account, the error "BRIDGES_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| filter | JSON object containing the parameters to be sent along with the listStatuses request. |

The filter object properties are as follows:

| **Property** | **Description** |
| --- | --- |
| count | Boolean specifying whether or not to return the total count of bridges matching the filter. Optional, defaults to false. |
| resultsPerPage | Numeric value that determines the number of bridges per page to return. Optional, defaults to 50. |
| pageNumber | Numeric value representing the number of the page to be returned. Optional, defaults to 1. |
| channel | String representing the name of an existing channel. If passed, only bridges publishing to this channel will be listed. Optional. |
| externalEndpointConfiguration | String representing the name of an existing external endpoint configuration. If passed, only bridges subscribed to this external endpoint will be listed. Optional. |

**Return value:** JSON object containing the array of bridges matching the specified filter along with their respective states ("created", "restarting", "running", "removing", "paused", "stopped" and "dead") and statuses. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example - List all bridges without passing a filter**

1. **var** bridge = **require**("bridge");
2. **return** bridge.listStatuses();

**Example - List all bridges publishing to channel "myChannel" and subscribed to the external endpoint called "myEndpoint"**

1. **var** bridge = **require**("bridge");
2. **var** filter = {
3.                 "count":**true**,
4.                 "resultsPerPage": 2,
5.                 "pageNumber": 1,
6.                 "channel":"myChannel",
7.                 "externalEndpointConfiguration":"myEndpoint"
8.             };

10. **return** bridge.listStatuses(filter);

**Response Example**

1. {
2.    "result":{
3.       "count":"2",
4.       "bridges":\[
5.          {
6.             "channel":"myChannel",
7.             "state":"stopped",
8.             "status":"Exited (0) 1 week ago",
9.             "token":"QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
10.             "externalEndpointConfiguration":"myEndpoint",
11.             "creationTime":"2019-09-05T05:31:01.232Z",
12.             "lastModifiedTime":"2019-09-05T05:31:01.232Z",
13.             "id":"&lt;YOUR_FIRST_BRIDGE_ID&gt;"
14.          },
15.          {
16.             "channel":"myChannel",
17.             "state":"running",
18.             "status":"Up 38 minutes",
19.             "token":"QUNDT1VOVEtFWTp1c2VyTmFtZTpteXRva2Vu",
20.             "externalEndpointConfiguration":"myEndpoint",
21.             "creationTime":"2019-09-16T15:32:01.242Z",
22.             "lastModifiedTime":"2019-09-25T10:31:07.272Z",
23.             "id":"&lt;YOUR_SECOND_BRIDGE_ID&gt;"
24.          }
25.       \]
26.    },
27.    "metadata":{
28.       "status":"success"
29.    }
30. }
