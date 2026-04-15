class ForumTopic {
  final int id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final int totalRespuestas;
  final String? vehiculo;
  final String? vehiculoFoto;
  final String? autor;
  final List<ForumReply> respuestas;

  ForumTopic({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.totalRespuestas,
    this.vehiculo,
    this.vehiculoFoto,
    this.autor,
    this.respuestas = const [],
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      totalRespuestas: json['totalRespuestas'] ?? 0,
      vehiculo: json['vehiculo'],
      vehiculoFoto: json['vehiculoFoto'],
      autor: json['autor'],
      respuestas: (json['respuestas'] as List?)
              ?.map((e) => ForumReply.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ForumReply {
  final int id;
  final String contenido;
  final String fecha;
  final String? autor;

  ForumReply({
    required this.id,
    required this.contenido,
    required this.fecha,
    this.autor,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['id'] ?? 0,
      contenido: json['contenido'] ?? '',
      fecha: json['fecha'] ?? '',
      autor: json['autor'],
    );
  }
}
