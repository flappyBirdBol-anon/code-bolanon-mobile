import 'package:flutter/material.dart';
import 'package:code_bolanon/ui/common/base/filterable_view_model.dart';

class FilterableGridView extends StatefulWidget {
  final FilterableViewModel viewModel;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final Widget? header;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool showFilters;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Function()? onLoadMore;
  final bool isLoadingMore;

  const FilterableGridView({
    Key? key,
    required this.viewModel,
    required this.itemBuilder,
    required this.itemCount,
    this.header,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    this.showFilters = true,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.onLoadMore,
    this.isLoadingMore = false,
  }) : super(key: key);

  @override
  State<FilterableGridView> createState() => _FilterableGridViewState();
}

class _FilterableGridViewState extends State<FilterableGridView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore != null &&
        !widget.isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore!();
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
            Icons.grid_off_rounded,
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
                        GridView.builder(
                          controller: _scrollController,
                          padding: widget.padding,
                          physics: widget.physics,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.crossAxisCount,
                            childAspectRatio: widget.childAspectRatio,
                            crossAxisSpacing: widget.crossAxisSpacing,
                            mainAxisSpacing: widget.mainAxisSpacing,
                          ),
                          itemCount: widget.itemCount,
                          itemBuilder: widget.itemBuilder,
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
