// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart'; // Убедитесь, что путь правильный

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Удалили 'const'

    // Verify that our counter starts at 0.
    // В данном случае, у вас нет счетчика, так что этот тест не будет работать
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // Вы можете заменить его на проверку наличия определенных элементов UI
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Например, если вы хотите проверить наличие кнопки добавления задачи:
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Здесь можно добавить дополнительные проверки, соответствующие вашему приложению
  });
}
