const CustomerService = require('../services/customerService');

class CustomerController {
  static async getAllCustomers(req, res) {
    try {
      const customers = await CustomerService.getAllCustomers();
      res.json(customers);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get customers', message: error.message });
    }
  }

  static async getCustomerById(req, res) {
    try {
      const customer = await CustomerService.getCustomerById(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json(customer);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get customer', message: error.message });
    }
  }

  static async createCustomer(req, res) {
    try {
      console.log('📝 Creating customer with data:', req.body);
      const customer = await CustomerService.createCustomer(req.body);
      console.log('✅ Customer created successfully:', customer);
      res.status(201).json({ customer });
    } catch (error) {
      console.error('❌ Error creating customer:', error.message);
      res.status(400).json({ error: 'Failed to create customer', message: error.message });
    }
  }

  static async updateCustomer(req, res) {
    try {
      const customer = await CustomerService.updateCustomer(req.params.id, req.body);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json(customer);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update customer', message: error.message });
    }
  }

  static async deleteCustomer(req, res) {
    try {
      const deleted = await CustomerService.deleteCustomer(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json({ message: 'Customer deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete customer', message: error.message });
    }
  }
}

module.exports = CustomerController;