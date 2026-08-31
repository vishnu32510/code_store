import 'package:code_store_share/code_store_share.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockShareService implements IShareService {
  String? lastSharedText;
  Uri? lastSharedUri;
  List<String>? lastSharedFiles;

  @override
  Future<void> shareText({required String text, String? subject}) async {
    lastSharedText = text;
  }

  @override
  Future<void> shareUri({required Uri uri, String? text}) async {
    lastSharedUri = uri;
  }

  @override
  Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
  }) async {
    lastSharedFiles = filePaths;
    lastSharedText = text;
  }

  @override
  Future<void> shareContent(AppShareContent content) async {
    if (content.filePaths.isNotEmpty) {
      await shareFiles(
        filePaths: content.filePaths,
        text: content.fullMessageText,
        subject: content.subject,
      );
    } else {
      await shareText(text: content.fullMessageText, subject: content.subject);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Share Models & DI', () {
    final sl = GetIt.asNewInstance();

    test('AppShareContent model combines text and url', () {
      const content = AppShareContent(
        text: 'Check out CodeStore!',
        url: 'https://codestore.app',
      );

      expect(
        content.fullMessageText,
        'Check out CodeStore!\nhttps://codestore.app',
      );
    });

    test('setupShareDI registers mock service correctly', () {
      final mock = MockShareService();
      setupShareDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IShareService>(), true);
      expect(sl<IShareService>(), isA<MockShareService>());
    });

    test('MockShareService receives share calls', () async {
      final mock = MockShareService();
      await mock.shareText(text: 'Hello World');
      expect(mock.lastSharedText, 'Hello World');

      await mock.shareUri(uri: Uri.parse('https://example.com'));
      expect(mock.lastSharedUri, Uri.parse('https://example.com'));
    });
  });
}
