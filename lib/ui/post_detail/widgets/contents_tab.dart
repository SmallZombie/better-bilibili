import 'package:material_ui/material_ui.dart';

class ContentsTab extends StatefulWidget {
  final List<String> contents;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const ContentsTab({super.key, required this.contents, required this.currentIndex, required this.onIndexChanged});

  @override
  State<ContentsTab> createState() => _ContentsTabState();
}

class _ContentsTabState extends State<ContentsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      itemCount: widget.contents.length,
      itemBuilder:
          (context, index) => Material(
            child: ListTile(
              onTap: () => widget.onIndexChanged(index),
              title: Text(
                widget.contents[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              dense: true,
              selected: index == widget.currentIndex,
            ),
          ),
    );
  }
}
