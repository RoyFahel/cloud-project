import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Group;
import '../models/group.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Group> _groups = [];
  List<Product> _products = [];
  final List<Order> _orders = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Group> get groups => _groups;
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

  // Load all groups from database
  Future<void> loadGroups() async {
    try {
      _groups = await ApiService.getGroups();
      debugPrint('✅ Loaded ${_groups.length} groups');
      for (var group in _groups) {
        debugPrint('   Group: ${group.groupName} (ID: ${group.id})');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loadingg groups: $e');
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
        loadGroups(),
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

  // Get products filtered by group
  List<Product> getProductsForGroup(String groupId) {
    return _products.where((med) => med.groupId == groupId).toList();
  }

  // Create a new order
  Future<bool> createOrder({
    required String customerId,
    required String groupId,
    required String productId,
    String notes = '',
  }) async {
    _setLoading(true);
    try {
      debugPrint('🔄 Creating order for customer: $customerId');
      
      final orderData = {
        'customer_id': customerId,
        'group_id': groupId,
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

  // Get group by ID
  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
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

  // CRUD operations for Groups
  Future<bool> createGroup({
    required String groupName,
  
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final group = await ApiService.createGroup({
        'groupName': groupName,
       
      });
      
      _groups.add(group);
      notifyListeners();
      debugPrint('✅ Created group: $groupName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating group: $e');
      _setError('Failed to create group: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteGroup(String id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await ApiService.deleteGroup(id);
      
      _groups.removeWhere((group) => group.id == id);
      // Also remove products related to this group from local list
      _products.removeWhere((product) => product.groupId == id);
      notifyListeners();
      debugPrint('✅ Deleted group: $id and related products');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting group: $e');
      _setError('Failed to delete group: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Products
  Future<bool> createProduct({
    required String productName,
    
    required String groupId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final product = await ApiService.createProduct({
        'productName': productName,
        
        'group_id': groupId, // Backend expects group_id, not groupId
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