import 'package:flutter/material.dart';

import '../count_style.dart';
import '../tab_item.dart';

class BottomBarCircle extends StatefulWidget {
  const BottomBarCircle({
    required this.items,
    required this.backgroundColor,
    required this.color,
    required this.colorSelected,
    this.boxShadow,
    this.borderRadius,
    this.indexSelected = 0,
    this.onTap,
    this.animated = true,
    this.iconSize = 22,
    this.titleStyle,
    this.paddingHorizontal,
    this.countStyle,
    this.duration,
    this.top = 12,
    this.bottom = 12,
    this.pad = 4,
    this.padding,
    this.maskColor = Colors.white,
    Key? key,
  }) : super(key: key);

  final List<TabItem> items;

  /// view
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  /// item
  final int indexSelected;
  final void Function(int index)? onTap;
  final Color color;
  final Color colorSelected;
  final Color maskColor;
  final double iconSize;
  final TextStyle? titleStyle;
  final double? paddingHorizontal;
  final CountStyle? countStyle;
  final bool animated;
  final Duration? duration;
  final double? top;
  final double? bottom;
  final double? pad;
  final EdgeInsetsGeometry? padding;

  @override
  State<BottomBarCircle> createState() => _BottomBarCircleState();
}

class _BottomBarCircleState extends State<BottomBarCircle> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = widget.indexSelected;
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 300),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.animated) {
        _controllers[_selectedIndex].forward();
      } else {
        _controllers[_selectedIndex].value = 1;
      }
    });
  }

  @override
  void didUpdateWidget(covariant BottomBarCircle oldWidget) {
    _selectedIndex = widget.indexSelected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.animated) {
        _controllers[_selectedIndex].forward();
      } else {
        _controllers[_selectedIndex].value = 1;
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCircleTap(int index) {
    if (_selectedIndex != index) {
      widget.onTap?.call(index);
      if (widget.animated) {
        if (_selectedIndex != -1) {
          _controllers[_selectedIndex].reverse();
        }
        _controllers[index].forward();
      }
      setState(() {
        if (!widget.animated) {
          _controllers[_selectedIndex].value = 0;
          _controllers[index].value = 1;
        }
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCircle({
    required int index,
    required TabItem item,
  }) {
    final isSelected = _selectedIndex == index;
    final itemColor = isSelected ? widget.colorSelected : widget.color;
    final icon = item.child ??
        Icon(
          item.icon,
          size: widget.iconSize,
          color: itemColor,
        );
    return GestureDetector(
      onTap: () => _onCircleTap(index),
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          final buildContentItem = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: isSelected ? widget.colorSelected.withOpacity(_controllers[index].value == 1 ? 1 : 0) : widget.color),
                      shape: BoxShape.circle,
                    ),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return RadialGradient(
                          radius: _controllers[index].value * 0.5,
                          colors: [
                            widget.colorSelected.withOpacity(_controllers[index].value),
                            widget.maskColor.withOpacity(_controllers[index].value),
                          ],
                          stops: const [1, 0],
                        ).createShader(bounds);
                      },
                      child: Container(
                        width: widget.iconSize,
                        height: widget.iconSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: icon,
                  ),
                ],
              ),
              if (item.title is String && item.title != '') ...[
                SizedBox(height: widget.pad),
                Text(
                  item.title!,
                  style: Theme.of(context).textTheme.labelSmall?.merge(widget.titleStyle).copyWith(color: isSelected ? widget.colorSelected : widget.color),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );

          if (item.count is Widget) {
            final sizeBadge = widget.countStyle?.size ?? 18;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                buildContentItem,
                PositionedDirectional(
                  start: widget.iconSize - sizeBadge / 2,
                  top: -sizeBadge / 2,
                  child: item.count!,
                ),
              ],
            );
          }
          return buildContentItem;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: widget.boxShadow,
        borderRadius: widget.borderRadius,
        color: widget.backgroundColor,
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final isAddPad = !(index == 0 || index == widget.items.length - 1);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isAddPad ? (widget.paddingHorizontal ?? 0) : 0),
            child: _buildCircle(
              item: widget.items[index],
              index: index,
            ),
          );
        }),
      ),
    );
  }
}
