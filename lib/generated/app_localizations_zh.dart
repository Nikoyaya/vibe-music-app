// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Vibe 音乐';

  @override
  String get home => '首页';

  @override
  String get search => '搜索';

  @override
  String get player => '播放器';

  @override
  String get favorites => '收藏';

  @override
  String get my => '我的';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get logout => '退出登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get username => '用户名';

  @override
  String get enterEmail => '请输入邮箱';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get enterConfirmPassword => '请确认密码';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get registerSuccess => '注册成功';

  @override
  String get loginFailed => '登录失败';

  @override
  String get registerFailed => '注册失败';

  @override
  String get language => '语言';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get english => '英语';

  @override
  String get chinese => '简体中文';

  @override
  String get traditionalChinese => '繁体中文';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

  @override
  String get about => '关于';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get autoMode => '自动模式';

  @override
  String get theme => '主题';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get next => '下一首';

  @override
  String get previous => '上一首';

  @override
  String get shuffle => '随机播放';

  @override
  String get repeat => '循环播放';

  @override
  String get volume => '音量';

  @override
  String get duration => '时长';

  @override
  String get album => '专辑';

  @override
  String get artist => '歌手';

  @override
  String get genre => '流派';

  @override
  String get year => '年份';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get removeFromFavorites => '从收藏中移除';

  @override
  String get share => '分享';

  @override
  String get download => '下载';

  @override
  String get delete => '删除';

  @override
  String get confirmDelete => '确定要删除吗？';

  @override
  String get noResults => '未找到结果';

  @override
  String get searchHint => '搜索歌曲、艺术家、专辑...';

  @override
  String get networkError => '网络错误';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get success => '成功';

  @override
  String get error => '错误';

  @override
  String get ok => '确定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get songs => '歌曲';

  @override
  String get phone => '手机号';

  @override
  String get introduction => '个人简介';

  @override
  String get validEmail => '请输入有效的邮箱地址';

  @override
  String get validPhone => '请输入有效的手机号';

  @override
  String get introductionLimit => '个人简介不能超过100个字符';

  @override
  String get profileUpdateSuccess => '个人资料更新成功';

  @override
  String get profileUpdateFailed => '更新个人资料失败';

  @override
  String get pleaseLogin => '请先登录';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get avatarUpdateSuccess => '头像更新成功';

  @override
  String get avatarUpdateFailed => '更新头像失败';

  @override
  String get imagePickFailed => '选择图片失败';

  @override
  String confirmDeleteUser(Object username) {
    return '确定要删除 \'$username\' 吗？';
  }

  @override
  String confirmDeleteSong(Object songName) {
    return '确定要删除 \'$songName\' 吗？';
  }

  @override
  String get verificationCode => '验证码';

  @override
  String get enterVerificationCode => '请输入验证码';

  @override
  String get verificationCodeLength => '验证码必须是6位数字';

  @override
  String get sendVerificationCode => '发送验证码';

  @override
  String resendVerificationCode(Object countdown) {
    return '重新发送 (${countdown}s)';
  }

  @override
  String get alreadyHaveAccount => '已有账号？登录';

  @override
  String get dontHaveAccount => '没有账号？注册';

  @override
  String get usernameFormat => '用户名必须是4-16个字符，字母、数字、下划线或连字符';

  @override
  String get passwordLength => '密码至少6个字符';

  @override
  String get phoneFormat => '请输入有效的手机号';

  @override
  String get emailFormat => '请输入有效的邮箱';

  @override
  String get usernameRequired => '请输入用户名';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get emailRequired => '请输入邮箱';

  @override
  String get verificationCodeRequired => '请输入验证码';

  @override
  String get confirmPasswordRequired => '请确认密码';

  @override
  String get confirmPasswordMatch => '密码不匹配';

  @override
  String get playlist => '播放列表';

  @override
  String songsCount(Object count) {
    return '$count 首歌曲';
  }

  @override
  String get unknownSong => '未知歌曲';

  @override
  String get unknownArtist => '未知歌手';

  @override
  String get tip => '提示';

  @override
  String get removedFromFavorites => '已从收藏中移除';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get playNext => '下一首播放';

  @override
  String get addedToNextPlay => '已添加到下一首播放';

  @override
  String get searchFailed => '搜索失败，请重试';

  @override
  String get alreadyFavorited => '已在收藏中';

  @override
  String get verificationCodeSent => '验证码已发送！';

  @override
  String get failedToSendVerificationCode => '发送验证码失败';

  @override
  String get registrationSuccessful => '注册成功！请登录。';

  @override
  String get settingsPageComingSoon => '设置页面即将上线';

  @override
  String get confirmClose => '是否关闭';

  @override
  String get closePlayback => '关闭播放';

  @override
  String get confirmClosePlayback => '确定要关闭当前播放吗？';

  @override
  String get loginExpired => '登录失效，请重新登录';

  @override
  String get goToLogin => '去登录';

  @override
  String get recommendedPlaylists => '推荐歌单';

  @override
  String get viewMore => '查看更多';

  @override
  String get hotSongs => '热门歌曲';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Vibe 音樂';

  @override
  String get home => '首頁';

  @override
  String get search => '搜尋';

  @override
  String get player => '播放器';

  @override
  String get favorites => '收藏';

  @override
  String get my => '我的';

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get logout => '登出';

  @override
  String get email => '郵箱';

  @override
  String get password => '密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get username => '使用者名稱';

  @override
  String get enterEmail => '請輸入郵箱';

  @override
  String get enterPassword => '請輸入密碼';

  @override
  String get enterConfirmPassword => '請確認密碼';

  @override
  String get enterUsername => '請輸入使用者名稱';

  @override
  String get loginSuccess => '登入成功';

  @override
  String get registerSuccess => '註冊成功';

  @override
  String get loginFailed => '登入失敗';

  @override
  String get registerFailed => '註冊失敗';

  @override
  String get language => '語言';

  @override
  String get systemLanguage => '系統語言';

  @override
  String get english => '英語';

  @override
  String get chinese => '簡體中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get settings => '設定';

  @override
  String get profile => '個人資料';

  @override
  String get about => '關於';

  @override
  String get privacyPolicy => '隱私政策';

  @override
  String get termsOfService => '服務條款';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '淺色模式';

  @override
  String get autoMode => '自動模式';

  @override
  String get theme => '主題';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get play => '播放';

  @override
  String get pause => '暫停';

  @override
  String get next => '下一首';

  @override
  String get previous => '上一首';

  @override
  String get shuffle => '隨機播放';

  @override
  String get repeat => '循環播放';

  @override
  String get volume => '音量';

  @override
  String get duration => '時長';

  @override
  String get album => '專輯';

  @override
  String get artist => '歌手';

  @override
  String get genre => '流派';

  @override
  String get year => '年份';

  @override
  String get addToFavorites => '新增到收藏';

  @override
  String get removeFromFavorites => '從收藏中移除';

  @override
  String get share => '分享';

  @override
  String get download => '下載';

  @override
  String get delete => '刪除';

  @override
  String get confirmDelete => '確定要刪除嗎？';

  @override
  String get noResults => '未找到結果';

  @override
  String get searchHint => '搜尋歌曲、藝術家、專輯...';

  @override
  String get networkError => '網路錯誤';

  @override
  String get loading => '載入中...';

  @override
  String get retry => '重試';

  @override
  String get success => '成功';

  @override
  String get error => '錯誤';

  @override
  String get ok => '確定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get songs => '歌曲';

  @override
  String get phone => '手機號';

  @override
  String get introduction => '個人簡介';

  @override
  String get validEmail => '請輸入有效的郵箱地址';

  @override
  String get validPhone => '請輸入有效的手機號';

  @override
  String get introductionLimit => '個人簡介不能超過100個字符';

  @override
  String get profileUpdateSuccess => '個人資料更新成功';

  @override
  String get profileUpdateFailed => '更新個人資料失敗';

  @override
  String get pleaseLogin => '請先登入';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '從相冊選擇';

  @override
  String get avatarUpdateSuccess => '頭像更新成功';

  @override
  String get avatarUpdateFailed => '更新頭像失敗';

  @override
  String get imagePickFailed => '選擇圖片失敗';

  @override
  String confirmDeleteUser(Object username) {
    return '確定要刪除 \'$username\' 嗎？';
  }

  @override
  String confirmDeleteSong(Object songName) {
    return '確定要刪除 \'$songName\' 嗎？';
  }

  @override
  String get verificationCode => '驗證碼';

  @override
  String get enterVerificationCode => '請輸入驗證碼';

  @override
  String get verificationCodeLength => '驗證碼必須是6位數字';

  @override
  String get sendVerificationCode => '發送驗證碼';

  @override
  String resendVerificationCode(Object countdown) {
    return '重新發送 (${countdown}s)';
  }

  @override
  String get alreadyHaveAccount => '已有帳號？登入';

  @override
  String get dontHaveAccount => '沒有帳號？註冊';

  @override
  String get usernameFormat => '使用者名稱必須是4-16個字符，字母、數字、下劃線或連字符';

  @override
  String get passwordLength => '密碼至少6個字符';

  @override
  String get phoneFormat => '請輸入有效的手機號';

  @override
  String get emailFormat => '請輸入有效的郵箱';

  @override
  String get usernameRequired => '請輸入使用者名稱';

  @override
  String get passwordRequired => '請輸入密碼';

  @override
  String get emailRequired => '請輸入郵箱';

  @override
  String get verificationCodeRequired => '請輸入驗證碼';

  @override
  String get confirmPasswordRequired => '請確認密碼';

  @override
  String get confirmPasswordMatch => '密碼不匹配';

  @override
  String get playlist => '播放列表';

  @override
  String songsCount(Object count) {
    return '$count 首歌曲';
  }

  @override
  String get unknownSong => '未知歌曲';

  @override
  String get unknownArtist => '未知歌手';

  @override
  String get tip => '提示';

  @override
  String get removedFromFavorites => '已從收藏中移除';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get playNext => '下一首播放';

  @override
  String get addedToNextPlay => '已添加到下一首播放';

  @override
  String get searchFailed => '搜索失敗，請重試';

  @override
  String get alreadyFavorited => '已在收藏中';

  @override
  String get verificationCodeSent => '驗證碼已發送！';

  @override
  String get failedToSendVerificationCode => '發送驗證碼失敗';

  @override
  String get registrationSuccessful => '註冊成功！請登錄。';

  @override
  String get settingsPageComingSoon => '設置頁面即將上線';

  @override
  String get confirmClose => '是否關閉';

  @override
  String get closePlayback => '關閉播放';

  @override
  String get confirmClosePlayback => '確定要關閉當前播放嗎？';

  @override
  String get loginExpired => '登入失效，請重新登入';

  @override
  String get goToLogin => '去登入';

  @override
  String get recommendedPlaylists => '推薦歌單';

  @override
  String get viewMore => '查看更多';

  @override
  String get hotSongs => '熱門歌曲';
}
