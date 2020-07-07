var express = require('express');
var router = express.Router();
var connectionObject = require('../config/database');
var connection = connectionObject.init();

connectionObject.dbConnect(connection);
// const connection = mysql.createConnection({
//   host      : 'localhost',
//   user      : 'anipleUser',
//   password  : '1234',
//   database  : 'anipledb'
// });
//
// connection.connect();

//const todoDefinition = require('../define/todoDefinition');


router.get('/todo', function(req,res,next){
  connection.query('SELECT * from tb_beauty', (error, rows) => {
    if(error) throw error;
    res.send(rows[0]);
  });
})

router.get('/order', function(req,res,next) {
  var customerID = req.query.customerID;
  var quantity = req.query.quantity;
  //console.log(customerID);
  connection.query('SELECT * from Orders WHERE CustomerID = ? AND Quantity = ?',[customerID,quantity], (error, rows) => {
    if(error) throw error;
    res.send(rows);
  })
})




/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = router;
