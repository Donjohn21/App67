import 'package:flutter/material.dart';
import '../models/catalog_model.dart';
import '../services/catalog_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class CatalogDetailScreen extends StatefulWidget {
  final int catalogId;
  const CatalogDetailScreen({super.key, required this.catalogId});

  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  CatalogItem? _item;
  String? _error;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _item = null; });
    try {
      final item = await CatalogService.getDetail(widget.catalogId);
      if (mounted) setState(() => _item = item);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item != null ? '${_item!.marca} ${_item!.modelo}' : 'Detalle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) return AppError(message: _error!, onRetry: _load);
    if (_item == null) return const AppLoading();

    final images = _item!.imagenes.isNotEmpty ? _item!.imagenes : [_item!.imagen ?? ''];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image viewer
          Stack(
            children: [
              AppNetworkImage(
                url: images[_imageIndex],
                height: 250,
                width: double.infinity,
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) => GestureDetector(
                      onTap: () => setState(() => _imageIndex = i),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _imageIndex ? AppTheme.primary : Colors.white60,
                        ),
                      ),
                    )),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_item!.marca} ${_item!.modelo} ${_item!.anio}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(AppDateUtils.formatCurrency(_item!.precio),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                if (_item!.descripcion != null && _item!.descripcion!.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text('Descripción',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_item!.descripcion!,
                      style: const TextStyle(color: AppTheme.textSecondary, height: 1.5)),
                ],
                if (_item!.especificaciones != null && _item!.especificaciones!.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text('Especificaciones',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._item!.especificaciones!.entries.map((e) => InfoRow(
                    icon: Icons.check_circle_outline,
                    label: e.key,
                    value: e.value.toString(),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
