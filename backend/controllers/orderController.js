const OrderService = require('../services/orderService');

class OrderController {
  static async getAllOrders(req, res) {
    try {
      const orders = await OrderService.getAllOrders();
      res.json(orders);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get orders', message: error.message });
    }
  }

  static async getOrderById(req, res) {
    try {
      const order = await OrderService.getOrderById(req.params.id);
      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }
      res.json(order);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get order', message: error.message });
    }
  }

  static async createOrder(req, res) {
    try {
      console.log('📝 Creating order with data:', req.body);
      const order = await OrderService.createOrder(req.body);
      console.log('✅ Order created successfully:', order);
      res.status(201).json({ order });
    } catch (error) {
      console.error('❌ Error creating order:', error.message);
      res.status(400).json({ error: 'Failed to create order', message: error.message });
    }
  }

  static async updateOrder(req, res) {
    try {
      const order = await OrderService.updateOrder(req.params.id, req.body);
      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }
      res.json(order);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update order', message: error.message });
    }
  }

  static async deleteOrder(req, res) {
    try {
      const deleted = await OrderService.deleteOrder(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Order not found' });
      }
      res.json({ message: 'Order deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete order', message: error.message });
    }
  }
}

module.exports = OrderController;