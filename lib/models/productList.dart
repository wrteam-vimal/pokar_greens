import 'package:project/helper/utils/generalImports.dart';

class ProductList {
  ProductList({
    required this.status,
    required this.message,
    required this.total,
    required this.totalMinPrice,
    required this.totalMaxPrice,
    required this.brands,
    required this.sizes,
    required this.data,
  });

  late final String status;
  late final String message;
  late final String total;
  late final String totalMinPrice;
  late final String totalMaxPrice;
  late final List<Brands>? brands;
  late final List<Sizes>? sizes;
  late final List<ProductListItem> data;

  ProductList.fromJson(Map<String, dynamic> json) {
    if (List.from(json['data'])
            .map((e) => ProductListItem.fromJson(e))
            .toList() !=
        []) {
      status = json['status'].toString();
      message = json['message'].toString();
      total = json['total'].toString();
      totalMinPrice = json['total_min_price'].toString();
      totalMaxPrice = json['total_max_price'].toString();
      if (json.containsKey("brands")) {
        brands =
            List.from(json['brands']).map((e) => Brands.fromJson(e)).toList();
      } else {
        brands = [];
      }
      if (json.containsKey("sizes")) {
        sizes = List.from(json['sizes']).map((e) => Sizes.fromJson(e)).toList();
      } else {
        sizes = [];
      }
      data = List.from(json['data'])
          .map((e) => ProductListItem.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final itemData = <String, dynamic>{};
    itemData['status'] = status;
    itemData['message'] = message;
    itemData['total'] = total;
    itemData['total_min_price'] = totalMinPrice;
    itemData['total_max_price'] = totalMaxPrice;
    if (brands == null) {
      brands = [];
    } else {
      itemData['brands'] = brands?.map((e) => e.toJson()).toList();
    }
    if (sizes == null) {
      sizes = [];
    } else {
      itemData['sizes'] = sizes?.map((e) => e.toJson()).toList();
    }
    itemData['data'] = data.map((e) => e.toJson()).toList();
    return itemData;
  }
}

class Brands {
  Brands({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  late final String id;
  late final String name;
  late final String imageUrl;

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    imageUrl = json['image_url'].toString();
  }

  Map<String, dynamic> toJson() {
    final itemData = <String, dynamic>{};
    itemData['id'] = id;
    itemData['name'] = name;
    itemData['image_url'] = imageUrl;
    return itemData;
  }
}

class Sizes {
  Sizes({
    required this.size,
    required this.shortCode,
    required this.unitId,
  });

  late final String size;
  late final String shortCode;
  late final String unitId;

  Sizes.fromJson(Map<String, dynamic> json) {
    size = json['size'].toString();
    shortCode = json['short_code'].toString();
    unitId = json['unit_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final itemData = <String, dynamic>{};
    itemData['size'] = size;
    itemData['short_code'] = shortCode;
    itemData['unit_id'] = unitId;
    return itemData;
  }
}
