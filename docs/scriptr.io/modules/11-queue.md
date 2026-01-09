**queue Module**

The queue module allows you to use scriptr.io's queuing system to queue scripts to be executed in a sequential manner, monitor and control your queues. The queue module uses channels as an abstract representation of queues. Therefore, in this section, the terms channel and queue are used interchangeably.

The Message Broadcasting and Queuing feature is a premium add-on that is disabled by default on the free-mium tier.

**getInstance**

Retrieves an instance of the queue module associated with the specified channel. All actions performed against this instance will be executed against its associated channel/queue.

| **Parameter** | **Description** |
| --- | --- |
| channelName | String representing the channel name. |

**Return value:** object containing a queue instance associated with a specific queue. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**clear**

Clears all items in the queue. This method can only be used against an instance of the queue module in order to be executed against the queue that this instance is bound to. If Message Broadcasting and Queuing feature is not enabled on the account, the error "QUEUING_DISABLED" is returned.

**Return value:** JSON object containing the status of the operation, success or failure, in a metadata section. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** queue = **require**("queue").getInstance("myChannel");
2. **return** queue.clear();

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

**getStatistics**

Retrieves statistics about the bound queue. This method can only be used against an instance of the queue module in order to be executed against the queue that this instance is bound to. If Message Broadcasting and Queuing feature is not enabled on the account, the error "QUEUING_DISABLED" is returned.

**Return value:** JSON object containing the queue statistics. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** queue = pubsub.getInstance("testQueue");
3. **return** queue.getStatistics();

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

**Example of a Success Response**

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
56.             }
57.         }
58.     }
59. }

**peek**

Peeks through the queue by returning the specified number of elements from the head of the queue, without removing them. This method can only be used against an instance of the queue module in order to be executed against the queue that this instance is bound to. If Message Broadcasting and Queuing feature is not enabled on the account, the error "QUEUING_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| itemCount | Numeric representing the number of items to be returned from the queue, starting from the head of the queue. If greater than the queue size, it returns all the messages in the queue. Optional, defaults to 1. |
| payloadMaxCharacters | Numeric representing the number of characters of each item's payload to be displayed in the response. Optional, defaults to 50,000. |

**Return value:** JSON object containing queue elements. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Request Example**

1. **var** pubsub = **require**("pubsub");
2. **var** queue = pubsub.getInstance("testChannel");
3. **return** queue.peek({"itemCount": 3});

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
3.         "requestId": "96e1ce8d-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
4.         "status": "success",
5.         "statusCode": "200"
6.     },
7.     "result": {
8.         "metadata": {
9.             "status": "success"
10.         },
11.         "result": \[
12.             {
13.                 "payload_bytes": 34,
14.                 "redelivered": **false**,
15.                 "routing_key": "SjM2PRJCMDREMQ==.testChannel.invoke",
16.                 "message_count": 10846,
17.                 "properties": {
18.                     "user_id": "SjM2PRJCMDREMTpzY3JpcHRyQG5hc3J5",
19.                     "timestamp": 1511532551,
20.                     "correlation_id": "b0bbb781-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
21.                 },
22.                 "payload": "{'method':'scriptName','params':{}}",
23.                 "payload_encoding": "string"
24.             },
25.             {
26.                 "payload_bytes": 34,
27.                 "redelivered": **false**,
28.                 "routing_key": "SjM2PRJCMDREMQ==.testChannel.invoke",
29.                 "message_count": 10845,
30.                 "properties": {
31.                     "user_id": "SjM2PRJCMDREMTpzY3JpcHRyQG5hc3J5",
32.                     "timestamp": 1511532551,
33.                     "correlation_id": "b0bbb781-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
34.                 },
35.                 "payload": "{'method':'myScript','params':{}}",
36.                 "payload_encoding": "string"
37.             },
38.             {
39.                 "payload_bytes": 34,
40.                 "redelivered": **false**,
41.                 "routing_key": "SjM2PRJCMDREMQ==.testChannel.invoke",
42.                 "message_count": 10844,
43.                 "properties": {
44.                     "user_id": "SjM2PRJCMDREMTpzY3JpcHRyQG5hc3J5",
45.                     "timestamp": 1511532551,
46.                     "correlation_id": "b0bbb781-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
47.                 },
48.                 "payload": "{'method':'testScript','params':{}}",
49.                 "payload_encoding": "string"
50.             }
51.         \]
52.     }
53. }

**queue**

Adds the specified script to the head of the queue, optionally passing the specified parameters to be available for the script during execution. This method can only be used against an instance of the queue module in order to be executed against the queue that this instance is bound to. If Message Broadcasting and Queuing feature is not enabled on the account, the error "QUEUING_DISABLED" is returned.

| **Parameter** | **Description** |
| --- | --- |
| scriptName | String representing the name of the script to be queued for execution. Required. |
| params | JSON object containing the parameters to be passed to the script during execution. |

**Return value:** JSON object containing the status of the operation, success or failure, in a metadata section. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**Example**

1. **var** pubsub = **require**("pubsub");
2. **var** queue = pubsub.getInstance("testQueue");
3. **return** queue.queue("testScript");

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
