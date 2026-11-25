import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_grievance/features/officer/presentation/officer_dashboard_screen.dart';
import 'package:smart_grievance/features/officer/presentation/officer_grievance_action_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OfficerDashboardScreen renders portal header and queue metrics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OfficerDashboardScreen(),
      ),
    );

    // Wait for async load fallback
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Department Officer Portal'), findsOneWidget);
    expect(find.text('Jurisdiction: Itanagar Capital Complex'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('SLA Alert'), findsWidgets);
  });

  testWidgets('OfficerGrievanceActionScreen renders grievance details and status dropdown', (tester) async {
    const sample = {
      'id': 'grv-101',
      'reference_number': 'GRV-2026-0101',
      'title': 'Broken pipeline at Bank Tinali',
      'description': 'Major water leak affecting main road.',
      'location_address': 'Bank Tinali, Itanagar',
      'status': 'SUBMITTED',
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: OfficerGrievanceActionScreen(grievance: sample),
      ),
    );

    expect(find.text('Action: GRV-2026-0101'), findsOneWidget);
    expect(find.text('Broken pipeline at Bank Tinali'), findsOneWidget);
    expect(find.text('Submit Official Action'), findsOneWidget);
  });
}
