import '../../../core/utils/parse_utils.dart';

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
      id: ParseUtils.toIntSafe(json['id']),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      totalRespuestas: ParseUtils.toIntSafe(json['totalRespuestas']),
      vehiculo: json['vehiculo']?.toString(),
      vehiculoFoto: json['vehiculoFoto']?.toString(),
      autor: json['autor']?.toString(),
      respuestas: (json['respuestas'] as List?)
              ?.map((e) => ForumReply.fromJson(e as Map<String, dynamic>))
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
      id: ParseUtils.toIntSafe(json['id']),
      contenido: json['contenido']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      autor: json['autor']?.toString(),
    );
  }
}
