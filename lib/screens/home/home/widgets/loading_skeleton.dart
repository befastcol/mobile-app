import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 54,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.all(Radius.circular(10)))),
        Container(
            height: 54,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.all(Radius.circular(10)))),
        Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.all(Radius.circular(10)))),
      ],
    );
  }
}
