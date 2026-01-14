import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 应用级日志管理工具类
/// 提供统一的日志记录功能，支持不同环境配置和日志级别控制
class AppLogger {
  // 单例模式实现
  static final AppLogger _instance = AppLogger._internal();

  /// 获取单例实例
  factory AppLogger() => _instance;

  /// 私有构造函数，防止外部实例化
  AppLogger._internal();

  // 日志核心对象
  late final Logger _logger;
  // 初始化标记，防止重复初始化
  bool _isInitialized = false;

  /// 初始化日志配置
  ///
  /// [参数说明]:
  /// - [dateTimeFormat]: 时间显示格式配置
  ///   - `DateTimeFormat.none`: 不显示时间戳
  ///   - `DateTimeFormat.microsecond`: 显示微秒级时间(HH:mm:ss.SSSSSS)
  ///   - `DateTimeFormat.onlyTimeAndSinceStart`: 显示时间及应用启动后时长
  /// - [printError]: 是否打印错误堆栈信息(默认true)
  /// - [methodCount]: 开发环境下打印的调用栈方法数(默认2)
  /// - [errorMethodCount]: 错误日志打印的调用栈方法数(默认8)
  /// - [lineLength]: 日志行最大字符数(默认120，用于自动换行)
  /// - [colors]: 是否使用ANSI颜色输出(默认true)
  /// - [level]: 日志记录级别(默认Level.trace，记录所有日志)
  void initialize({
    DateTimeFormatter dateTimeFormat = DateTimeFormat.none,
    bool printError = true,
    int methodCount = 2,
    int errorMethodCount = 8,
    int lineLength = 120,
    bool colors = true,
    Level level = Level.trace,
  }) {
    // 防止重复初始化
    if (_isInitialized) {
      if (kDebugMode) {
        _logger.w('警告: AppLogger已经被初始化');
      }
      return;
    }

    // 设置全局日志级别
    Logger.level = level;

    // 创建日志记录器实例
    _logger = Logger(
      // 配置日志格式化输出
      printer: PrettyPrinter(
        methodCount: methodCount, // 开发环境调用栈深度
        errorMethodCount: errorMethodCount, // 错误调用栈深度
        lineLength: lineLength, // 行宽限制(自动换行)
        colors: colors, // 是否使用颜色
        dateTimeFormat: dateTimeFormat, // 时间显示格式
      ),
      // 配置日志过滤器
      filter: _isProduction() ? ProductionFilter() : DevelopmentFilter(),
    );

    _isInitialized = true;
  }

  /// 判断是否为生产环境
  ///
  /// 默认返回false(开发环境)，实际项目中可通过环境变量判断
  /// 例如: const bool.fromEnvironment('dart.vm.product')
  bool _isProduction() {
    return false; // 默认开发环境
  }

  // 日志记录方法(委托给底层Logger实现)
  // 每个方法对应一个日志级别

  /// 记录trace级别日志(最详细，开发调试用)
  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  /// 记录debug级别日志(调试信息)
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// 记录info级别日志(普通信息)
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// 记录warning级别日志(警告信息)
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// 记录error级别日志(错误信息)
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// 记录wtf级别日志(严重错误，What a Terrible Failure)
  void f(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
