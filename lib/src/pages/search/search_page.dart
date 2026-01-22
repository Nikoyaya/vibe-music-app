import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/search/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/search/widgets/view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchPageController>(
      init: Get.find<SearchPageController>(),
      builder: (controller) {
        return SearchView();
      },
    );
  }
}
