import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<Widget?> _cachedChildren;

  @override
  void initState() {
    super.initState();
    _cachedChildren = List<Widget?>.filled(widget.children.length, null);
    _cacheChild(widget.index);
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _cachedChildren = List<Widget?>.generate(
        widget.children.length,
        (index) => index < _cachedChildren.length ? _cachedChildren[index] : null,
      );
    }
    for (var i = 0; i < _cachedChildren.length; i++) {
      if (_cachedChildren[i] != null) {
        _cachedChildren[i] = widget.children[i];
      }
    }
    _cacheChild(widget.index);
  }

  void _cacheChild(int index) {
    if (index < 0 || index >= widget.children.length) {
      return;
    }
    _cachedChildren[index] ??= widget.children[index];
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        return _cachedChildren[i] ?? const SizedBox.shrink();
      }),
    );
  }
}
