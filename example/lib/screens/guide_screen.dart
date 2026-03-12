import 'package:flutter/material.dart';
import '../theme/typography.dart';
import '../theme/styles.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('개발자 가이드', style: AdropTypography.screenTitle),
            const SizedBox(height: 16),

            // SDK 초기화
            const Text('SDK 초기화', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            _descriptionCard(
              'main()에서 runApp() 호출 전에 초기화합니다.\n\n'
              '• Production  Adrop.initialize(true)\n'
              '• Debug          Adrop.initialize(false)\n\n'
              '⚠ Debug 모드에서는 테스트 광고가 노출됩니다.\n'
              '     출시 전 반드시 Production으로 전환하세요.',
            ),

            const SizedBox(height: 16),

            // 광고 포맷
            const Text('광고 포맷', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            ..._buildFormatCards(),

            const Divider(height: 32),

            // 속성 설정
            const Text('속성 설정', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            _descriptionCard(
              '사용자 속성을 키-값 쌍으로 설정합니다.\n\n'
              'AdropMetrics.setProperty(key, value)\n\n'
              '지원 타입\n'
              'String · int · double · bool · null\n\n'
              '예시\n'
              'setProperty("age", 25)\n'
              'setProperty("gender", "male")\n'
              'setProperty("premium", true)',
            ),

            const Divider(height: 32),

            // 동의 관리
            const Text('동의 관리', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            _descriptionCard(
              'GDPR 등 개인정보 보호 규정에 대응합니다.\n\n'
              '1. Adrop.consentManager로 접근\n'
              '2. requestConsentInfoUpdate()로 동의 상태 요청\n'
              '3. 콜백 함수로 결과 수신\n\n'
              '동의 상태에 따라 광고 요청 및 맞춤 광고 노출 여부가 결정됩니다.',
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildFormatCards() {
    const formats = [
      (
        '배너 광고 (Banner)',
        '화면 상·하단에 표시되는 직사각형 광고\n\n'
            '• 동영상  16:9 / 9:16\n'
            '• 이미지   375×80 / 320×50',
      ),
      (
        '네이티브 광고 (Native)',
        '앱 디자인에 자연스럽게 녹아드는 맞춤형 광고\n\n'
            '구성: 프로필 · 헤드라인 · 미디어 · 본문 · CTA 버튼',
      ),
      (
        '전면 광고 (Interstitial)',
        '전체 화면으로 표시되는 광고\n\n'
            '페이지 이동, 앱 종료 등 자연스러운 전환 시점에 노출을 권장합니다.',
      ),
      (
        '보상형 광고 (Rewarded)',
        '동영상 시청 후 앱 내 보상을 제공하는 광고\n\n'
            '• 지원 포맷  9:16 동영상',
      ),
      (
        '팝업 광고 (Popup)',
        '화면 위에 오버레이로 표시되는 광고\n\n'
            '• 위치  하단 / 중앙\n'
            '• 오늘 하루 보지 않기 · 커스텀 스타일링 지원',
      ),
      (
        '스플래시 광고 (Splash)',
        '앱 실행 시 전체 화면으로 표시되는 광고\n\n'
            '• 자동 닫기 타이머 · 건너뛰기 옵션 제공',
      ),
    ];

    return formats
        .map(
          (f) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: AdropStyles.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.$1, style: AdropTypography.formatTitle),
                const SizedBox(height: 4),
                Text(f.$2, style: AdropTypography.body),
              ],
            ),
          ),
        )
        .toList();
  }

  static Widget _descriptionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AdropStyles.card,
      child: Text(text, style: AdropTypography.body),
    );
  }
}
