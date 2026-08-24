---
layout: post
title:  "API's Design - Not pieces of advice"
date:   2024-09-02 23:50:00
categories: ["Design"]
---

Okay, okay, everything depends. But try to forget about it for a while, try to be more material. Doing this maybe you will be a better developer.

### API hierarchy

The “/” should be separating the system hierarchy.

Like this:

```
/users
/users/{userId}
/users/{userId}/orders
/users/{userId}/orders/{orderId}
/products
/products/{productId}
/categories
/categories/{categoryId}
```

### Queries

Queries can help you identify different endpoints. They're our bread and butter overflow.

```jsx
/articles?author=john_doe&tags=technology,science
/events?location=new_york&start_date=2024-09-01
```

These examples demonstrate how queries can be used to filter, sort, and specify parameters for API endpoints:

- Fetching articles by a specific author with certain tags
- Finding events in a particular location starting from a given date

Queries allow for flexible and powerful data retrieval, BUT you can use this to differentiate your endpoints sometimes! (You need to be evil sometimes)

**Response Status Codes**
I hate this part too much, but know this is crucial to have a good communication. 

1. **1xx (Informational)**: The request was received, continuing process.
2. **2xx (Successful)**: The request was successfully received, understood, and accepted.
3. **3xx (Redirection)**: Further action needs to be taken in order to complete the request.
4. **4xx (Client Error)**: The request contains bad syntax or cannot be fulfilled.
5. **5xx (Server Error)**: The server failed to fulfill an apparently valid request.

### Common HTTP Response Status Codes

### **1xx: Informational**

- **100 Continue**: The server has received the request headers, and the client should proceed to send the request body.
- **101 Switching Protocols**: The requester has asked the server to switch protocols, and the server has agreed to do so.

### **2xx: Successful**

- **200 OK**: The request has succeeded. The meaning of success depends on the HTTP method (GET, POST, etc.).
- **201 Created**: The request has been fulfilled, resulting in the creation of a new resource.
- **202 Accepted**: The request has been accepted for processing, but the processing has not been completed.
- **204 No Content**: The server successfully processed the request, and is not returning any content.
- **206 Partial Content**: The server is delivering only part of the resource due to a range header sent by the client.

### **3xx: Redirection**

- **301 Moved Permanently**: The resource requested has been permanently moved to a new URL.
- **302 Found (Previously "Moved Temporarily")**: The resource is temporarily located at a different URL.
- **303 See Other**: The response to the request can be found under another URI using a GET method.
- **304 Not Modified**: The resource has not been modified since the last request.
- **307 Temporary Redirect**: The request should be repeated with another URI; however, future requests should still use the original URI.
- **308 Permanent Redirect**: The resource requested has been moved permanently to a new URI, and future references should use the new URI.

### **4xx: Client Error**

- **400 Bad Request**: The server could not understand the request due to invalid syntax.
- **401 Unauthorized**: The client must authenticate itself to get the requested response.
- **403 Forbidden**: The client does not have access rights to the content.
- **404 Not Found**: The server can not find the requested resource.
- **405 Method Not Allowed**: The request method is known by the server but is not supported by the target resource.
- **409 Conflict**: The request could not be processed because of conflict in the current state of the resource.
- **410 Gone**: The resource requested is no longer available and will not be available again.
- **429 Too Many Requests**: The user has sent too many requests in a given amount of time ("rate limiting").

### **5xx: Server Error**

- **500 Internal Server Error**: The server has encountered a situation it doesn't know how to handle.
- **501 Not Implemented**: The request method is not supported by the server and cannot be handled.
- **502 Bad Gateway**: The server, while acting as a gateway or proxy, received an invalid response from the upstream server.
- **503 Service Unavailable**: The server is not ready to handle the request (e.g., it is down for maintenance or overloaded).
- **504 Gateway Timeout**: The server, while acting as a gateway or proxy, did not get a response in time from the upstream server.
- **505 HTTP Version Not Supported**: The server does not support the HTTP protocol version used in the request.

### Head and body (because I don't wanna know about arms and legs)

Use headers to control cache, organize your authentication or to organize your responses. 
The term organize your responses is not good, sorry, so let me give you an example: 

**Content-Type**

The Content-Type header is used to specify the media type of the resource being sent to the server or being returned to the client. 
This tells the server or client the data type contained in the body of the request or response.

**Accept Header**

The accept header tells the server what type(s) of content the client is prepared to accept in the response. 
The server then tries to provide the response in one of the acceptable formats. If it can't, it may return a **406 Not Acceptable** status.

Now the body, this is the rest, while the headers take care about the the healthy of 
the communication, the body is our envelope, our data container. 
So throw every sort of trash here, try to not leave a mess to other people deal with.

### Take a look in:

[WRML notation](https://github.com/wrml/wrml)

**REST API Design Rulebook: Designing Consistent RESTful Web Service Interfaces (Mark Masse)**

Thanks, bye!
