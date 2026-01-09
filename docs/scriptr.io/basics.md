# **Basic Concepts**

## **What is Scriptr.io?**

Scriptr.io is a very powerful cloud service to run your server-side code. With scriptr.io, you use scripts to create the custom back-end APIs needed to power your Internet of Things (IoT) and other projects. Scriptr.io allows you to get productive quickly by providing an integrated web-based environment for developing, running and debugging your code.

## **What are Scripts?**

Scripts are units of execution, after you create a script, it immediately becomes a web service with a unique secure HTTP end-point and ready to run as soon as it is invoked. Scripts can be created to be used as web services or as modules for other scripts. You can invoke directly your new scriptr.io APIs from an IoT, mobile or web project or from other web services.

## **What is the Difference between Using scriptr.io and Running Your Own Servers?**

With scriptr.io, you don't need to handle hosting, deployment, management and upgrade of servers such as application containers, database servers or libraries to integrate with social networks and other web services. When your product goes to production and you need quick reliable scaling, you don't have to figure-out server architecture, scalability strategies, fault-tolerance, etc... You only concentrate on improving the business logic needed to power your project while we make sure that everything else is running smoothly for you.

## **Supported Languages**

For now our script containers support JavaScript ES5. We will be adding other languages in the future.

## **What about Authentication and Security?**

Scripts can be invoked as secure web services using HTTPS and by providing unique secure tokens associated with each account.

## **Invoking scriptr.io URLs**

Scriptr.io scripts are invokable based on the following patterns for the POST and GET methods respectively:

## **POST**
```
1. curl -X POST -F &lt;requestParameter&gt; -d &lt;postBody&gt; -H "Authorization: bearer &lt;authorizationToken&gt;" "<https://api.scriptrapps.io/&lt;scriptName>&gt;"
```

## **GET**
```
1. curl -X GET -H "Authorization: bearer &lt;authorizationToken&gt;" "<https://api.scriptrapps.io/&lt;scriptName&gt;?&lt;requestParameter>&gt;"
```

| **Parameter** | **Description** |
| --- | --- |
| httpMethod | HTTP Verb:  POST, GET. |
| timestamp | A UNIX timestamp denoting the current time when the request is issued. |
| requestParameter | Request parameter specific to what your script is expecting. |
| postBody | "value1":"some value", "value2":"some value", "value3":"some value". |
| authorizationToken | Unique token provided for each account. |
| scriptName | The unique name per account that you have given to the script you want to invoke. |

## **What are Experimental Features?**

At scriptr.io, we keep improving our product to bring you the best. You might encounter several features that our team is still developing - they are labelled with the Experimental tag. You may tinker with them as much as you want, but beware that these experimental features might change, break, or disappear at any time.

## **Getting Started**

### **Open an Account**

