import 'dart:convert';

import 'package:isar/isar.dart';

part 'verification_item.g.dart';

@collection
class VerificationItem {
  Id? id;
  String? type;
  String? name;
  String? vendor;
  String? key;
  int? time;
  int? length;
  String? sha;
  int? counter;
  int? used;

  VerificationItem(
      {this.type,
      this.name,
      this.vendor,
      this.key,
      this.time,
      this.length,
      this.sha,
      this.counter,
      this.used,
      this.id = Isar.autoIncrement});

  @override
  String toString() {
    return 'VerificationItem(type: $type, name: $name, vendor: $vendor, key: $key, time: $time, length: $length, sha: $sha, counter: $counter, used: $used,id:$id)';
  }

  factory VerificationItem.fromMap(Map<String, dynamic> data) {
    return VerificationItem(
        type: data['type'] as String?,
        name: data['name'] as String?,
        vendor: data['vendor'] as String?,
        key: data['key'] as String?,
        time: data['time'] as int?,
        length: data['length'] as int?,
        sha: data['sha'] as String?,
        counter: data['counter'] as int?,
        used: data['used'] as int?,
        id: data['id'] as Id? ?? Isar.autoIncrement);
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'vendor': vendor,
        'key': key,
        'time': time,
        'length': length,
        'sha': sha,
        'counter': counter,
        'used': used,
        'id': id
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [VerificationItem].
  factory VerificationItem.fromJson(String data) {
    return VerificationItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [VerificationItem] to a JSON string.
  String toJson() => json.encode(toMap());

  VerificationItem copyWith(
      {String? type,
      String? name,
      String? vendor,
      String? key,
      int? time,
      int? length,
      String? sha,
      int? counter,
      int? used,
      Id? id}) {
    return VerificationItem(
        type: type ?? this.type,
        name: name ?? this.name,
        vendor: vendor ?? this.vendor,
        key: key ?? this.key,
        time: time ?? this.time,
        length: length ?? this.length,
        sha: sha ?? this.sha,
        counter: counter ?? this.counter,
        used: used ?? this.used,
        id: id ?? this.id);
  }
}
