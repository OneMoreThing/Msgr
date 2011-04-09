
var sys = require('sys');
var http = require('http');
var apns = require('apn');
var db = require('mysql-native').createTCPClient('db.cs.dal.ca',3306);

/* Configuration variables
 * FILL THESE IN APPROPRIATELY
 */
var HOST_IP = '192.168.0.116';
var PORT = 12345;
var DB_DB = 'cbaltzer'; 
var DB_USER = 'cbaltzer'; 
var DB_PASS = '';
var APNS_GATEWAY = 'gateway.sandbox.push.apple.com';

var apnsConnection;

/* Initialization */
function setup() {
    // Database 
    db.auto_prepare = true;


    // APNS connection
    var apns_options = { cert: 'msgr_dev.pem' 
                        , key:  'msgr_key.pem' 
                        , gateway: APNS_GATEWAY 
                        , port: 2195 
                        , enhanced: true 
                        , errorCallback: apns_error
                        , cacheLength: 5 
                        };
    apnsConnection = new apns.connection(apns_options);



    // Web server
    var ws = http.createServer(httpHandler);
    ws.listen(PORT, HOST_IP);
}


/* Database wrappers */
function sqlQuery(query, handler) {
    db.auth(DB_DB, DB_USER, DB_PASS);
    handler(db.query(query));
    db.close();
}

function print_rows(cmd) {
    console.log("print rows");
    cmd.addListener('row', function(r) {
        console.log(r);
    });
}

function authorize(cmd) { 
    cmd.addListener('row', function(r) {
        return true;
    });
    cmd.addListener('end', function(r) {
        return false;
    });
}

function checkAuth(user, pass) {
    /* CAN'T BECAUSE OF SQL SERVER
    db.auth(DB_DB, DB_USER, DB_PASS);
    var isA = authorize(db.execute("select username from msgr_users where username=? and password=?", [user, pass]));
    print_rows(db.query("select * from msgr_users"));
    db.close();
    */
    var users = {   "cbaltzer": "cbaltzer", 
                    "test1": "test1", 
                    "test2": "test2" 
                };
    
    if (users[user] == pass) {
        return true;
    } else {
        return false;
    }
}

function findDeviceID(user) {
    /* DB SERVER SO FRUSTRATING 
     */
    var devIDs = {  "cbaltzer": "fc71fe3ef654bb356e2858418ef89ac85d4867708d3e0294044c9b72ef2ffe46",
                    "test1": "ad38d0fb523e3edab4f35fe1306e548077d323d6555d51df434b2bf0a5c361cc",
                    "test2": "ec13773863bdd44d6d052cb4af8fd76a4de5cb1765be00c3307a758c54d076a8"
                };
    return devIDs[user];
}
    


/* APNS handlers
 */

function apns_error (error) {
    error.addListener('error', function(e) {
        console.log("APNS Error");
    });
}



/* Web Server handler
 * 
 */
function httpHandler(req, res) {
    req.setEncoding('utf8');

    var body = ""
    req.addListener('data', function (data) {
        body += data;
    });

    req.addListener('end', function (data) {

        if (req.url == "/message") {
            if (body == "") {
                res.writeHead(400, {'Content-Type': 'text/plain'});
                res.end();
            } else {
                var message = JSON.parse(body);
                console.log(message);
                messageHandler(res, message);
            }
        } else if (req.url == "/register") {
            console.log("/register");
        } else if (req.url == "/contacts") {
            if (body == "") {
                res.writeHead(403, {'Content-Type': 'text/plain'});
                res.end();
            } else {
                var message = JSON.parse(body);
                console.log(message);
                contactsHandler(res, message);
            }
        } else {
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.write("Forbidden");
            res.end();
        }

    });


}


function messageHandler(res, message) {
    console.log("Message handler");
    var userFrom = message['UserFrom'];
    var password = message['Password'];
    var userTo = message['UserTo'];
    var msg = message['Message'];
    
    var destID = findDeviceID(userTo);
    if (checkAuth(userFrom, password) && (destID != "")) {
    
        var note = new apns.notification();

       
        var destDevice = new apns.device(destID);

        note.badge = msg;
        note.sound = "default";
        note.alert = userFrom+": "+msg;
        note.payload = {'UserFrom': userFrom, 'Message': msg};
        note.device = destDevice;

        apnsConnection.sendNotification(note);

        console.log("Message sent from " + userFrom + " to " + userTo);
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end();
    } else {
        console.log("Denied: " + userFrom);
        res.writeHead(403, {'Content-Type': 'text/plain'});
        res.end();
    }
}


function contactsHandler(res, message) {
    console.log("Contacts handler");
    var user = message['Username'];
    var password = message['Password'];

    /* REWRITE THIS TO FETCH FROM DB 
     * Can't from home because db.cs.dal.ca is awful
     */
    var contacts = { "cbaltzer": ["test1", "test2", "cbaltzer"],
                    "test1": ["cbaltzer", "test2"],
                    "test2": ["cbaltzer", "test1"]
                    };

    if (checkAuth(user, password)) {
        console.log("Authorized: " + user);
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.write(JSON.stringify(contacts[user]));
        res.end();
    } else {
        console.log("Denied: " + user);
        res.writeHead(403, {'Content-Type': 'text/plain'});
        res.end();
    }
}


function loginHandler(credentials) {
    console.log("Login");
}



setup();

db.close();


