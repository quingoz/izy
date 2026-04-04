import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class ProductosSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const ProductosSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<ProductosSearchBar> createState() => _ProductosSearchBarState();
}

class _ProductosSearchBarState extends State<ProductosSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IzySpacing.md),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
        ),
        onChanged: widget.onSearch,
      ),
    );
  }
}
