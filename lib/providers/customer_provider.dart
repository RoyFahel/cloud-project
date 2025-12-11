import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;
  bool _isConnected = false;

  // Getters
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _customers.isNotEmpty;
  bool get isConnected => _isConnected;
  Map<String, dynamic>? get statistics => _statistics;

  // Initialize and test MongoDB connection
  Future<void> initializeConnection() async {
    await loadCustomers();
    
  }

  // Test connection to MongoDB
  Future<void> testConnection() async {
    _setLoading(true);
    try {
      final healthStatus = await ApiService.getHealthStatus();
      _isConnected = healthStatus['status'] == 'OK';
      _clearError();
      
      if (_isConnected) {
        await loadCustomers();
      }
    } catch (e) {
      _isConnected = false;
      _setError('Failed to connect to MongoDB: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all customers from MongoDB
  Future<void> loadCustomers() async {
    _setLoading(true);
    try {
      _customers = await ApiService.getCustomers();
      _isConnected = true;
      _clearError();
      debugPrint('✅ Successfully loaded ${_customers.length} customers from MongoDB');
    } catch (e) {
      _isConnected = false;
      _setError('Failed to load customers: $e');
      debugPrint('❌ Error loading customers: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new customer to MongoDB
  Future<bool> addCustomer(Customer customer) async {
    _setLoading(true);
    try {
      debugPrint('🔄 CustomerProvider: Starting to add customer: ${customer.firstName} ${customer.lastName}');
      debugPrint('🔄 CustomerProvider: Calling ApiService.createCustomer...');
      
      final newCustomer = await ApiService.createCustomer(customer);
      
      debugPrint('✅ CustomerProvider: Successfully received customer from API: ${newCustomer.id}');
      _customers.add(newCustomer);
      _clearError();
      notifyListeners();
      debugPrint('✅ Successfully added customer: ${newCustomer.firstName} ${newCustomer.lastName}');
      
    
      
      return true;
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to add customer: $e';
      debugPrint('❌ CustomerProvider Error: $errorMsg');
      debugPrint('❌ CustomerProvider Stack: $stackTrace');
      _setError(errorMsg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing customer in MongoDB
  // Future<bool> updateCustomer(String id, Customer customer) async {
  //   _setLoading(true);
  //   try {
  //     final updatedCustomer = await ApiService.updateCustomer(id, customer);
  //     final index = _customers.indexWhere((p) => p.id == id);
  //     if (index != -1) {
  //       _customers[index] = updatedCustomer;
  //       _clearError();
  //       notifyListeners();
  //       debugPrint('✅ Successfully updated customer: ${updatedCustomer.firstName} ${updatedCustomer.lastName}');
  //       await loadStatistics(); // Refresh stats
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     _setError('Failed to update customer: $e');
  //     debugPrint('❌ Error updating customer: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Delete a customer from MongoDB
  // Future<bool> deleteCustomer(String id) async {
  //   _setLoading(true);
  //   try {
  //     final success = await ApiService.deleteCustomer(id);
  //     if (success) {
  //       _customers.removeWhere((customer) => customer.id == id);
  //       _clearError();
  //       notifyListeners();
  //       debugPrint('✅ Successfully deleted customer with ID: $id');
  //       await loadStatistics(); // Refresh stats
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     _setError('Failed to delete customer: $e');
  //     debugPrint('❌ Error deleting customer: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Search customers in MongoDB
  Future<void> searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      await loadCustomers();
      return;
    }

    _setLoading(true);
    try {
      _customers = await ApiService.searchCustomers(query);
      _clearError();
      debugPrint('✅ Search completed: found ${_customers.length} customers');
    } catch (e) {
      _setError('Failed to search customers: $e');
      debugPrint('❌ Error searching customers: $e');
    } finally {
      _setLoading(false);
    }
  }

  // // Get customers statistics by email domain
  // Map<String, int> getCustomersStatistics() {
  //   final Map<String, int> stats = {};
  //   for (final customer in _customers) {
  //     final domain = customer.email.split('@').last;
  //     final domainKey = domain.isNotEmpty ? domain : 'Unknown';
  //     stats[domainKey] = (stats[domainKey] ?? 0) + 1;
  //   }
  //   return stats;
  // }

  // Get total customers count
  int get totalCustomers => _customers.length;

  // Get customers by email domain
  List<Customer> getCustomersByEmailDomain(String domain) {
    return _customers.where((customer) => customer.email.contains('@$domain')).toList();
  }

  // Clear all data
  void clearData() {
    _customers.clear();
    _statistics = null;
    _isConnected = false;
    _clearError();
    notifyListeners();
  }

  // Retry connection
  Future<void> retryConnection() async {
    debugPrint('🔄 Retrying MongoDB connection...');
    await testConnection();
  }

  // Private helper methods
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

  // Get connection status for UI
  String get connectionStatus {
    if (_isLoading) return 'Connecting to MongoDB...';
    if (_isConnected) return 'Connected to MongoDB';
    if (hasError) return 'Connection Failed';
    return 'Not Connected';
  }

  // Get connection icon for UI
  IconData get connectionIcon {
    if (_isLoading) return Icons.hourglass_empty;
    if (_isConnected) return Icons.check_circle;
    if (hasError) return Icons.error;
    return Icons.cloud_off;
  }

  // Get connection color for UI
  Color get connectionColor {
    if (_isLoading) return Colors.orange;
    if (_isConnected) return Colors.green;
    if (hasError) return Colors.red;
    return Colors.grey;
  }
}