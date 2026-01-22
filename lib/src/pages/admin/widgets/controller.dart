import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class AdminController extends GetxController {
  // 状态
  var currentTab = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // 用户管理
  var users = <dynamic>[].obs;
  var userPage = 1.obs;
  var userTotal = 0.obs;
  var userSearchController = TextEditingController();
  static const int userPageSize = 10;

  // 歌曲管理
  var songs = <dynamic>[].obs;
  var songPage = 1.obs;
  var songTotal = 0.obs;
  var songSearchController = TextEditingController();
  static const int songPageSize = 10;

  // API服务
  late ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    _apiService = ApiService();
    loadUsers();
  }

  @override
  void onClose() {
    userSearchController.dispose();
    songSearchController.dispose();
    super.onClose();
  }

  /// 加载用户
  Future<void> loadUsers({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    if (!loadMore) {
      userPage.value = 1;
    }

    try {
      final response = await _apiService.getAllUsers(
        userPage.value,
        userPageSize,
        userSearchController.text.isNotEmpty ? userSearchController.text : null,
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 1) {
          if (loadMore) {
            users.addAll(data['data']['records'] ?? []);
          } else {
            users.value = data['data']['records'] ?? [];
          }
          userTotal.value = data['data']['total'] ?? 0;
        } else {
          errorMessage.value = data['message'] ?? '加载用户失败';
        }
      } else {
        errorMessage.value = '网络错误: ${response.statusCode}';
      }
    } catch (e, stackTrace) {
      AppLogger().e('加载用户错误: $e', stackTrace: stackTrace);
      errorMessage.value = '错误: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载歌曲
  Future<void> loadSongs({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    if (!loadMore) {
      songPage.value = 1;
    }

    try {
      final response = await _apiService.getAllSongs(
        songPage.value,
        songPageSize,
        songName: songSearchController.text.isNotEmpty
            ? songSearchController.text
            : null,
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 1) {
          if (loadMore) {
            songs.addAll(data['data']['records'] ?? []);
          } else {
            songs.value = data['data']['records'] ?? [];
          }
          songTotal.value = data['data']['total'] ?? 0;
        } else {
          errorMessage.value = data['message'] ?? '加载歌曲失败';
        }
      } else {
        errorMessage.value = '网络错误: ${response.statusCode}';
      }
    } catch (e, stackTrace) {
      AppLogger().e('加载歌曲错误: $e', stackTrace: stackTrace);
      errorMessage.value = '错误: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 清除用户搜索
  void clearUserSearch() {
    userSearchController.clear();
    loadUsers();
  }

  /// 清除歌曲搜索
  void clearSongSearch() {
    songSearchController.clear();
    loadSongs();
  }

  /// 切换标签页
  void changeTab(int index) {
    currentTab.value = index;
    if (index == 0 && users.isEmpty) {
      loadUsers();
    } else if (index == 1 && songs.isEmpty) {
      loadSongs();
    }
  }

  /// 刷新数据
  void refreshData() {
    if (currentTab.value == 0) {
      loadUsers();
    } else {
      loadSongs();
    }
  }

  /// 处理删除用户
  void handleDeleteUser(dynamic user) {
    showDeleteUserDialog(user);
  }

  /// 处理删除歌曲
  void handleDeleteSong(dynamic song) {
    showDeleteSongDialog(song);
  }

  /// 显示删除用户对话框
  void showDeleteUserDialog(dynamic user) {
    Get.dialog(
      AlertDialog(
        title: Text('删除用户'),
        content: Text('确定要删除 "${user['username']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // 实现删除用户逻辑
              // await deleteUser(user['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示删除歌曲对话框
  void showDeleteSongDialog(dynamic song) {
    Get.dialog(
      AlertDialog(
        title: Text('删除歌曲'),
        content: Text('确定要删除 "${song['songName']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // 实现删除歌曲逻辑
              // await deleteSong(song['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }
}
