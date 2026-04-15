class NewsItem {
  final int id;
  final String titulo;
  final String resumen;
  final String? imagen;
  final String fecha;
  final String? fuente;
  final String? link;
  final String? contenido;

  NewsItem({
    required this.id,
    required this.titulo,
    required this.resumen,
    this.imagen,
    required this.fecha,
    this.fuente,
    this.link,
    this.contenido,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      resumen: json['resumen'] ?? '',
      imagen: json['imagen'],
      fecha: json['fecha'] ?? '',
      fuente: json['fuente'],
      link: json['link'],
      contenido: json['contenido'],
    );
  }
}
