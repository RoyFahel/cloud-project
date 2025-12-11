const express = require('express');
const router = express.Router();
const OrderController = require('../controllers/orderController');
// GET /api/orders - Get all orders
router.get('/', OrderController.getAllOrders);

// GET /api/orders/:id - Get order by ID
router.get('/:id', OrderController.getOrderById);

// POST /api/orders - Create new order
router.post('/', OrderController.createOrder);

// PUT /api/orders/:id - Update order
router.put('/:id', OrderController.updateOrder);

// DELETE /api/orders/:id - Delete order
router.delete('/:id', OrderController.deleteOrder);

module.exports = router;
