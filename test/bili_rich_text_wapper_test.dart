import 'package:better_bilibili/ui/core/bilibili/rich_text/bili_rich_text_wapper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows expand toggle when a line overflows horizontally', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 80,
            child: BiliRichTextWapper(
              rawText: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              parserNodes: [],
              maxLines: 4,
            ),
          ),
        ),
      ),
    );

    expect(find.text('展开'), findsOneWidget);
  });
}
