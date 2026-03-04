import 'package:flutter/material.dart';

class NeumorphicMenuCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? accentColor;

  const NeumorphicMenuCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.accentColor,
  });

  @override
  State<NeumorphicMenuCard> createState() => _NeumorphicMenuCardState();
}

class _NeumorphicMenuCardState extends State<NeumorphicMenuCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Base color for Neumorphism (Off-white)
    final Color baseColor = const Color(0xFFEFEEEE);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.black : baseColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? [
                  // Pressed state: Inner shadow effect (simulated with standard shadows for simplicity 
                  // or just flatter shadows)
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: const Offset(4, 4),
                    blurRadius: 5,
                  ),
                ]
              : [
                  // Unpressed state: Outer soft shadows
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-8, -8),
                    blurRadius: 12, // Softer blur
                  ),
                  BoxShadow(
                    color: Colors.grey.shade400, // Slightly darker for contrast
                    offset: const Offset(8, 8),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? (widget.accentColor ?? Colors.red) 
                    : baseColor, // Inner neumorphic or flat
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [] // No shadow on the accent container inside black card
                    : [
                        // Subtle inner neumorphism for icon container
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: widget.isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (widget.isSelected) ...[
               const SizedBox(height: 4),
               Text(
                 'Selected',
                 style: TextStyle(
                   fontSize: 10,
                   color: Colors.white.withOpacity(0.6),
                 ),
               )
            ]
          ],
        ),
      ),
    );
  }
}
