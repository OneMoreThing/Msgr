Msgr
====

Operation
---------

The server is a basic webserver which passes JSON data over HTTP. The server also has a database connection, 
as well as handles connections to Apple for push notifications. When a client initializes a connection, it 
will authenticate and a session will be created. When a client pushes a message to the server, a connection 
to APNS will be created, and the message will be pushed to the other user. 

No message history is stored on the server, this must be stored on the client side. All messages to devices 
will be pushed through APNS, not HTTP. Because messages are not stored server side, delivery is unreliable. 
There are no read receipts or confirmation messages. 


Message format
--------------

###Messages

Outgoing messages (from client) have the following 'headers':

        UserFrom: <sending user>
        Password: <users password>
        UserTo: <destination username>
        Message: <message text>

The server will reply with a standard 200 OK, or 403 Forbidden, depending if authorization passes or not. 
These messages are sent to `/message`. Failure to post these headers will give 400 Bad Request.


Incoming messages have the following 'headers' in the payload:

        UserFrom: <sending user>
        Message: <message text>

###Registration *

Upon app launch, the user will be prompted to register or log in an account. A message will be passed to 
`/register` or `/login` with the following headers:

        Username: <users id>
        Password: <password>
        DeviceID: <device id>

The server will reply with either 200 OK or 403 Forbidden. Failure to post these headers will give 400 Bad
Request.On the server side, the device ID in the database should be updated to match the posted device ID,
upon login. After login, the users credentials will be saved in the app. Login will only need to be done 
once. 


###Getting Contacts

Once login is complete, a message will be sent to the `/contacts` with the headers:

        Username: <users id>
        Password: <password>

The server will respond with 200 OK and a JSON array of the contacts, or 403 Forbidden.

###Adding Contacts *

To add a new contact, a message will be sent to `/add` with headers:

        Username: <users id>
        Passwword: <password>
        AddUser: <user to add>

If the users are already friends, the server returns 200 OK. If not, a push notification
will be sent to the second user, as a standard message, but with the additional 
"AddRequest" header:

        UserFrom: <sending user>
        Message: <message text>
        AddRequest: true

The recipient client will return a post to `/add` to confirm, getting 200 OK in response.


Implementation Considerations
-----------------------------

* If ignored, push notifications are lost (as of iOS 4.3). When the client launches it should fetch the most recent 
messages from the server. This server does not store messages, so the database will need to be expanded.
* HTTP requests should run over HTTPS. This can easily be changed, thanks to Node.js.
* Server could implement a persistent connection system, for allowing an authenticated state. This would cut back on 
data transfer, and the UserFrom and Password headers could be eliminated. 


Database
--------

The database requires only two tables. 

msgr_users(username,password,deviceid):

        CREATE TABLE msgr_users(username VARCHAR(12), PRIMARY KEY(username), password VARCHAR(20), deviceid VARCHAR(64));

msr_contacts(username,friend):

        CREATE TABLE msgr_contacts(username VARCHAR(12), PRIMARY KEY(username), friend VARCHAR(12));


Requirements
------------

Server

* [Node.js 0.4.3](http://www.nodejs.org)
* [node-apn](https://github.com/argon/node-apn)
* [node-mysql-native](https://github.com/sidorares/nodejs-mysql-native)

Client

* [JSON Framework](http://stig.github.com/json-framework/)
* [Three20](http://three20.info/)
    




