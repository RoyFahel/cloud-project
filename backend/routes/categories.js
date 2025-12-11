const express = require('express');
const router = express.Router();
const CategoryController = require('../controllers/categoryController');

// GET /api/categories - Get all categories
router.get('/', CategoryController.getAllCategories);

// GET /api/categories/:id - Get category by ID
router.get('/:id', CategoryController.getCategoryById);

// POST /api/categories - Create new category
router.post('/', CategoryController.createCategory);

// PUT /api/categories/:id - Update category
router.put('/:id', CategoryController.updateCategory);

// DELETE /api/categories/:id - Delete category
router.delete('/:id', CategoryController.deleteCategory);

module.exports = router;
