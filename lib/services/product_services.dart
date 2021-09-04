import 'dart:convert';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsServices extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-3cb0c-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  Product? selectedProduct;
  bool isLoading = true;
  bool isSaving = false;
  File? newPictureFile;
  ProductsServices() {
    this.loadProduct();
  }

  Future loadProduct() async {
    this.isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);
    final Map<String, dynamic> productsMap = json.decode(resp.body);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      this.products.add(tempProduct);
    });
    this.isLoading = false;
    notifyListeners();
    return this.products;
  }

  Future saveorCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    // ignore: unnecessary_null_comparison
    if (product.id == null) {
      //es necesario crear
      await this.createProduct(product);
    } else {
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodeData = resp.body;

    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;
    //actualizar el listado de productos
    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodeData = json.decode(resp.body);
    print(decodeData);
    product.id = decodeData['name'];

    this.products.add(product);
    //actualizar el listado de productos
    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    this.selectedProduct!.picture = path;
    this.newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPictureFile == null) return null;
    this.isSaving = true;
    notifyListeners();

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/dxzafq3oh/image/upload?upload_preset=nes7go0e');

    final imageUploadRequest = http.MultipartRequest('POST', uri);
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('algo salio mal');
      print(resp.body);
      return null;
    }

    this.newPictureFile = null;
    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];
    // print(resp.body);
  }
}
