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
    final name = fields[2] as String?;
    final price = fields[3] as double?;
    return CartItem(
      productId: fields[0] as int,
      storeName: fields[1] as String,
      name: name ?? '',
      price: price ?? 0.0,
      image: fields[4] as String?,
      quantity: fields[5] as int? ?? 1,
      isWholesale: fields[6] as bool? ?? false,
      selectedAttributes: fields[7] as String?,
      notes: fields[8] as String?,
      addedAt: fields[9] != null ? DateTime.parse(fields[9] as String) : null,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.isWholesale)
      ..writeByte(7)
      ..write(obj.selectedAttributes)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
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
