import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // AWS Elastic Beanstalk URL 
  static const String baseUrl = 'http://nodejsapp-env.eba-jjpppfhc.eu-north-1.elasticbeanstalk.com';
  
  // Local development URL
  // static const String baseUrl = 'http://localhost:3000/api';
  static Future<List<Customer>> getCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
 
        final List<dynamic> customersData = jsonData['customers'] ?? jsonData;
        return customersData.map((json) => Customer.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load customers: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  // Create a new customer
  static Future<Customer> createCustomer(Customer customer) async {
    
    try {
      print('🔄 ApiService: Creating customer for ${customer.firstName} ${customer.lastName}');
      
      final Map<String, dynamic> customerData = customer.toJson();
      // Remove null id and timestamps for creation
      customerData.removeWhere((key, value) => value == null || key == '_id');
      
      print('🔄 ApiService: Sending POST request to $baseUrl/api/customers');
      print('🔄 ApiService: Customer data: $customerData');

      final response = await http.post(
        Uri.parse('$baseUrl/api/customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(customerData),
      );

      print('🔄 ApiService: Response status: ${response.statusCode}');
      print('🔄 ApiService: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        // The new backend returns the customer in a 'customer' field
        final customerJson = jsonData['customer'] ?? jsonData;
        final newCustomer = Customer.fromJson(customerJson);
        print('✅ ApiService: Successfully created customer with ID: ${newCustomer.id}');
        return newCustomer;
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Failed to create customer';
        print('❌ ApiService: Server error (${ response.statusCode}): $errorMsg');
        throw Exception('Server error (${response.statusCode}): $errorMsg');
      }
    } catch (e, stackTrace) {
      print('❌ ApiService: Exception in createCustomer: $e');
      print('❌ ApiService: Stack trace: $stackTrace');
      
      if (e.toString().contains('Connection refused') || e.toString().contains('network')) {
        throw Exception('Cannot connect to server. Please check if the backend is running on $baseUrl');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection and server URL.');
      } else {
        throw Exception('Error creating customer: $e');
      }
    }
  }


  // Search customers by name or phone
  static Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Customer.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to search customers');
      }
    } catch (e) {
      throw Exception('Error searching customers: $e');
    }
  }

  // Get API health status
  static Future<Map<String, dynamic>> getHealthStatus() async {
  
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get health status');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }


  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> categoriesData;
        
        if (decoded is Map<String, dynamic>) {
          categoriesData = decoded['categories'] as List<dynamic>;
        } else if (decoded is List<dynamic>) {
          categoriesData = decoded;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load categories: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }



  // Get all products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> productsData;
        
        if (decoded is Map<String, dynamic>) {
          productsData = decoded['products'] as List<dynamic>;
        } else if (decoded is List<dynamic>) {
          productsData = decoded;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load products: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Get products by category ID
  static Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/category/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> productsData = jsonData['products'] ?? jsonData;
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load products: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products for category: $e');
    }
  }


  static Future<Category> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(categoryData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Category.fromJson(data['category'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create category: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  // Delete category
  static Future<bool> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/categories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete category: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  
  
  // Create product
  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      print('🔄 Creating product with data: $productData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Product.fromJson(data['product'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error from server: $errorData');
        throw Exception('Failed to create product: ${errorData['message'] ?? errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in createProduct: $e');
      throw Exception('Error creating product: $e');
    }
  }

  // Delete product
  static Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete product: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
  // Get all orders
  static Future<List<Order>> getOrders() async {
    try {
      // 1. Send HTTP GET request to the backend endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      // 2. Check if the response status is OK (200)
      if (response.statusCode == 200) {
        // 3. Decode the JSON response body
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> ordersData;
        
        if (decoded is Map<String, dynamic>) {
          ordersData = decoded['orders'] as List<dynamic>;
        } else if (decoded is List<dynamic>) {
          ordersData = decoded;
        } else {
          throw Exception('Unexpected response format');
        }

        // 5. Map each JSON object to a Order model and return as a List
        return ordersData.map((json) => Order.fromJson(json)).toList();
      } else {
        // 6. Handle error response
        final errorData = json.decode(response.body);
        throw Exception('Failed to load orders: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      // 7. Handle exceptions
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order by ID
  static Future<Order> getOrder(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final orderData = jsonData['order'] ?? jsonData;
        return Order.fromJson(orderData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load order: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create order
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Always remove notes field
      orderData.remove('notes');
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Order.fromJson(data['order'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create order: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Delete order
  static Future<bool> deleteOrder(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete order: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

}