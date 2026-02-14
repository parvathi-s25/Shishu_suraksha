import 'package:flutter/material.dart';

/// Responsive Dashboard Utilities
class ResponsiveDashboard {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  final BuildContext context;

  ResponsiveDashboard(this.context);

  /// Get device type
  DashboardDeviceType get deviceType {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DashboardDeviceType.mobile;
    if (width < tabletBreakpoint) return DashboardDeviceType.tablet;
    return DashboardDeviceType.desktop;
  }

  /// Get screen dimensions
  Size get screenSize => MediaQuery.of(context).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Device type checks
  bool get isMobile => deviceType == DashboardDeviceType.mobile;
  bool get isTablet => deviceType == DashboardDeviceType.tablet;
  bool get isDesktop => deviceType == DashboardDeviceType.desktop;

  /// Responsive padding
  EdgeInsets get contentPadding {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return const EdgeInsets.all(12);
      case DashboardDeviceType.tablet:
        return const EdgeInsets.all(16);
      case DashboardDeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Responsive card padding
  EdgeInsets get cardPadding {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return const EdgeInsets.all(12);
      case DashboardDeviceType.tablet:
        return const EdgeInsets.all(16);
      case DashboardDeviceType.desktop:
        return const EdgeInsets.all(18);
    }
  }

  /// Responsive spacing
  double getSpacing(double baseSpacing) {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return baseSpacing * 0.8;
      case DashboardDeviceType.tablet:
        return baseSpacing;
      case DashboardDeviceType.desktop:
        return baseSpacing * 1.2;
    }
  }

  /// Responsive font size
  double getFontSize(double baseSize) {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return baseSize * 0.9;
      case DashboardDeviceType.tablet:
        return baseSize;
      case DashboardDeviceType.desktop:
        return baseSize * 1.1;
    }
  }

  /// Grid columns for layouts
  int get gridColumns {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return 1;
      case DashboardDeviceType.tablet:
        return 2;
      case DashboardDeviceType.desktop:
        return 3;
    }
  }

  /// Sidebar width
  double get sidebarWidth {
    if (isMobile) return 0;
    if (isTablet) return 60;
    return 70;
  }

  /// Max content width
  double get maxContentWidth {
    switch (deviceType) {
      case DashboardDeviceType.mobile:
        return screenWidth * 0.95;
      case DashboardDeviceType.tablet:
        return screenWidth * 0.9;
      case DashboardDeviceType.desktop:
        return 1400;
    }
  }

  /// Bottom navigation height
  double get bottomNavHeight {
    return isMobile ? 56 : (isTablet ? 64 : 0);
  }

  /// FAB positioning
  double get fabBottom {
    if (isMobile) return 80;
    return 30;
  }

  double get fabRight {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  /// Panel width for sidebars (animated panels)
  double get panelWidth {
    if (isMobile) return screenWidth * 0.9;
    if (isTablet) return screenWidth * 0.5;
    return screenWidth * 0.4;
  }

  /// Panel height for sidebars
  double get panelHeight {
    if (isMobile) return screenHeight * 0.7;
    if (isTablet) return screenHeight * 0.65;
    return screenHeight * 0.55;
  }
}

enum DashboardDeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive card widget
class ResponsiveDashboardCard extends StatelessWidget {
  final Widget child;
  final double? customPadding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const ResponsiveDashboardCard({
    Key? key,
    required this.child,
    this.customPadding,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    final padding = customPadding ?? responsive.cardPadding.left;

    return Card(
      elevation: 2,
      color: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid for dashboard items
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final ScrollController? scrollController;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    final columns = responsive.gridColumns;

    return GridView.count(
      controller: scrollController,
      crossAxisCount: columns,
      mainAxisSpacing: responsive.getSpacing(spacing),
      crossAxisSpacing: responsive.getSpacing(spacing),
      childAspectRatio: responsive.isDesktop ? 1.2 : 1.0,
      children: children,
    );
  }
}

/// Responsive list for tabs
class ResponsiveDashboardList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;

  const ResponsiveDashboardList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);

    return ListView.builder(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      padding: padding ?? responsive.contentPadding,
      itemCount: items.length,
      itemBuilder: (ctx, index) => Padding(
        padding: EdgeInsets.only(
          bottom: responsive.getSpacing(12),
        ),
        child: itemBuilder(ctx, items[index]),
      ),
    );
  }
}

/// Responsive button style
class ResponsiveDashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? customWidth;

  const ResponsiveDashboardButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.customWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    final width = customWidth ?? (responsive.isDesktop ? 200 : double.infinity);
    final padding = responsive.contentPadding;

    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: isLoading
            ? const Text('Loading...')
            : Text(
                label,
                style: TextStyle(
                  fontSize: responsive.getFontSize(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: padding.left,
            vertical: 12,
          ),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

/// Responsive stat card
class ResponsiveStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const ResponsiveStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    final cardColor = color ?? Colors.teal;

    return ResponsiveDashboardCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.getFontSize(32), color: cardColor),
          SizedBox(height: responsive.getSpacing(12)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.getFontSize(20),
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
          SizedBox(height: responsive.getSpacing(4)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.getFontSize(12),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive section header
class ResponsiveSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMoreTap;

  const ResponsiveSectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);

    return Padding(
      padding: responsive.contentPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.getFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: responsive.getSpacing(4)),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          if (onMoreTap != null)
            GestureDetector(
              onTap: onMoreTap,
              child: Text(
                'More',
                style: TextStyle(
                  fontSize: responsive.getFontSize(12),
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Adaptive Scaffold for consistent app structure
class ResponsiveAdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final FloatingActionButton? fab;
  final BottomNavigationBar? bottomNavigation;
  final Drawer? drawer;
  final Color? backgroundColor;

  const ResponsiveAdaptiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.fab,
    this.bottomNavigation,
    this.drawer,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);

    return Scaffold(
      appBar: appBar,
      drawer: responsive.isMobile ? drawer : null,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.maxContentWidth,
            ),
            child: body,
          ),
        ),
      ),
      floatingActionButton: fab,
      bottomNavigationBar: bottomNavigation,
    );
  }
}
