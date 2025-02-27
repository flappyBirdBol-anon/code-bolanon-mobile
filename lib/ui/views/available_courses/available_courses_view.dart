import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'available_courses_viewmodel.dart';

class AvailableCoursesView extends StackedView<AvailableCoursesViewModel> {
  const AvailableCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, AvailableCoursesViewModel viewModel,
      Widget? child) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, viewModel),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => viewModel.refreshCourses(),
                child: _buildCoursesList(viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AvailableCoursesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: viewModel.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterOptions(context, viewModel),
              ),
              IconButton(
                icon: const Icon(Icons.book),
                onPressed: viewModel.navigateToMyCourses,
              ),
            ],
          ),
          if (viewModel.activeFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.activeFilters.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(viewModel.activeFilters.toList()[index]),
                        onDeleted: () => viewModel.removeFilter(
                            viewModel.activeFilters.toList()[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(AvailableCoursesViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: viewModel.filteredCourses.length,
      itemBuilder: (context, index) {
        return CourseCard(course: viewModel.filteredCourses[index]);
      },
    );
  }

  void _showFilterOptions(
      BuildContext context, AvailableCoursesViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: viewModel.availableFilters.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: viewModel.activeFilters.contains(filter),
                  onSelected: (selected) => viewModel.toggleFilter(filter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AvailableCoursesViewModel viewModelBuilder(BuildContext context) =>
      AvailableCoursesViewModel();
}

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                course.thumbnailUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: AssetImage(course.instructorAvatar),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            course.instructorName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              course.rating.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ' (${course.reviewsCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          course.price == 0 ? 'Free' : '\$${course.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
