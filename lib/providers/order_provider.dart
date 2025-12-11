import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Product> _products = [];
  final List<Order> _orders = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Private helper methods (defined first)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load all categories from database
  Future<void> loadCategories() async {
    try {
      _categories = await ApiService.getCategories();
      debugPrint('✅ Loaded ${_categories.length} categories');
      for (var category in _categories) {
        debugPrint('   Category: ${category.categoryName} (ID: ${category.id})');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loadingg categories: $e');
      rethrow;
    }
  }


  Future<void> loadProducts() async {
    try {
      _products = await ApiService.getProducts();
      debugPrint('✅ Loaded ${_products.length} products');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      rethrow;
    }
  }

  Future<void> loadCustomers() async {
    try {
      _customers = await ApiService.getCustomers();
      debugPrint('✅ Loaded ${_customers.length} customers');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading customers: $e');
      rethrow;
    }
  }

 
  Future<void> loadOrders() async {
    try {
      final orders = await ApiService.getOrders();
      _orders.clear();
      _orders.addAll(orders);
      debugPrint('Loaded ${_orders.length} orders');
      notifyListeners();
    } catch (e) {
      debugPrint(' Error loading orders: $e');
      rethrow;
    }
  }

 
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadCategories(),
        loadProducts(),
        loadCustomers(),
        loadOrders(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to initialize data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get products filtered by category
  List<Product> getProductsForCategory(String categoryId) {
    return _products.where((med) => med.categoryId == categoryId).toList();
  }

  // Create a new order
  Future<bool> createOrder({
    required String customerId,
    required String categoryId,
    required String productId,
    String notes = '',
  }) async {
    _setLoading(true);
    try {
      debugPrint('🔄 Creating order for customer: $customerId');
      
      final orderData = {
        'customer_id': customerId,
        'category_id': categoryId,
        'product_id': productId,
        'date': DateTime.now().toIso8601String(),
        'notes': notes,
      };
      
      final newOrder = await ApiService.createOrder(orderData);
      
      _orders.insert(0, newOrder); // Add to beginning
      _clearError();
      notifyListeners();
      
      debugPrint('✅ Successfully created order');
      return true;
    } catch (e) {
      final errorMsg = 'Failed to create order: $e';
      debugPrint('❌ $errorMsg');
      _setError(errorMsg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new customer and return the customer object
  Future<Customer?> createCustomer({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final customer = Customer(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      debugPrint('🔄 Creating customer: $firstName $lastName');
      final newCustomer = await ApiService.createCustomer(customer);
      
      _customers.add(newCustomer);
      notifyListeners();
      
      debugPrint('✅ Successfully created customer: ${newCustomer.id}');
      return newCustomer;
    } catch (e) {
      debugPrint('❌ Error creating customer: $e');
      _setError('Failed to create customer: $e');
      rethrow; // Re-throw the error so it can be caught by the caller
    }
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // CRUD operations for Categories
  Future<bool> createCategory({
    required String categoryName,
  
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final category = await ApiService.createCategory({
        'categoryName': categoryName,
       
      });
      
      _categories.add(category);
      notifyListeners();
      debugPrint('✅ Created category: $categoryName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating category: $e');
      _setError('Failed to create category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await ApiService.deleteCategory(id);
      
      _categories.removeWhere((category) => category.id == id);
      // Also remove products related to this category from local list
      _products.removeWhere((product) => product.categoryId == id);
      notifyListeners();
      debugPrint('✅ Deleted category: $id and related products');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting category: $e');
      _setError('Failed to delete category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Products
  Future<bool> createProduct({
    required String productName,
    
    required String categoryId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final product = await ApiService.createProduct({
        'productName': productName,
        
        'category_id': categoryId, // Backend expects category_id, not categoryId
      });
      
      _products.add(product);
      notifyListeners();
      debugPrint('✅ Created product: $productName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      _setError('Failed to create product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await ApiService.deleteProduct(id);
      
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
      debugPrint('✅ Deleted product: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      _setError('Failed to delete product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

}