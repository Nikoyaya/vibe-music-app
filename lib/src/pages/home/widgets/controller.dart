import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';

class HomeController extends GetxController {
  // 当前选中的页面索引
  var currentPage = 0.obs;

  // 页面标题
  final pageTitles = {
    0: '音乐库',
    1: '搜索',
    2: '我的收藏',
    3: '个人中心',
  };

  /// 切换页面
  void changePage(int index) {
    currentPage.value = index;
  }

  /// 获取当前页面标题
  String getCurrentPageTitle() {
    return pageTitles[currentPage.value] ?? 'Vibe Music Player';
  }

  /// 导航到设置页面
  void navigateToSettings() {
    // 实现设置页面导航逻辑
    final localizations = AppLocalizations.of(Get.context!);
    Get.snackbar(
        localizations?.settings ?? 'Settings',
        localizations?.settingsPageComingSoon ??
            'Settings page will be implemented soon');
  }
}
