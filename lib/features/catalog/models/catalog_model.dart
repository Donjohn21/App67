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
      id: json['id'] ?? 0,
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'],
      descripcionCorta: json['descripcionCorta'] ?? json['descripcion_corta'],
      descripcion: json['descripcion'],
      imagenes: (json['imagenes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      especificaciones: json['especificaciones'],
    );
  }
}
