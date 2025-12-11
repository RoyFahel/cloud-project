// Fallback routes when database is not available
const express = require('express');
const router = express.Router();

// Mock data for testing
const mockCustomers = [
  { _id: '1', nom: 'Test Customer', email: 'test@example.com', age: 30 }
];

const mockProducts = [
  { _id: '1', nom: 'Aspirin', description: 'Pain reliever', prix: 10 }
];

const mockGroups = [
  { _id: '1', nom: 'Headache', description: 'Common pain' }
];

// Customers
router.get('/customers', (req, res) => {
  res.json(mockCustomers);
});

router.post('/customers', (req, res) => {
  const newCustomer = { _id: Date.now().toString(), ...req.body };
  mockCustomers.push(newCustomer);
  res.json(newCustomer);
});

// Products
router.get('/products', (req, res) => {
  res.json(mockProducts);
});

router.post('/products', (req, res) => {
  const newProduct = { _id: Date.now().toString(), ...req.body };
  mockProducts.push(newProduct);
  res.json(newProduct);
});

// Groups
router.get('/groups', (req, res) => {
  res.json(mockGroups);
});

router.post('/groups', (req, res) => {
  const newGroup = { _id: Date.now().toString(), ...req.body };
  mockGroups.push(newGroup);
  res.json(newGroup);
});

module.exports = router;