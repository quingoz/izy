// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carrito_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarritoItemAdapter extends TypeAdapter<CarritoItem> {
  @override
  final int typeId = 0;

  @override
  CarritoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarritoItem(
      productoId: fields[0] as int,
      nombre: fields[1] as String,
      imagenUrl: fields[2] as String?,
      precioUnitarioUsd: fields[3] as double,
      precioUnitarioBs: fields[4] as double,
      cantidad: fields[5] as int,
      variantes: (fields[6] as List?)?.cast<VarianteSeleccionada>(),
      notas: fields[7] as String?,
      stockDisponible: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CarritoItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.productoId)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.imagenUrl)
      ..writeByte(3)
      ..write(obj.precioUnitarioUsd)
      ..writeByte(4)
      ..write(obj.precioUnitarioBs)
      ..writeByte(5)
      ..write(obj.cantidad)
      ..writeByte(6)
      ..write(obj.variantes)
      ..writeByte(7)
      ..write(obj.notas)
      ..writeByte(8)
      ..write(obj.stockDisponible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarritoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VarianteSeleccionadaAdapter extends TypeAdapter<VarianteSeleccionada> {
  @override
  final int typeId = 1;

  @override
  VarianteSeleccionada read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VarianteSeleccionada(
      name: fields[0] as String,
      value: fields[1] as String,
      priceUsd: fields[2] as double?,
      priceBs: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, VarianteSeleccionada obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.priceUsd)
      ..writeByte(3)
      ..write(obj.priceBs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VarianteSeleccionadaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
