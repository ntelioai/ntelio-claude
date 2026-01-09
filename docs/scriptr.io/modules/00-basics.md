# **Modules**

script.io is built with modular design in mind. A module is a reusable piece of software that defines variables, functions and/or objects that you can require and use in your own scripts. While some of the modules you will be using are provided by scriptr.io or other third parties, called the _core modules_, you also have the possibility to create your own modules which are regular scriptr.io scripts. The difference with other scripts is that it should not be directly invoked through HTTP requests and hence, they usually expose fields, functions or classes only.

In order to add a module to your script, i.e., be able to use the functions and/or objects it defines, just use the [require](https://www.scriptr.io/documentation#documentation-require)("_module_") instruction.

**Definition of the homeAutomation module**
```
1. **function** HomeAutomationManager() {
2.   **this**.rooms = \[
3.     {"master": {"temperature": 22, "light": **false**}},
4.     {"kids": {"temperature": 22, "light": **false**}},
5.     {"living": {"temperature": 22, "light": **false**}}
6.   \];
7.   **this**.doors = \[{"font":**false**}, {"garage":**false**}\];
8. }
9. HomeAutomationManager.prototype.getReport = **function**() {
10.   **return** "Rooms: " + "\\n" +  JSON.stringify(**this**.rooms) + "\\nDoors:\\n" + JSON.stringify(**this**.doors);
11. }
```
**Definition of the getReportAPI script that requires the homeAutomation module**
```
1. **var** homeAutomation = **require**("./homeAutomation");
2. **var** homeAutomationMgr = **new** homeAutomation.HomeAutomationManager();
3. **return** homeAutomationMgr.getReport();
```
Note that most scriptr.io functions return a JSON object with the following two properties:
```
1. **result:** containing the actual return result of the function.
2. **metadata:** containing the status of the operation and any error details in case of failure.
```
**Example of a Typical Success Response**
```
1. {
2.     "result" : {
3.         "device" : {
4.             "id" : "AB825CE1520F"
5.         }
6.     },
7.     "metadata" : {
8.         "status" : "success"
9.     }
10. }
```
**Example of a Typical Failure Response**
```
1. {
2.     "metadata" : {
3.         "status" : "failure",
4.         "statusCode" : 400,
5.         "errorCode" : "INVALID_PARAMETER_VALUE",
6.         "errorDetail" : "Invalid value for fieldName \[acl\]."
7.     }
8. }
```