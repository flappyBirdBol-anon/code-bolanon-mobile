import 'package:flutter/material.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';

class FilterableListView extends StatefulWidget {
  final CourseBaseViewModel viewModel;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final Widget? header;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool showFilters;
  final Function()? onLoadMore;
  final bool isLoadingMore;
  final double? itemExtent;

  const FilterableListView({
    Key? key,
    required this.viewModel,
    required this.itemBuilder,
    required this.itemCount,
    this.header,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    this.showFilters = true,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.itemExtent,
  }) : super(key: key);

  @override
  State<FilterableListView> createState() => _FilterableListViewState();
}

class _FilterableListViewState extends State<FilterableListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent - _scrollController.offset <=
        500) {
      widget.viewModel.loadMoreItems();
    }
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: widget.viewModel.availableFilters.map((filter) {
          final isSelected = widget.viewModel.activeFilters.contains(filter);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => widget.viewModel.toggleFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showFilters && widget.viewModel.availableFilters.isNotEmpty)
          _buildFilters(),
        if (widget.header != null) widget.header!,
        Expanded(
          child: widget.viewModel.isBusy
              ? const Center(child: CircularProgressIndicator())
              : widget.itemCount == 0
                  ? _buildEmptyState()
                  : Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: widget.padding,
                          physics: widget.physics,
                          itemCount: widget.itemCount +
                              (widget.viewModel.hasMoreItems ? 1 : 0),
                          itemExtent: widget.itemExtent,
                          itemBuilder: (context, index) {
                            if (index == widget.itemCount &&
                                widget.viewModel.hasMoreItems) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return widget.itemBuilder(context, index);
                          },
                        ),
                        if (widget.isLoadingMore)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              color: Colors.white.withOpacity(0.8),
                              padding: const EdgeInsets.all(16),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}
