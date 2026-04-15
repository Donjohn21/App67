class VideoItem {
  final int id;
  final String youtubeId;
  final String titulo;
  final String descripcion;
  final String? categoria;
  final String? thumbnail;

  VideoItem({
    required this.id,
    required this.youtubeId,
    required this.titulo,
    required this.descripcion,
    this.categoria,
    this.thumbnail,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] ?? 0,
      youtubeId: json['youtubeId'] ?? json['youtube_id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'],
      thumbnail: json['thumbnail'],
    );
  }
}
