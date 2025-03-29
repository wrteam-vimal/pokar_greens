class RatingReasonList {
  String? success;
  String? total;
  List<RatingReason>? data;

  RatingReasonList({this.success, this.total, this.data});

  RatingReasonList.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <RatingReason>[];
      json['data'].forEach((v) {
        data!.add(RatingReason.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = this.success;
    dataMap['total'] = this.total;
    if (this.data != null) {
      dataMap['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class RatingReason {
  String? id;
  String? reason;
  String? status;
  String? createdAt;
  String? updatedAt;

  RatingReason({
    this.id,
    this.reason,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  RatingReason.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    reason = json['reason'].toString();
    status = json['status'].toString();
    createdAt = json['created_at'].toString();
    updatedAt = json['updated_at'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = this.id;
    dataMap['reason'] = this.reason;
    dataMap['status'] = this.status;
    dataMap['created_at'] = this.createdAt;
    dataMap['updated_at'] = this.updatedAt;
    return dataMap;
  }
}
