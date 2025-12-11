const CategoryService = require('../services/categoryService');

class CategoryController {
  static async getAllCategories(req, res) {
    try {
      const categories = await CategoryService.getAllCategories();
      res.json(categories);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get categories', message: error.message });
    }
  }

  static async getCategoryById(req, res) {
    try {
      const category = await CategoryService.getCategoryById(req.params.id);
      if (!category) {
        return res.status(404).json({ error: 'Category not found' });
      }
      res.json(category);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get category', message: error.message });
    }
  }

  static async createCategory(req, res) {
    try {
      console.log('📝 Creating category with data:', req.body);
      const category = await CategoryService.createCategory(req.body);
      console.log('✅ Category created successfully:', category);
      res.status(201).json({ category });
    } catch (error) {
      console.error('❌ Error creating category:', error.message);
      res.status(400).json({ error: 'Failed to create category', message: error.message });
    }
  }

  static async updateCategory(req, res) {
    try {
      const category = await CategoryService.updateCategory(req.params.id, req.body);
      if (!category) {
        return res.status(404).json({ error: 'Category not found' });
      }
      res.json(category);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update category', message: error.message });
    }
  }

  static async deleteCategory(req, res) {
    try {
      const deleted = await CategoryService.deleteCategory(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Category not found' });
      }
      res.json({ message: 'Category deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete category', message: error.message });
    }
  }
}

module.exports = CategoryController;