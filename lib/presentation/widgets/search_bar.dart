import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../providers/dependencies_provider.dart';
import 'app_text_field.dart';

/// Barra de pesquisa reutilizável com debounce
class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({
    super.key,
    this.hintText = 'Pesquisar louvores...',
    this.onChanged,
    this.debounceMilliseconds = 300,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final int debounceMilliseconds;

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sincronizar com o provider inicial após montagem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = ref.read(searchQueryProvider);
      if (_controller.text != query && mounted) {
        _controller.text = query;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Atualizar provider imediatamente (para UI responsiva)
    ref.read(searchQueryProvider.notifier).state = value;

    // Executar callback após debounce
    _debounceTimer = Timer(
      Duration(milliseconds: widget.debounceMilliseconds),
      () {
        widget.onChanged?.call(value);
      },
    );
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.mediumRadius,
        boxShadow: [
          AppShadows.small,
        ],
      ),
      child: AppTextField(
        controller: _controller,
        hint: widget.hintText,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textDark,
        ),
        suffixIcon: Consumer(
          builder: (context, ref, _) {
            final query = ref.watch(searchQueryProvider);
            if (query.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppColors.textDark,
              ),
              onPressed: _clearSearch,
            );
          },
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}

