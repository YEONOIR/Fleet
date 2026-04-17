import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final bool isSearchExpanded;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<bool> onSearchExpandedChange;
  final VoidCallback onSearchChanged;
  final bool isFilterActive;
  final VoidCallback onFilterTap;
  final bool isCalendarActive;
  final VoidCallback onCalendarTap;

  const SearchHeader({
    super.key,
    required this.isSearchExpanded,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchExpandedChange,
    required this.onSearchChanged,
    required this.isFilterActive,
    required this.onFilterTap,
    required this.isCalendarActive,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAC72A1), Color(0xFF070E2A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Search icon / expanded search bar
          if (isSearchExpanded)
            Expanded(child: _buildExpandedSearch())
          else
            _buildCollapsedSearch(),

          // Spacer pushes filter+calendar to right when collapsed
          if (!isSearchExpanded) const Spacer(),

          const SizedBox(width: 12),

          // Filter button
          _buildHeaderIcon(
            icon: Icons.filter_alt,
            isActive: isFilterActive,
            onTap: onFilterTap,
          ),
          const SizedBox(width: 8),

          // Calendar button
          _buildHeaderIcon(
            icon: Icons.calendar_today,
            isActive: isCalendarActive,
            onTap: onCalendarTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return GestureDetector(
      key: const ValueKey('collapsed'),
      onTap: () {
        onSearchExpandedChange(true);
        Future.delayed(const Duration(milliseconds: 100), () {
          searchFocusNode.requestFocus();
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(Icons.search, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return Container(
      key: const ValueKey('expanded'),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: (_) => onSearchChanged(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFF070E2A),
        ),
        decoration: InputDecoration(
          hintText: 'Enter Search',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: const Color(0xFF070E2A).withValues(alpha: 0.4),
          ),
          prefixIcon: GestureDetector(
            onTap: () {
              if (searchController.text.isEmpty) {
                onSearchExpandedChange(false);
                searchFocusNode.unfocus();
              }
            },
            child: const Icon(Icons.search, color: Color(0xFFAC72A1), size: 22),
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();
                    onSearchChanged();
                  },
                  child: const Icon(
                    Icons.clear,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF7B1FA2) : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
