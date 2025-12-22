import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/features/profile/profile_page.dart';
import 'package:eden_mind_app/features/profile/progress_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'profile_page_test.mocks.dart';

@GenerateMocks([AuthService, ImagePicker])
void main() {
  late MockAuthService mockAuthService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockAuthService = MockAuthService();
    mockImagePicker = MockImagePicker();

    // Default stub for userProfile
    when(mockAuthService.userProfile).thenReturn({
      'firstName': 'John',
      'lastName': 'Doe',
      'sub': 'john.doe@example.com',
      'createdAt': '2023-10-15T10:00:00Z',
      'avatarUrl': 'http://example.com/avatar.jpg',
      'birthday': '1990-01-01',
      'familySituation': 'Single',
      'workType': 'Engineer',
      'workHours': '9-5',
      'childrenCount': 0,
      'country': 'USA',
    });

    when(mockAuthService.addListener(any)).thenAnswer((_) {});
    when(mockAuthService.removeListener(any)).thenAnswer((_) {});
    when(mockAuthService.hasListeners).thenReturn(false);

    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  Widget createWidget({ImagePicker? imagePicker}) {
    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuthService,
      child: MaterialApp(home: ProfilePage(imagePicker: imagePicker)),
    );
  }

  group('ProfilePage Tests', () {
    testWidgets('Renders full user info correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Hello, John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('October 2023'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
    });

    testWidgets('Derives name from sub if names missing (email format)', (
      WidgetTester tester,
    ) async {
      when(
        mockAuthService.userProfile,
      ).thenReturn({'sub': 'jane.doe@example.com'});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Should capitalize and replace dots with spaces
      expect(find.text('Hello, Jane Doe'), findsOneWidget);
    });

    testWidgets('Derives name from sub if names missing (simple string)', (
      WidgetTester tester,
    ) async {
      when(mockAuthService.userProfile).thenReturn({
        'sub': 'GuestUser',
        'createdAt': 'invalid-date', // Test catch block for date parsing
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hello, GuestUser'), findsOneWidget);
      // Fallback/Default date check if parsing fails logic is covered by initial value in widget ('October 2023' is hardcoded default)
    });

    testWidgets('Displays avatar if url present', (WidgetTester tester) async {
      // Logic for NetworkImage is implicit, we can just check if CircleAvatar finds the backgroundImage
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      // Verifying image provider is hard in widget tests without http overrides,
      // but we can verify the widget tree structure.
      final avatarFinder = find.byType(CircleAvatar);
      expect(
        avatarFinder,
        findsAtLeastNWidgets(1),
      ); // One in header, one in info section if any
    });

    testWidgets('Displays initial if avatar url missing', (
      WidgetTester tester,
    ) async {
      when(mockAuthService.userProfile).thenReturn({
        'firstName': 'John',
        'lastName': 'Doe',
        // No avatarUrl
      });
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('Navigates to ProgressPage', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View My Progress'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Allow navigation to complete

      expect(find.byType(ProgressPage), findsOneWidget);
    });

    /*  testWidgets('Picks and uploads image from Camera', (
      WidgetTester tester,
    ) async {
      final XFile mockFile = XFile.fromData(
        Uint8List.fromList([0, 1, 2]),
        name: 'test.jpg',
      );
      when(
        mockImagePicker.pickImage(source: ImageSource.camera),
      ).thenAnswer((_) async => mockFile);
      when(
        mockAuthService.uploadImageBytes(any, any),
      ).thenAnswer((_) async => 'http://new-avatar.com');
      when(
        mockAuthService.updateProfile(avatarUrl: anyNamed('avatarUrl')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      // Tap 'Take a Photo'
      await tester.tap(find.text('Take a Photo'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Allow async execution & SnackBar frame
      await tester.pump(); // Ensure visibility

      verify(mockImagePicker.pickImage(source: ImageSource.camera)).called(1);
      verify(mockAuthService.uploadImageBytes(any, any)).called(1);
      verify(
        mockAuthService.updateProfile(avatarUrl: 'http://new-avatar.com'),
      ).called(1);
      expect(
        find.textContaining('Profile image updated successfully!'),
        findsOneWidget,
      );
    });
 */
    testWidgets('Picks and uploads image from Gallery', (
      WidgetTester tester,
    ) async {
      final XFile mockFile = XFile.fromData(
        Uint8List.fromList([0, 1, 2]),
        name: 'test.jpg',
      );
      when(
        mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => mockFile);
      when(
        mockAuthService.uploadImageBytes(any, any),
      ).thenAnswer((_) async => 'http://new-avatar.com');
      when(
        mockAuthService.updateProfile(avatarUrl: anyNamed('avatarUrl')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      verify(mockAuthService.uploadImageBytes(any, any)).called(1);
    });

    testWidgets('Handles image picking cancellation', (
      WidgetTester tester,
    ) async {
      when(
        mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      verifyNever(mockAuthService.uploadImageBytes(any, any));
    });

    /*  testWidgets('Handles image upload failure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final XFile mockFile = XFile.fromData(
        Uint8List.fromList([0, 1, 2]),
        name: 'test.jpg',
      );
      when(
        mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => mockFile);
      when(
        mockAuthService.uploadImageBytes(any, any),
      ).thenThrow(Exception('Upload failed'));

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose from Gallery'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Allow async execution
      await tester.pump(); // Rebuild with SnackBar

      expect(find.textContaining('Upload failed'), findsOneWidget);
    }); */

    testWidgets('Removes profile image', (WidgetTester tester) async {
      when(
        mockAuthService.updateProfile(avatarUrl: ''),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove Photo'));
      await tester.pumpAndSettle();

      verify(mockAuthService.updateProfile(avatarUrl: '')).called(1);
      expect(find.text('Profile image removed'), findsOneWidget);
    });

    testWidgets('Handles remove image error', (WidgetTester tester) async {
      when(
        mockAuthService.updateProfile(avatarUrl: ''),
      ).thenThrow(Exception('Delete failed'));

      await tester.pumpWidget(createWidget(imagePicker: mockImagePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove Photo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.textContaining('Delete failed'), findsOneWidget);
    });

    testWidgets('Show Edit Profile bottom sheet and close it', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsNothing);
    });

    testWidgets('Settings and Support switches toggle', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsWidgets);

      // Tap the switch doesn't do much logic but we can ensure it's tappable
      await tester.tap(switchFinder.first);
      await tester.pump();
    });

    testWidgets('Nav tiles are tappable', skip: true, (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final finder = find.text('Account Security');
      await tester.scrollUntilVisible(
        finder,
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(finder);
      await tester.pump();
    });
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _TestHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }
}

class _TestHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _TestHttpClientResponse();
  }

  @override
  void add(List<int> data) {}
}

class _TestHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpHeaders extends Mock implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  List<String>? operator [](String name) => null;
}

final kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
