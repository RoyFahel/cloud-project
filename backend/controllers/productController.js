const ProductService = require('../services/productService');

class ProductController {
  static async getAllProducts(req, res) {
    try {
      const result = await ProductService.getAllProducts();
      res.json(result);
    } catch (error) {
      console.error('❌ Error in getAllProducts:', error);
      res.status(500).json({ error: 'Failed to get products', message: error.message });
    }
  }

  static async getProductById(req, res) {
    try {
      const product = await ProductService.getProductById(req.params.id);
      if (!product) {
        return res.status(404).json({ error: 'Product not found' });
      }
      res.json(product);
    } catch (error) {
      console.error('❌ Error in getProductById:', error);
      res.status(500).json({ error: 'Failed to get product', message: error.message });
    }
  }

  static async createProduct(req, res) {
    try {
      console.log('📝 Creating product with data:', req.body);
      const product = await ProductService.createProduct(req.body);
      console.log('✅ Product created successfully:', product);
      res.status(201).json({ product });
    } catch (error) {
      console.error('❌ Error in createProduct:', error);
      console.error('Error message:', error.message);
      res.status(400).json({ error: 'Failed to create product', message: error.message });
    }
  }

  static async updateProduct(req, res) {
    try {
      const product = await ProductService.updateProduct(req.params.id, req.body);
      if (!product) {
        return res.status(404).json({ error: 'Product not found' });
      }
      res.json(product);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update product', message: error.message });
    }
  }

  static async deleteProduct(req, res) {
    try {
      const deleted = await ProductService.deleteProduct(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Product not found' });
      }
      res.json({ message: 'Product deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete product', message: error.message });
    }
  }
}

module.exports = ProductController;