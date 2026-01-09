
## **log Module**

To facilitate debugging remote calls from hardware, scriptr.io provides an automatic log of all requests, showing how the request got received (parameters, headers, etc.) and the returned response.

In addition, you can generate custom logs which will appear under logs, grouped by request and only logged based on a user-specified log level. Furthermore, this log view page provides the ability to download the logs, filter them by script name and scheduled scripts.

**Example**

1. **var** log = **require**("log");
2. log.setLevel("DEBUG"); //levels are ERROR | WARN | INFO | DEBUG | OFF
3. log.error("This is the error message of the script");
4. log.warn("This is the warning message of the script");
5. log.info("This is the info message of the script");
6. log.debug("This is the debug message of the script");

- The default level being OFF, remember to always configure your log level as needed. e.g. log.setLevel("DEBUG");
- Scriptr.io retains up to two weeks or 2,560 log entries.
