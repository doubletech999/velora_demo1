// lib/presentation/widgets/common/custom_switch.dart
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final double width;
  final double height;
  final double switchBorderRadius;
  final double thumbBorderRadius;
  final Duration animationDuration;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.width = 50.0,
    this.height = 30.0,
    this.switchBorderRadius = 20.0,
    this.thumbBorderRadius = 18.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  late Animation<Alignment> _toggleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _toggleAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
    
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = widget.inactiveColor ?? Colors.grey;
    final activeTrackColor = widget.activeTrackColor ?? widget.activeColor.withOpacity(0.3);
    final inactiveTrackColor = widget.inactiveTrackColor ?? inactiveColor.withOpacity(0.3);
    
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.switchBorderRadius),
              color: _toggleAnimation.value.x <= 0.0 
                  ? inactiveTrackColor 
                  : activeTrackColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Align(
              alignment: _toggleAnimation.value,
              child: Container(
                width: widget.height - 4,
                height: widget.height - 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _toggleAnimation.value.x <= 0.0 
                      ? inactiveColor 
                      : widget.activeColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}