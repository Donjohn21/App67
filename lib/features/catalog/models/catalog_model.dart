import '../../../core/utils/parse_utils.dart';

class CatalogItem {
  final int id;
  final String marca;
  final String modelo;
  final int anio;
  final double precio;
  final String? imagen;
  final String? descripcionCorta;
  final String? descripcion;
  final List<String> imagenes;
  final Map<String, dynamic>? especificaciones;

  CatalogItem({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.precio,
    this.imagen,
    this.descripcionCorta,
    this.descripcion,
    this.imagenes = const [],
    this.especificaciones,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: ParseUtils.toIntSafe(json['id']),
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      anio: ParseUtils.toIntSafe(json['anio']),
      // precio may arrive as String
      precio: ParseUtils.toDoubleSafe(json['precio']),
      imagen: json['imagen']?.toString(),
      descripcionCorta: json['descripcionCorta']?.toString() ??
          json['descripcion_corta']?.toString(),
      descripcion: json['descripcion']?.toString(),
      imagenes:
          (json['imagenes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      especificaciones: json['especificaciones'] as Map<String, dynamic>?,
    );
  }
}
