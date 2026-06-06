class AppConstants {
  static const String appName = 'PrivShot';
  static const String appTagline = 'Screenshot Privacy Tool';

  static const double canvasMaxHeight = 420;
  static const double canvasPadding = 16.0;

  static const List<String> blockedEmailDomains = [
    'example.com',
    'test.com',
    'sample.com',
    'localhost',
    'email.com',
    'domain.com',
  ];

  static const List<String> privateIpPrefixes = [
    '10.',
    '192.168.',
    '172.16.',
    '172.17.',
    '172.18.',
    '172.19.',
    '172.20.',
    '172.21.',
    '172.22.',
    '172.23.',
    '172.24.',
    '172.25.',
    '172.26.',
    '172.27.',
    '172.28.',
    '172.29.',
    '172.30.',
    '172.31.',
    '127.',
    '169.254.',
  ];
}