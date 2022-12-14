import 'dart:io';

import 'package:e_commerce_admin/Screens/AddProduct.dart';
import 'package:e_commerce_admin/data/FileStoreHelper.dart';
import 'package:e_commerce_admin/model/Product.dart';
import 'package:e_commerce_admin/model/catergory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Routers/AppRouter.dart';

class FireStoreProvider extends ChangeNotifier {
  List<Product> products = [];
  List<AppCategory> categories = [];
  File? selectedImage;
  String? seletedItem;
  bool loading = true;

  GlobalKey<FormState> addProductForm = GlobalKey<FormState>();
  TextEditingController nameProductController = TextEditingController();
  TextEditingController descriptionProductController = TextEditingController();
  TextEditingController priceProductController = TextEditingController();
  TextEditingController quantityProductController = TextEditingController();
  TextEditingController categoryProductController = TextEditingController();

  TextEditingController nameProductControllerEdit = TextEditingController();
  TextEditingController descriptionProductControllerEdit =
      TextEditingController();
  TextEditingController priceProductControllerEdit = TextEditingController();
  TextEditingController quantityProductControllerEdit = TextEditingController();
  TextEditingController categoryProductControllerEdit = TextEditingController();

  File? selectedFile;

  FireStoreProvider() {
    fillData();
  }

  readAllProducts() async {
    products = await FireStorHelper.instance.readAllProduct();
    notifyListeners();
  }

  readAllCategories() async {
    categories = await FireStorHelper.instance.readAllCatergories();
    notifyListeners();
  }

  getImage() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    selectedImage = File(file!.path);
    notifyListeners();
  }

  changeSeleteditem(var value) {
    seletedItem = value;
    notifyListeners();
  }

  upLoadFile(File file) async {
    return await FireStorHelper.instance.uplaodFile(file);
  }

  AddProductToFireBase() async {
    if (addProductForm.currentState!.validate()) {
      changeLoading();
      Product product = Product(
          name: nameProductController.text,
          descraption: descriptionProductController.text,
          imagePath: await upLoadFile(selectedImage!),
          categoryId: seletedItem!,
          quantity: int.parse(quantityProductController.text),
          price: int.parse(priceProductController.text));

      await FireStorHelper.instance.addProductToFirebase(product);
      emptyControllers();
      AppRouter.popWidget();
      ScaffoldMessenger.of(AppRouter.navKey.currentContext!)
          .showSnackBar(const SnackBar(content: Text("Added Successfully")));
      fillData();
      changeLoading();
    }
  }

  deleteProduct(String productId) async {
    changeLoading();

    await FireStorHelper.instance.deleteProduct(productId);
    ScaffoldMessenger.of(AppRouter.navKey.currentContext!)
        .showSnackBar(const SnackBar(content: Text("Deleted Successfully")));
    fillData();
    changeLoading();
  }

  updateProduct(Product product) async {
    if (addProductForm.currentState!.validate()) {
      changeLoading();

      product.name = nameProductControllerEdit.text;
      product.descraption = descriptionProductControllerEdit.text;
      product.price = int.parse(priceProductControllerEdit.text);
      product.quantity = int.parse(quantityProductControllerEdit.text);

      await FireStorHelper.instance.updateProduct(product);
      AppRouter.popWidget();
      ScaffoldMessenger.of(AppRouter.navKey.currentContext!)
          .showSnackBar(const SnackBar(content: Text("Updated Successfully")));
      fillData();
      changeLoading();
    }
  }

  fillEditcontrollers(Product product) {
    nameProductControllerEdit.text = product.name;
    descriptionProductControllerEdit.text = product.descraption;
    priceProductControllerEdit.text = product.price.toString();
    quantityProductControllerEdit.text = product.quantity.toString();
  }

  fillData() async {
    changeLoading();
    await readAllProducts();
    await readAllCategories();
    changeLoading();
  }

  emptyControllers() {
    nameProductController.text = '';
    descriptionProductController.text = '';
    priceProductController.text = '';
    quantityProductController.text = '';
    selectedImage = null;
    notifyListeners();
  }

  emptyValidation(value) {
    if (value == null || value == '') return 'This failed is required';
  }

  priceAndQuantityValidation(value) {
    if (value == "0") return 'This failed can\'t be zero';

    if (value == null || value == '') return "This faild is required";
  }

  changeLoading() {
    loading = !loading;
    notifyListeners();
  }
}
