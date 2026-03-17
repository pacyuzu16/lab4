import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../utils/exceptions.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch all posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to load posts (${response.statusCode})');
    } on SocketException {
      throw const NoInternetException();
    }
  }

  // Fetch a single post by id
  Future<Post> getPost(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts/$id'));
      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load post (${response.statusCode})');
    } on SocketException {
      throw const NoInternetException();
    }
  }

  // Create a new post
  Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(post.toJson()),
      );
      if (response.statusCode == 201) {
        return Post.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create post (${response.statusCode})');
    } on SocketException {
      throw const NoInternetException();
    }
  }

  // Update an existing post
  Future<Post> updatePost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/posts/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...post.toJson(), 'id': post.id}),
      );
      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update post (${response.statusCode})');
    } on SocketException {
      throw const NoInternetException();
    }
  }

  // Delete a post
  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/posts/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete post (${response.statusCode})');
      }
    } on SocketException {
      throw const NoInternetException();
    }
  }
}
