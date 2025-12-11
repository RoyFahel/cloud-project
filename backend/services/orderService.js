const Order = require('../models/Order');

class OrderService {
  static async getAllOrders() {
    try {
      const orders = await Order.find({ isDeleted: false })
        .populate('customer_id', 'firstName lastName email age gender')
        .populate('category_id', 'categoryName')
        .populate('product_id', 'productName')
        .sort({ createdAt: -1 });
      return { orders: orders || [], count: orders ? orders.length : 0 };
    } catch (error) {
      console.error('❌ Error in OrderService.getAllOrders:', error);
      return { orders: [], count: 0 };
    }
  }

  static async getOrderById(id) {
    return await Order.findOne({ _id: id, isDeleted: false })
      .populate('customer_id', 'firstName lastName email age gender')
      .populate('category_id', 'categoryName')
      .populate('product_id', 'productName');
  }

  static async createOrder(orderData) {
    try {
      console.log('🔍 Creating order with data:', orderData);
      
      const newOrder = new Order(orderData);
      const saved = await newOrder.save();
      
      // Return populated order
      return await Order.findById(saved._id)
        .populate('customer_id', 'firstName lastName email age gender')
        .populate('category_id', 'categoryName')
        .populate('product_id', 'productName');
    } catch (error) {
      console.error('❌ Error in createOrder service:', error.message);
      throw error;
    }
  }

  static async updateOrder(id, orderData) {
    return await Order.findByIdAndUpdate(
      id,
      { ...orderData, updatedAt: new Date() },
      { new: true, runValidators: true }
    )
      .populate('customer_id', 'firstName lastName email age gender')
      .populate('category_id', 'categoryName')
      .populate('product_id', 'productName');
  }

  static async deleteOrder(id) {
    return await Order.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = OrderService;