You can create a new scriptr.io account from this [page](https://www.scriptr.io/login) by providing your email and a password, or signing in with your [GitHub](http://www.github.com/), [Twitter](http://www.twitter.com/) or [Facebook](http://www.facebook.com/) account.

### **Write Your First Script and Run It**

Once you log in to scriptr.io, you land on your workspace. There are plenty of very useful features in it. For now, we will just go ahead and create our first script by clicking **New Script** at the lower left corner of the screen.

In the scriptr.io editor, simply add a line to return the traditional "Hello world":

```
1. **return** "Hello world";
```

Once done, do not forget to name your script and save it before you execute it. Note that script names should abide by the following rules:

- Must be minimum 2 characters and maximum 1,000 characters long, including any folders.
- Each folder name must be maximum 255 bytes long.
- Can contain alphanumeric characters, underscores (\_), hyphens (-) and periods (.).
- Cannot have two consecutive periods.

Now run your script by clicking **Run** on the top-right part of the editor. Notice the console in the lower half of the screen where you can see the result of the execution. The first line of the console is the curl instruction to issue from an HTTP client to trigger the execution of your script.

### **What Can a Script Do?**

Well, actually, a lot. When using scripts, you have access to a very rich set of features and modules that are provided to you by scriptr.io, such as storage, gateways to IoT platforms, gateways to external web services, social networks, etc... Scripts allow you to implement all the business logic for your IoT solution.

Check the example below where we create a back-end API for a smart home ambiance regulator. Our script does the following:

- Requires (imports) the scriptr.io [http module](https://www.scriptr.io/documentation#documentation-http).
- Retrieves a location from the request it receives (sent by the regulator).
- Invokes a remote weather REST API to obtain the weather forecast for the day.
- Executes a function defined in the script to determine the ambiance according to the obtained temperature and humidity forecast.
- Returns the resulting ambiance to the calling device.

```
1. // import the scriptr.io http module to issue calls to remote APIs
2. **var** http = **require**("http");
3. // retrieve the station parameter from the request
4. **var** station = request.parameters.station; // use location = 260
5. **var** weatherStationAPI = "<http://fawn.ifas.ufl.edu/controller.php/today/obs/>" + station + ";json";
6. // invoke the weatherStationAPI third party API
7. **var** callResult = http.request({
8.         "url" : weatherStationAPI
9.     });
10. // parse the result of the call using regular JSON object
11. **var** weatherInfo = JSON.parse(callResult.body); // returns an array of today's observations
12. **var** latestInfo = weatherInfo\[0\]; // get latest observation, first one on the list
13. **var** temperature2m = latestInfo.t2m;
14. **var** windSpeed = latestInfo.ws;
15. // return the result of the function call
16. **return** getAmbianceConfiguration(temperature2m, windSpeed);
17. // define a bespoke function
18. **function** getAmbianceConfiguration(temp, wind) {
19.     **var** tempCategory = (temp &lt; 18) ? "Cold" : (temp &gt;= 18 && temp <= 25) ? "Cool" : "Hot";
20.     **var** windCategory = wind &lt; 20 ? "No Wind" : (wind &gt; 20 && wind < 50) ? "Windy" : "Strong Wind";
21.     **return** {
22.         "temp" : tempCategory,
23.         "wind" : windCategory
24.     };
25. }
```

## **Authentication and Security**

### **What are Tokens?**

Tokens are credentials that you send with your requests to authenticate yourself and gain access to your protected resources in your scriptr.io account.

Upon registration, scriptr.io provides you with the "scriptr" device and its token which are used within the IDE to execute your scripts. You can also send this token along with your requests in order to authenticate yourself as the owner of the application. Note that you should keep this token secret and not distribute it.

However, you can always create more devices and tokens to control who has access to your application. Managing your devices and tokens can be achieved using the [Device Directory](https://www.scriptr.io/documentation#documentation-device-directory) in your scriptr.io account or programmatically by calling the APIs of the [device module](https://www.scriptr.io/documentation#documentation-device-module).  

### **What is an Anonymous Token?**

Sometimes you will want to allow end users / devices to invoke your scripts without any authentication. Yet you still want to control who / what is able to do so. For that purpose, scriptr.io provides you with an Anonymous Token (similar to API keys) that you can distribute to those users.

### **How to Get Your Tokens?**

Two tokens have automatically been generated for you when you first registered to scriptr.io. You can find them under the Access tab of the Settings menu at the top-right corner of your workspace. Moreover, you can create more tokens from the [Device Directory](https://www.scriptr.io/documentation#documentation-device-directory) section.

### **How to (Re)Generate Your Tokens?**

Under the [Device Directory](https://www.scriptr.io/documentation#documentation-device-directory), in the Device tab, click the regenerate icon in order to create a new token.

After your generate a new token, all requests using the former version will fail to authenticate.

### **How to Use Your Tokens?**

When invoking scriptr.io, you can pass a token to the request in one of the following ways:

- In the request's Authorization header, such as "Auhtorization: bearer _yourToken_".
- In the request's auth_token parameter.