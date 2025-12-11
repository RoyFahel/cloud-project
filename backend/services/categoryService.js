const Category = require('../models/Category');

class CategoryService {
  static async getAllCategories() {
    try {
      const categories = await Category.find({ isDeleted: false })
        .sort({ createdAt: -1 });
      return { categories: categories || [], count: categories ? categories.length : 0 };
    } catch (error) {
      console.error('❌ Error in CategoryService.getAllCategories:', error);
      return { categories: [], count: 0 };
    }
  }

  static async getCategoryById(id) {
    return await Category.findOne({ _id: id, isDeleted: false });
  }

  static async createCategory(categoryData) {
    try {
      console.log('🔍 Creating category with data:', categoryData);
      
      if (!categoryData.categoryName) {
        throw new Error('Category name is required');
      }
      
      const newCategory = new Category(categoryData);
      const saved = await newCategory.save();
      return saved;
    } catch (error) {
      console.error('❌ Error in createCategory service:', error.message);
      throw error;
    }
  }

  static async updateCategory(id, categoryData) {
    return await Category.findByIdAndUpdate(
      id,
      { ...categoryData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  static async deleteCategory(id) {
    // Soft delete
    return await Category.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = CategoryService;