# Timeseries module

&nbsp;

The ts module allows a user to log, query, and delete records from a ts-store, as well as manage continuous aggregates and refresh policies for the ts-store.

The module provides the following methods:

- [getInstance](#Timeseriesmodule-getInstance)
- [log](#Timeseriesmodule-log)
- [query](#Timeseriesmodule-query)
- [update](#Timeseriesmodule-update)
- [delete](#Timeseriesmodule-delete)
- [createContinuousAggregate](#Timeseriesmodule-createContinuousAggreg)
- [queryContinuousAggregate](#Timeseriesmodule-queryContinuousAggrega)
- [listContinuousAggregates](#Timeseriesmodule-listContinuousAggregat)
- [deleteContinuousAggregate](#Timeseriesmodule-deleteContinuousAggreg)
- [addContinuousAggregatePolicy](#Timeseriesmodule-addContinuousAggregate)
- [refreshContinuousAggregate](#Timeseriesmodule-refreshContinuousAggre)
- [removeContinuousAggregatePolicy](#Timeseriesmodule-removeContinuousAggreg)
- [createIndex](#Timeseriesmodule-createIndex)
- [deleteIndex](#Timeseriesmodule-deleteIndex)
- [addRetentionPolicy](#Timeseriesmodule-addRetentionPolicy)
- [dropChunks](#Timeseriesmodule-dropChunks)
- [removeRetentionPolicy](#Timeseriesmodule-removeRetentionPolicy)

# getInstance

Returns an instance of the ts module associated with a specific store. All actions performed against this instance, such as logging, querying, or deleting records, will be executed against its associated store.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| storeName | String representing a store name.<br><br>Store name must start with a character, can contain only alpha-numeric characters and underscore, and can be between 3 and 32 characters in length. | Yes |     |

# log

Adds a record to the store returned by getInstance.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| fields | A JSON Array of JSON Objects. Each JSON object represents a record containing the fields. The value of each field must be a primitive type (int, boolean, string, ...) or a string representation of a more complex type (such as a JSONObject or JSONArray). | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Example:
```
var timeseries = require("ts").getInstance("DefaultStore");

var records = \[\];

var d = new Date();

for(var i = 0; i < 1000; i++) {

// 2 seconds difference between record timestamps

d.setSeconds(d.getSeconds() + 2);

// remove T, Z, and milliseconds

var ts = d.toISOString().replace("T", " ").replace("Z", "").substring(0,19);

var fields = {

"id": i+1,

"timestamp": ts,

"long": getRandomInRange(-180, 180, 3),

"lat": getRandomInRange(-180, 180, 3),

"grideye": "grid-" + (i+1)

}

records.push(fields);

}

return timeseries.log(records);

// returns a decimal in the range between "from" and "to"

function getRandomInRange(from, to, fixed) {

return (Math.random() \* (to - from) + from).toFixed(fixed) \* 1

}

Response:

{

"metadata" : {

"status" : "success"

}

}
```
# query

Returns the fields of a set of logs from the store, filtered and represented based on the filter parameter:

| **Parameter** | **Description** |
| --- | --- |
| filter | JSON object containing the parameters to be sent along with the query request. |

**Return value:** JSON object containing the array of logs matching the query filter. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The filter object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| fields | A comma-separated string, or a JSON array containing the names of the fields or aggregate functions to be returned. Each field or aggregate function may have an alias representing the name of the field in the returned response, by appending the field name or aggregate function with "as &lt;ALIAS&gt;", where &lt;ALIAS&gt; is any string. If &lt;ALIAS&gt; contains white characters, it must be enclosed in quotes. | No  | \*  |
| query | Zero or more conditions, joined with AND/OR and grouped by parentheses, where a record would be returned if all the conditions are met. | No  |     |
| groupBy | A comma separated list of field names on which the returned records are grouped. | No  |     |
| sort | A comma separated list of field names on which the returned records are sorted. By default, the returned records are sorted in ascending order; however, the order can be specified manually by appending the field names with a space character, followed by either ASC or DESC, to sort in ascending or descending order, respectively. | No  | ASC |
| limit | An integer representing the maximum number of rows to be returned. Defaults to 100. | No  | 100 |
| page | An integer representing the page from which the "limit" number of records are returned. If limit is the default 100, then specifying 1 for page will return the first 100 records, specifying 2 will return the second 100, ... | No  | 0   |

Example:
```
var timeseries = require("ts").getInstance("DefaultStore");

// var fields = "\*";

var filter = {

"query": "id = '1' or id = '2'"

}

return timeseries.query(filter);

Response:

{

"metadata": {

"status": "success"

},

"result": \[

{

"timestamp": 1630087137000,

"id": "1",

"long": 171.191,

"lat": 64.628,

"grideye": "grid-1"

},

{

"timestamp": 1630087139000,

"id": "2",

"long": -53.623,

"lat": 104.352,

"grideye": "grid-2"

}

\]

}

**Query on empty table or no results in response**

{

"metadata": {

"status": "success"

},

"result": \[\]

}
```

# update

Updates one or more logs in the store, based on the values and conditions specified in the parameters.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| fields | A comma separated string containing key/value pairs of the fields to be updated and their values.<br><br>Example: " field1='value1', field2='value2' " | Yes |     |
| criteria | One or more conditions, joined with AND/OR and grouped by parentheses, where a record would be updated if the criteria are met. | Yes |     |

**Return value:** In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Example:
```
var timeseries = require("ts").getInstance("DefaultStore");

var fields = "long='-3.623', lat = '54.352'";

var criteria = "id='2' AND grideye='grid-2'";

return timeseries.update(fields, criteria);

Response:

{

"metadata" : {

"status" : "success"

}

}
```

# delete

Deletes one or more logs from the store, based on the conditions specified in the parameters:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| query | One or more conditions, joined with AND/OR and grouped by parentheses, where a record would be deleted if all the conditions are met. | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Example:
```
var timeseries = require("ts").getInstance("DefaultStore");

var query = "id = '200'";

return timeseries.delete(query);

Response:

{

"metadata" : {

"status" : "success"

}

}

**Delete from a store that does not exist** (should not include the authkey in the table name in the error message)

{

"metadata": {

"status": "failure",

"statusCode": 400,

"errorCode": "INVALID_SQL",

"errorDetail": "ERROR: relation 'TestStore' does not exist Position: 13"

}

}
```

# createContinuousAggregate

Creates a materialized view out of the continuous aggregate specified using the parameters.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of the continuous aggregate. | Yes |     |
| aggregate | JSON object containing the parameters of the query to be executed as a continuous aggregate. | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The filter object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| fields | A comma-separated string, or a JSON array containing the names of the fields or aggregate functions to be returned. Each field or aggregate function may have an alias representing the name of the field in the returned response, by appending the field name or aggregate function with "as &lt;ALIAS&gt;", where &lt;ALIAS&gt; is any string. If &lt;ALIAS&gt; contains white characters, it must be enclosed in quotes. | Yes |     |
| query | Zero or more conditions, joined with AND/OR and grouped by parentheses, where a record would be returned if all the conditions are met. | No  |     |
| groupBy | A comma separated list of field names on which the returned records are grouped. | No  |     |
| noData | A boolean specifying whether to instantly create the continuous aggregate (true), or wait for the data to be aggregated (false). | No  | false |

Example:
```
var timeseriesStore = require("ts-store");

var fields = \[

{

"name": "device",

"datatype": "int",

"nullable": false

},

{

"name": "time",

"datatype": "TIMESTAMP WITHOUT TIME ZONE",

"nullable": false

},

{

"name": "temperature",

"datatype": "DOUBLE PRECISION"

}

\];

// create the store

timeseries.create("TestStore", fields, "time");

var timeseries = require("ts").getInstance("TestStore");

var aggregate = {

"fields": "device, time_bucket('1 day', time) AS bucket, AVG(temperature) AS avgTemp, MAX(temperature) AS maxTemp, MIN(temperature) AS minTemp",

"groupBy": "device, bucket"

}

var name = "month_temperature_summary";

return timeseries.createContinuousAggregate(name, aggregate);

Response:

{

"metadata" : {

"status" : "success"

}

}
```

# queryContinuousAggregate

Returns the records from a continuous aggregate, filtered and represented based on the filter parameter:

| **Parameter** | **Description** |
| --- | --- |
| name | The name of the continuous aggregate to query from. |
| filter | JSON object containing the parameters to be sent along with the query request. |

**Return value:** JSON object containing the array of logs matching the query filter. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The filter object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| fields | A comma-separated string, or a JSON array containing the names of the fields or aggregate functions to be returned. Each field or aggregate function may have an alias representing the name of the field in the returned response, by appending the field name or aggregate function with "as &lt;ALIAS&gt;", where &lt;ALIAS&gt; is any string. If &lt;ALIAS&gt; contains white characters, it must be enclosed in quotes. | No  | \*  |
| query | Zero or more conditions, joined with AND/OR and grouped by parentheses, where a record would be returned if all the conditions are met. | No  |     |
| groupBy | A comma separated list of field names on which the returned records are grouped. | No  |     |
| sort | A comma separated list of field names on which the returned records are sorted. By default, the returned records are sorted in ascending order; however, the order can be specified manually by appending the field names with a space character, followed by either ASC or DESC, to sort in ascending or descending order, respectively. | No  | ASC |
| limit | An integer representing the maximum number of rows to be returned. Defaults to 100. | No  | 100 |
| page | An integer representing the page from which the "limit" number of records are returned. If limit is the default 100, then specifying 1 for page will return the first 100 records, specifying 2 will return the second 100, ... | No  | 0   |

Example:
```
var timeseries = require("ts").getInstance("DefaultStore");

// Check the createContinuousAggregate example to understand the fields used in this query.

var fields = "device, bucket, avgTemp";

var filter = {

"fields": fields,

"query": "avgTemp > 35"

}

var name = "month_temperature_summary";

return timeseries.queryContinuousAggregate(name, filter);

Response:

{

"metadata": {

"status": "success"

},

"result": \[

{

"device": 1,

"bucket": 1630087137000,

"avgTemp": 45.4

},

{

"device": 1,

"bucket": 1630087139000,

"avgTemp: 42.5

}

\]

}
```

# listContinuousAggregates

Lists the names of all continuous aggregates created on the store.

**Return value:** JSON object containing the array of continuous aggregates. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Example:

var timeseries = require("ts").getInstance("TestStore");

return timeseries.listContinuousAggregates();

Response:
```
{

"result": {

"aggregates": \[

{

"name": "month_temperature_summary"

},

{

"name": "day_temperature_summary"

}

\]

},

"metadata": {

"status": "success"

}

}
```
# deleteContinuousAggregate

Deletes the continuous aggregate specified as a parameter.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of the continuous aggregate to be deleted. | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

Example:

var timeseries = require("ts").getInstance("TestStore");

timeseries.deleteContinuousAggregate("month_temperature_summary");

Response:
```
{

"metadata" : {

"status" : "success"

}

}
```
# addContinuousAggregatePolicy

Creates a refresh policy for a continuous aggregate

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a continuous aggregate. | Yes |     |
| options | A JSON Object containing the refresh policy options. | Yes |     |

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| startOffset | A String representing the aggregate start offset relative to the aggregate creation.<br><br>If not specified, the range will start from the beginning of time. | No  |     |
| endOffset | A String representing the aggregate end offset relative to the aggregate creation.<br><br>If not specified, the range will end at the end of time. | No  |     |
| scheduleInterval | A string representing the interval at which the aggregate is refreshed. | Yes |     |

**Note: Should we allow not specifying start or end offset? If you set the start_offset or end_offset to NULL, the range is open-ended and will extend to the beginning or end of time. However, we recommend that you set the end_offset so that at least the most recent time bucket is excluded.**

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var refreshPolicy = {

"startOffset": "30 days",

"endOffset": "1 day",

"scheduleInterval": "1 day"

}

var name = "month_temperature_summary";

return timeseries.addContinuousAggregatePolicy(name, refreshPolicy);

Response:

{

"metadata" : {

"status" : "success"

}

}
```
# refreshContinuousAggregate

Refreshes all buckets of the specified continuous aggregate in the window specified in the options.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a continuous aggregate. | Yes |     |
| options | A JSON Object containing the refresh policy options. | Yes |     |

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| windowStart | A timestamp string in the format "YYYY-mm-dd HH:mm:ss" representing the start of the window to refresh.<br><br>NULL is equivalent to specifying the minimum timestamp value in the store. | No  |     |
| windowEnd | A timestamp string in the format "YYYY-mm-dd HH:mm:ss" representing the end of the window to refresh.<br><br>NULL is equivalent to specifying the maximum timestamp value in the store. | No  |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var options = {

"windowStart": "2021-09-20",

"windowEnd": "2021-09-21"

}

var name = "month_temperature_summary";

return timeseries.refreshContinuousAggregate(name, options);

Response:

{

"metadata" : {

"status" : "success"

}

}
```
# removeContinuousAggregatePolicy

Removes the refresh policy of the specified continuous aggregate.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a continuous aggregate. | Yes |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var name = "month_temperature_summary";

return timeseries.removeContinuousAggregatePolicy(name);

Response:

{

"metadata" : {

"status" : "success"

}

}
```
# createIndex

Creates an index with the specified options on the store returned by getInstance.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| options | A JSON Object containing the index options. | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | The name of the index to be created. | Yes |     |
| fields | The fields or expressions to be indexed. | Yes |     |
| unique | A boolean specifying whether duplicate entries are allowed on the fields specified in the fields option. | No  | false |
| concurrently | A boolean specifying whether to lock the store while creating the index (false) or not (true). | No  | false |
| predicate | A string specifying predicates to use while looking for records to be indexed. | No  |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var options = {

"name": "nameIndex",

"fields": "name",

"concurrently": "false",

"predicate": "timestamp > '2021-10-01 00:00:00'"

}

timeseries.createIndex(options);

Response

{

"metadata" : {

"status" : "success"

}

}
```
# deleteIndex

Deletes an index with the specified options from the store returned by getInstance

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| options | A JSON Object containing the options to be used for deleting the index. | Yes |     |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | The name of the index to be deleted. | Yes |     |
| concurrently | A boolean specifying whether to lock the store while deleting the index (false) or not (true). | No  | false |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var options = {

"name": "nameIndex",

"concurrently": "false"

}

timeseries.deleteIndex(options);

Response

{

"metadata" : {

"status" : "success"

}

}
```
# addRetentionPolicy

Creates a data retention policy for a hypertable or continuous aggregate.

Only one retention policy is allowed per hypertable and one per continuous aggregate.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a hypertable or continuous aggregate. | Yes |     |
| options | A JSON Object containing the retention policy options. | Yes |     |

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| dropAfter | A string representing an interval, where chunks that are fully older than this interval will be dropped. | Yes |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var retentionPolicy = {

"dropAfter": "12 months"

}

var name = "month_temperature_summary";

return timeseries.addRetentionPolicy(name, retentionPolicy);

Response:

{

"metadata" : {

"status" : "success"

}

}
```
Example Failure (add a second retention policy):
```
var timeseries = require("ts").getInstance("TestStore");

var retentionPolicy = {

"dropAfter": "12 months"

}

var name = "month_temperature_summary";

timeseries.addRetentionPolicy(name, retentionPolicy);

return timeseries.addRetentionPolicy(name, retentionPolicy);

Response:

"metadata": {

"status": "failure",

"statusCode": 400,

"errorCode": "INVALID_SQL",

"errorDetail": "ERROR: retention policy already exists for hypertable 'TestStore'"

}
```
# dropChunks

Drops a chunk of data from the specified hypertable or continuous aggregate. A chunk that is fully older than the specified "older_than" option is dropped. If part of the chunk is not older than "older_than", then the chunk will remain.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a hypertable or continuous aggregate. | Yes |     |
| options | A JSON Object containing the options for dropping chunks. | Yes |     |

The options object properties are as follows:

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| older_than | A string representing an interval, where chunks that are fully older than this interval will be dropped. | No  |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var options = {

"windowStart": "2021-09-20",

"windowEnd": "2021-09-21"

}

var name = "month_temperature_summary";

return timeseries.dropChunks(name, options);

Response:

{

"metadata" : {

"status" : "success"

}

}
```
# removeRetentionPolicy

Removes the retention policy of the specified continuous hypertable or continuous aggregate.

| **Parameter** | **Description** | **Required** | **Default** |
| --- | --- | --- | --- |
| name | A string representing the name of a hypertable or continuous aggregate. | Yes |     |

Example:
```
var timeseries = require("ts").getInstance("TestStore");

var name = "month_temperature_summary";

return timeseries.removeRetentionPolicy(name);

Response:

{

"metadata" : {

"status" : "success"

}

}
```

Example failure (remove a retention policy from a hypertable or continuous aggregate that doesn't have one):
```
var timeseries = require("ts").getInstance("TestStore");

var name = "month_temperature_summary";

timeseries.removeRetentionPolicy(name);

return timeseries.removeRetentionPolicy(name);

Response:

"metadata": {

"status": "failure",

"statusCode": 400,

"errorCode": "INVALID_SQL",

"errorDetail": "ERROR: retention policy not found for hypertable 'TestStore'"

}
```

Notes:

1. Postgres identifiers are limited to 63 characters. Identifiers include "names of tables, columns, or other database objects, depending on the command they are used in". (<https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS> )  
    If the table name is the concatenation of the account key and the store name, then, given that the account key is 10 characters, and that a separator character exists between the account key and store name, the remaining permitted length for a store name is 52 characters (63 - 10 - 1)  
    Column names are also limited to 63 characters.

&nbsp;