import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final VoidCallback? onTap;
  final double? width, height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.all(color: colors.first.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class AstroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const AstroAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            )
          : leading,
      automaticallyImplyLeading: false,
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF080C1A), Color(0xFF0D1B3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: Color(0xFFE8F0FE),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}