import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_eye/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TeacherEyeApp());
    expect(find.text('TeacherEye AI'), findsWidgets);
  });
}
