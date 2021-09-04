import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productServices = Provider.of<ProductsServices>(context);
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productServices.selectedProduct!),
      child: _ProductScreenBody(productServices: productServices),
    );
    //
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productServices,
  }) : super(key: key);

  final ProductsServices productServices;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productServices.selectedProduct!.picture),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 49,
                  right: 60,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 30,
                    ),
                    onPressed: () async {
                      final picker = new ImagePicker();
                      // ignore: deprecated_member_use
                      final PickedFile? pickedFile = await picker.getImage(
                          source: ImageSource.gallery, imageQuality: 100);

                      if (pickedFile == null) {
                        print('no selecciono nada');
                        return;
                      }
                      print('tenemos imagen:: ');
                      productServices
                          .updateSelectedProductImage(pickedFile.path);
                    },
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                    ),
                    onPressed: () async {
                      final picker = new ImagePicker();
                      // ignore: deprecated_member_use
                      final PickedFile? pickedFile = await picker.getImage(
                          source: ImageSource.camera, imageQuality: 100);

                      if (pickedFile == null) {
                        print('no selecciono nada');
                        return;
                      }
                      print('tenemos imagen:: ');
                      productServices
                          .updateSelectedProductImage(pickedFile.path);
                    },
                  ),
                ),
              ],
            ),
            _ProductForm(),
            SizedBox(height: 100)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: productServices.isSaving
            ? null
            : () async {
                if (!productForm.isValidForm()) return;
                final String? imageUrl = await productServices.uploadImage();
                // print(imageUrl);
                if (imageUrl != null) productForm.product.picture = imageUrl;

                await productServices.saveorCreateProduct(productForm.product);
              },
        child: productServices.isSaving
            ? CircularProgressIndicator(
                color: Colors.white,
              )
            : Icon(
                Icons.save_alt_outlined,
              ),
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productform = Provider.of<ProductFormProvider>(context);
    final product = productform.product;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: _buildBoxDecoration(),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: productform.formKey,
        child: Column(
          children: [
            SizedBox(height: 10),
            TextFormField(
              initialValue: product.name,
              onChanged: (value) => product.name = value,
              validator: (value) {
                if (value == null || value.length < 1)
                  return 'El Nombre es Obligatorio';
              },
              decoration: InputDecorations.authInputDecoration(
                hintText: 'Nombre del Producto',
                labelText: 'Nombre:',
              ),
            ),
            SizedBox(height: 30),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
              ],
              initialValue: '${product.price}',
              onChanged: (value) {
                if (double.tryParse(value) == null) {
                  product.price = 0;
                } else {
                  product.price = double.parse(value);
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecorations.authInputDecoration(
                hintText: '\$150',
                labelText: 'Precio:',
              ),
            ),
            SizedBox(height: 30),
            SwitchListTile.adaptive(
              value: product.available,
              onChanged: productform.updateAvailability,
              title: Text('Disponible'),
              activeColor: Colors.indigo,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 5),
            blurRadius: 5),
      ],
    );
  }
}
