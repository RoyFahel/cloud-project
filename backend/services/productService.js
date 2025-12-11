const Product = require('../models/Product');
const Category = require('../models/Category'); // Import to ensure model is registered

class ProductService {
  static async getAllProducts() {
    try {
      const products = await Product.find({ isDeleted: false })
        .populate('category_id', 'categoryName')
        .sort({ createdAt: -1 });
      return { products: products || [], count: products ? products.length : 0 };
    } catch (error) {
      console.error('❌ Error in ProductService.getAllProducts:', error);
      // Return empty array instead of throwing to prevent 500 errors
      return { products: [], count: 0 };
    }
  }

  static async getProductById(id) {
    return await Product.findOne({ _id: id, isDeleted: false })
      .populate('category_id', 'categoryName');
  }

  static async createProduct(productData) {
    try {
      console.log('🔍 Creating product with data:', productData);
      
      // Validate required fields
      if (!productData.productName) {
        throw new Error('Product name is required');
      }
      if (!productData.category_id) {
        throw new Error('Category ID is required');
      }
      
      // Check if category exists
      const category = await Category.findById(productData.category_id);
      if (!category) {
        throw new Error(`Category with ID ${productData.category_id} not found`);
      }
      
      const newProduct = new Product(productData);
      const saved = await newProduct.save();
      return await Product.findById(saved._id).populate('category_id', 'categoryName');
    } catch (error) {
      console.error('❌ Error in createProduct service:', error.message);
      throw error;
    }
  }

  static async updateProduct(id, productData) {
    return await Product.findByIdAndUpdate(
      id,
      { ...productData, updatedAt: Date.now() },
      { new: true, runValidators: true }
    ).populate('category_id', 'categoryName');
  }

  static async deleteProduct(id) {
    const result = await Product.findByIdAndUpdate(
      id,
      { isDeleted: true, updatedAt: Date.now() },
      { new: true }
    );
    return result !== null;
  }
}

module.exports = ProductService;