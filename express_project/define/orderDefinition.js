/**
 * @swagger
 * tags:
 *    name: Order
 *    description: 주문
 * definitions:
 *    Order:
 *      type: object
 *      required:
 *       - content
 *      properties:
 *        OrderID :
 *          type: string
 *          description: ObjectID
 *        CustomerID :
 *          type: string
 *          description: CustomerID
 *        Quantity:
 *          type: number
 *          description: quantity
 *        ProductID:
 *          type: string
 *          description: ProductID
 *
 */
/**
 * @swagger
 * /order?customerID={customerID}&quantity={quantity}:
 *  get:
 *    summary: Returns Order List
 *    tags : [Order]
 *    parameters:
 *        - in : query
 *          type: string
 *          required: true
 *          name: customerID
 *          description : 손님 아이디
 *        - in : query
 *          type: string
 *          required: true
 *          name: quantity
 *          description: 양
 *    responses:
 *      200:
 *        description: order list
 *        schema:
 *          type: object
 *          properties:
 *            todos:
 *              type: array
 *              items:
 *                  $ref: '#/definitions/Order'
 *
 *
 */

