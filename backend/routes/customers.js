const express = require('express');
const router = express.Router();
const CustomerController = require('../controllers/customerController');

// GET /api/customers - Get all customers
router.get('/', CustomerController.getAllCustomers);

// GET /api/customers/:id - Get customer by ID
router.get('/:id', CustomerController.getCustomerById);

// POST /api/customers - Create new customer
router.post('/', CustomerController.createCustomer);

// PUT /api/customers/:id - Update customer
router.put('/:id', CustomerController.updateCustomer);

// DELETE /api/customers/:id - Delete customer
router.delete('/:id', CustomerController.deleteCustomer);

module.exports = router;

// Get all customers (not deleted)
router.get('/', async (req, res) => {
  try {
    const customers = await Customer.find({ isDeleted: false }).sort({ createdAt: -1 });
    res.json({ customers, count: customers.length });
  } catch (error) {
    console.error('Error fetching customers:', error);
    res.status(500).json({ error: 'Failed to fetch customers' });
  }
});

// Create a new customer
router.post('/', async (req, res) => {
  try {
    const { firstName, lastName, email } = req.body;
    const customer = new Customer({ firstName, lastName, email });
    const savedCustomer = await customer.save();
    res.status(201).json({ customer: savedCustomer });
  } catch (error) {
    console.error('Error creating customer:', error);
    if (error.code === 11000) {
      res.status(400).json({ error: 'Email already exists' });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

module.exports = router;
