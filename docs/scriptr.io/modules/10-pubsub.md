## **pubsub Module**

Through its publish-subscribe model, scriptr.io provides the two-way communication that allows devices, scripts and other "things" to relay messages among each other. The pubsub module uses channels as an abstract representation of topics over which messages are exchanged. Therefore, in this section, the terms channel and topic are used interchangeably.

**getInstance**

Returns an instance of the pubsub module associated with the specified [channel](https://www.scriptr.io/display/scriptr/documentation). All actions performed against this instance will be executed against its associated channel/topic.

| **Parameter** | **Description** |
| --- | --- |
| channelName | String representing the channel name. |

**Return value:** object representing the instance of the pubsub module associated with a specific topic.

**getStatistics**

Retrieves statistics about a topic. This method can only be used against an instance of the pubsub module in order to be executed against the topic that this instance is bound to. If the Message Broadcasting and Queuing feature is not enabled on the account, it returns the error-code "QUEUING_DISABLED".

**Return value:** JSON object containing the topic statistics. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** topic = pubsub.getInstance("myChannel");
3. **return** topic.getStatistics();

**Example of a response on an account with queuing disabled**

1. {
2.     "metadata": {
3.         "requestId": "d9b8e304-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
4.         "status": "success",
5.         "statusCode": "200"
6.     },
7.     "result": {
8.         "metadata": {
9.             "status": "failure",
10.             "statusCode": 400,
11.             "errorCode": "QUEUING_DISABLED",
12.             "errorDetail": "Upgrade to a premium plan to get access to the queuing feature by contacting support."
13.         }
14.     }
15. }

**Response Example**

1. {
2.     "metadata": {
3.         "requestId": "d04b9842-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
4.         "status": "success",
5.         "statusCode": "200"
6.     },
7.     "result": {
8.         "metadata": {
9.             "status": "success"
10.         },
11.         "result": {
12.             "head_message_timestamp": 1511431786,
13.             "size":{
14.                 "total":134,
15.                 "unacknowledged":3,
16.                 "ready":131
17.             },
18.             "rates":{
19.                 "total":5,
20.                 "unacknowledged":0,
21.                 "ready":5
22.             },
23.             "stats":{
24.                 "deliverGet":{
25.                     "count":4709,
26.                     "rate":15.8
27.                 },
28.                 "ack":{
29.                     "count":4706,
30.                     "rate":15.8
31.                 },
32.                 "redeliver":{
33.                     "count":0,
34.                     "rate":0
35.                 },
36.                 "deliverNoAck":{
37.                     "count":0,
38.                     "rate":0
39.                 },
40.                 "deliver":{
41.                     "count":4709,
42.                     "rate":15.8
43.                 },
44.                 "getNoAck":{
45.                     "count":0,
46.                     "rate":0
47.                 },
48.                 "get":{
49.                     "count":0,
50.                     "rate":0
51.                 },
52.                 "publish":{
53.                     "count":4866,
54.                     "rate":19.8
55.                 }
56.             },
57.             "subscriberCount":2,
58.             "subscribers":\[
59.                 {
60.                     "peerHost": "x.x.x.x",
61.                     "deviceId": "scriptr",
62.                     "peerPort": "53944"
63.                 },
64.                 {
65.                     "peerHost": "y.y.y.y",
66.                     "deviceId": "scriptr",
67.                     "peerPort": "9212"
68.                 }
69.             \]
70.         }
71.     }
72. }

**publish**

Publishes a message to a topic. This method can only be used against an instance of the pubsub module in order to be executed against the topic that this instance is bound to.

| **Parameter** | **Description** |
| --- | --- |
| message | JSON objects representing the message to be distributed to subscribers. |
| useEnvelope | String representing a boolean value determining whether or not to wrap the message in a JSON object containing "from" and "message" attributes. The wrapped message is only delivered to WebSocket subscribers ({"from":"scriptr", "message":"_test-message_"}). Subscribed scripts will still only receive the value of "message" in request.rawBody. Optional, default to false. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** topic = pubsub.getInstance("myChannel");
3. **return** topic.publish("This is a message", **false**);

**subscribe**

Subscribes a script to a topic in order for it to read all the messages published to that topic. When a message is published to a topic, the subscribed script will get executed and will be able to access the message from the request.rawBody property. This method can only be used against an instance of the pubsub module in order to be executed against the topic that this instance is bound to.

You cannot subscribe a device to a topic using this API. You can do so using a WebSocket connection though (refer to the [Real-time Communication](https://www.scriptr.io/documentation#documentation-pubsubws) section).

| **Parameter** | **Description** |
| --- | --- |
| scriptName | String representing the script name to be executed. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** topic = pubsub.getInstance("myChannel");
3. **return** topic.subscribe("myFolder/myScript", "script");

**unsubscribe**

Unsubscribes a script from a topic in order to stop receiving future messages. This method can only be used against an instance of the pubsub module in order to be executed against the topic that this instance is bound to.

| **Parameter** | **Description** |
| --- | --- |
| scriptName | String representing the script name. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** topic = pubsub.getInstance("myChannel");
3. **return** topic.unsubscribe("myFolder/myScript", "script");
