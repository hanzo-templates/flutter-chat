import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzo_flutter_chat/hanzo.dart';
import 'package:hanzo_flutter_chat/main.dart';

void main() {
  testWidgets('sending with no key surfaces the config error, not a crash', (tester) async {
    Hanzo.instance.key = '';
    await tester.pumpWidget(const ChatApp());

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('No API key'), findsOneWidget);
    // The user turn is kept so the draft is not lost to a failed send.
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('settings edits the live config', (tester) async {
    await tester.pumpWidget(const ChatApp());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'zen-coder');
    expect(Hanzo.instance.model, 'zen-coder');
  });
}
