var express = require('express');
var router = express.Router();

const mysql = require('mysql');
const dbConfig = require('../config/database')
const connection = mysql.createConnection(dbConfig);

//connection.connect();




/**
 * @swagger
 * tags:
 *    name: Todo
 *    description : hello express, swagger
 * definitions:
 *    Todo:
 *      type: object
 *      required:
 *        - content
 *      properties:
 *        _id :
 *          type: string
 *          description : ObjectID
 *        content:
 *          type: string
 *          description: 할일 내용
 *        done:
 *          type: boolean
 *          description: 완료 여부
 *
 */
/**
 * @swagger
 * /todo :
 *  get:
 *    summary : Returns Todo list
 *    tags : [Todo]
 *    responses:
 *      200:
 *        description: 뇸뇸뇸뇸뇸
 *        schema :
 *          type : object
 *          properties:
 *            todos:
 *              type : array
 *              items :
 *                $ref : '#/definitions/Todo'
 *
 */

router.get('/todo', function(req,res,next){
  var todo;
  connection.query('SELECT * from Todo', (err, rows, field) => {
    if (err) throw err;
    todo = rows;
    res.send(todo);
  })

})




/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});



module.exports = router;

