## **http Module**

Scriptr.io provides the http module that allows you to easily issue any HTTP request from within a script. All you need to do is to require it and invoke its request(options) function.

**request**

Issues an HTTP request.

| **Parameter** | **Description** |
| --- | --- |
| options | JSON object containing the properties of the HTTP request to invoke. |

**Return value:** JSON object containing the HTTP request status, header, body and timeout.

The options object properties are as follows:

<table><tbody><tr><th><p><strong>Property</strong></p></th><th><p><strong>Description</strong></p></th></tr><tr><td><p>url</p></td><td><p>String representing the base URI for the HTTP request. Mandatory.</p></td></tr><tr><td><p>method</p></td><td><p>String representing the HTTP method to use when issuing the call to the remote service. The supported methods are POST, GET, PUT, DELETE, PATCH, HEAD and OPTIONS. Defaults to GET. Optional.</p></td></tr><tr><td><p>params</p></td><td><p>JSON object representing the map of HTTP parameters to be sent to the remote service along with the request.&nbsp;Optional.</p></td></tr><tr><td><p>authCreds</p></td><td><p>Array containing the username and password in case the request requires HTTP&nbsp;Authentication&nbsp;(<em>e.g.</em>, "authCreds": ["<em>username</em>","<em>password</em>"]).&nbsp;Optional.</p></td></tr><tr><td><p>headers</p></td><td><p>JSON object representing the map of HTTP headers to be sent to&nbsp;the remote service along with the request.&nbsp;Optional.</p></td></tr><tr><td><p>files</p></td><td><p>JSON object representing the map of files to be sent to&nbsp;the remote service along with the request.&nbsp;Optional.</p><p><strong>Note</strong>: If you are trying to send a single file&nbsp;in&nbsp;the HTTP request, you can use one of the following approaches:</p><ul><li>The file content can be passed by using plain text in the&nbsp;<strong>bodyString</strong>&nbsp;parameter.</li><li>The single file can be passed alone into the&nbsp;<strong>files</strong>&nbsp;parameter.</li></ul></td></tr><tr><td><p>returnFileRef</p></td><td><p>Boolean value indicating whether or not to return the HTTP response in the value returned from the remote service call.&nbsp;Optional.&nbsp;Defaults to false.</p></td></tr><tr><td><p>bodyString</p></td><td><p>String value representing the body to be passed to the HTTP request.&nbsp;Optional.</p></td></tr><tr><td><p>disableParameterEncoding</p></td><td><p>Boolean value indicating whether or not the request parameters are encoded before being sent in the request. If true, then parameters are not encoded.&nbsp;Optional.&nbsp;Defaults to false.</p></td></tr><tr><td><p>encodeHeaders</p></td><td><p>Boolean value indicating whether request headers are encoded before being sent in the request. If true, then headers are encoded.&nbsp;Optional.&nbsp;Defaults to false.</p></td></tr></tbody></table>

**Example**

1. // require the "http" module
2. **var** http = **require**("http");
3. // build a request. You should at least provide the "url" field
4. **var** requestObject = {
5.     "url" : "<http://api.openweathermap.org/data/2.5/weather>",
6.     "params" : {
7.         "q" : "london,uk"
8.     },
9.     "method" : "GET" // optional if GET
10. }
11. // send the request by invoking the request function
12. // of the http module and store the returned response object
13. **var** response = http.request(requestObject);
14. // get the body of the response as a string
15. **var** responseBodyStr = response.body;
16. // check the status of the response
17. **if** (response.status == "200") {
18.     // manipulate the response headers
19.     **if** (response.headers\["Content-Type"\].indexOf("application/json") > -1) {
20.         **return** JSON.parse(responseBodyStr);
21.     }
22.     **return** responseBodyStr;
23. } **else** {
24.     **return** "Remote API returned an error " + response.status;
25. }

**Example of a Success Response**

1. {
2. "result": {
3.     "status": "200",
4.     "headers": {
5.         "X-Source": "the x-source",
6.         "Access-Control-Allow-Origin": "the CORS configuration, if any",
7.         "Transfer-Encoding": "type of transfer encoding",
8.         "Date": "the response date",
9.         "Access-Control-Allow-Methods": "allowed HTTP methods",
10.         "Access-Control-Allow-Credentials": "true/false",
11.         "Connection": "keep-alive",
12.         "Content-Type": "the HTTP response content type and allowed charset",
13.         "Server": "the HTTP server"
14.     },
15.     "body": "the response body, as a string. Note that this could be a stringified JSON or could contain an error message sent by the remote service."
16.     "timeout": **true**/**false**
17. }

**Example of a Failure Response**

1. {
2.     "metadata": {
3.         "status": "failure",
4.         "errorCode": "HTTP error code",
5.         "errorDetail": "HTTP error details"
6.     }
7. }
