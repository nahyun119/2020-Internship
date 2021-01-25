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
 *        description: todo list
 *        schema :
 *          type : object
 *          properties:
 *            todos:
 *              type : array
 *              items :
 *                $ref : '#/definitions/Todo'
 *      404:
 *          description : 잘못된 접근
 *          schema:
 *              type: object
 *              properties:
 *                  error:
 *                      type: object
 *                      properties:
 *                          code:
 *                              type: number
 *                              example : 404
 *                          name:
 *                              type: string
 *                              example: 잘못된 접근입니다. 다시 요청해주세요
 *
 *
 */