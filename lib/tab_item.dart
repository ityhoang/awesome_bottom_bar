import 'package:flutter/material.dart';

class TabItem<T> {
  final T? icon;
  final Widget? child;
  final String? title;
  final Widget? count;
  final String? key;

  const TabItem({
    this.icon,
    this.child,
    this.title,
    this.count,
    this.key,
  });
}
