import 'package:hive/hive.dart';
import 'cart_item.dart';

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      productId: fields[0] as int,
      storeName: fields[1] as String,
      quantity: fields[2] as int,
      selectedAttributes: fields[3] as String?,
      notes: fields[4] as String?,
      addedAt: fields[5] != null ? DateTime.parse(fields[5] as String) : null,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.selectedAttributes)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.addedAt?.toIso8601String());
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
