import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/ui_helpers.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'learner_wishlists_viewmodel.dart';

class LearnerWishlistsView extends StackedView<LearnerWishlistsViewModel> {
  const LearnerWishlistsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerWishlistsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Wishlist',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshCourses,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : viewModel.wishlistedCourses.isEmpty
              ? Center(
                  child: Text(
                    'No items in wishlist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.wishlistedCourses.length,
                  itemBuilder: (context, index) {
                    final course = viewModel.wishlistedCourses[index];
                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: viewModel.getCourseImageWidget(
                                course: course,
                                width: 120,
                                height: 120,
                              ),
                            ),
                            horizontalSpaceMedium,
                            // Course Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  verticalSpaceSmall,
                                  Text(
                                    course.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  verticalSpaceSmall,
                                  Row(
                                    children: [
                                      Icon(Icons.book,
                                          size: 16, color: Colors.blue[700]),
                                      horizontalSpaceTiny,
                                      Text(
                                        '${course.lessons} lessons',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  verticalSpaceSmall,
                                  Text(
                                    '\$${course.price.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    // TODO: Implement checkout
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () =>
                                      viewModel.removeFromWishlist(course),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  LearnerWishlistsViewModel viewModelBuilder(BuildContext context) =>
      LearnerWishlistsViewModel(
        courseService: locator<CourseService>(),
        wishlistService: locator<WishlistService>(),
        imageService: locator<ImageService>(),
      )..init();
}
