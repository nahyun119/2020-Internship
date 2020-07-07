
var mysql = require('mysql');
var dbConnectionInfo = {
    host : 'localhost',
    user : 'anipleUser',
    password : '1234',
    database: 'anipledb'
};

var connection = {
    init : function(){
        return mysql.createConnection(dbConnectionInfo);
    },
    dbConnect : function (connection) {
        connection.connect(function (err) {
            if(err){
                console.error("MySQL connection error : " + err);
            }
            else {
                console.info("MySQL connection successfully.");
            }
        });
    }
};

module.exports = connection;