const Customer = require('../models/Customer');

class CustomerService {
  static async getAllCustomers() {
    try {
      const customers = await Customer.find({ isDeleted: false })
        .sort({ createdAt: -1 });
      return { customers: customers || [], count: customers ? customers.length : 0 };
    } catch (error) {
      console.error('❌ Error in CustomerService.getAllCustomers:', error);
      return { customers: [], count: 0 };
    }
  }

  static async getCustomerById(id) {
    return await Customer.findOne({ _id: id, isDeleted: false });
  }

  static async createCustomer(customerData) {
    try {
      console.log('🔍 Creating customer with data:', customerData);
      
      const newCustomer = new Customer(customerData);
      const saved = await newCustomer.save();
      return saved;
    } catch (error) {
      console.error('❌ Error in createCustomer service:', error.message);
      throw error;
    }
  }

  static async updateCustomer(id, customerData) {
    return await Customer.findByIdAndUpdate(
      id,
      { ...customerData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  static async deleteCustomer(id) {
    // Soft delete
    return await Customer.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = CustomerService;