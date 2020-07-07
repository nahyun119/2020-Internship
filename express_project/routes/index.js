var express = require('express');
var router = express.Router();

//const todoDefinition = require('../define/todoDefinition');


router.get('/todo', function(req,res,next){
  var todo = {
    _id : '4',
    content : 'todo list'
  };
  res.send(todo);
})




/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = router;
