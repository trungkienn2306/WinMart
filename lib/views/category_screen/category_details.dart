import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_tutorial/consts/consts.dart';
import 'package:firebase_tutorial/controller/product_controller.dart';
import 'package:firebase_tutorial/services/firestore_services.dart';
import 'package:firebase_tutorial/views/category_screen/item_details.dart';
import 'package:firebase_tutorial/views/widgets_common/bg_widget.dart';
import 'package:firebase_tutorial/views/widgets_common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryDetails extends StatefulWidget {
  final String? title;
  const CategoryDetails({super.key, required this.title});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  // gọi method switchCategory ngay từ khi init
  @override
  void initState() {
    super.initState();
    switchCategory(widget.title);
  }

  // logic filter theo danh mục phụ
  switchCategory(title) {
    if (controller.subCate.contains(title)) {
      productMethod = FirestoreServices.getSubCategoryProduct(title);
    } else {
      productMethod = FirestoreServices.getProducts(title);
    }
  }

  var controller = Get.find<ProductController>();

  // biến động logic filter danh mục phụ
  dynamic productMethod;

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          title: widget.title!.text.fontFamily(bold).white.make(),
        ),
        // Tạo danh mục cuốn ngang
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Tạo "Danh Mục phụ" cuốn ngang
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  /// Số lượng List dựa theo subCategory length
                  controller.subCate.length,
                  (index) => "${controller.subCate[index]}"
                      .text
                      .size(14)
                      .fontFamily(semibold)
                      .color(darkFontGrey)
                      .align(TextAlign.center)
                      .makeCentered()
                      .box
                      .white
                      .rounded
                      .size(120, 60)
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .make()
                      .onTap(() {
                    switchCategory("${controller.subCate[index]}");
                    setState(() {});
                  }),
                ),
              ),
            ),
            20.heightBox,

            /// Tạo StreamBuilder nhận dữ liệu từ Firebase
            StreamBuilder(
              stream: productMethod,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: loadingIndicator(),
                    ),
                  );
                } else if (snapshot.data!.docs.isEmpty) {
                  return Expanded(
                    child: "Không tìm thấy sản phẩm!"
                        .text
                        .color(darkFontGrey)
                        .makeCentered(),
                  );
                } else {
                  var data = snapshot.data!.docs;

                  return Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,

                      /// số lượng item tùy vào độ dài của data
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,

                        /// Chiều dài Grid item
                        mainAxisExtent: 290,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Lấy image Url từ data
                            Image.network(
                              data[index]['p_imgs'][0],
                              height: 170,
                              width: 200,
                              fit: BoxFit.cover,
                            ),

                            10.heightBox,

                            /// Lấy tên product từ data
                            "${data[index]['p_name']}"
                                .text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                            10.heightBox,

                            /// Lấy giá tiền product từ data
                            "${data[index]['p_price']}"
                                .numCurrencyWithLocale(locale: "vi")
                                .text
                                .color(redColor)
                                .fontFamily(bold)
                                .size(16)
                                .make(),
                            10.heightBox,
                          ],
                        )
                            .box
                            .white
                            .margin(const EdgeInsets.symmetric(horizontal: 4))
                            .roundedSM
                            .outerShadowSm
                            .padding(const EdgeInsets.all(12))
                            .make()
                            .onTap(() {
                          controller.checkIfFav(data[index]);
                          Get.to(() => ItemDetails(
                                title: "${data[index]['p_name']}",
                                data: data[index],
                              ));
                        });
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
