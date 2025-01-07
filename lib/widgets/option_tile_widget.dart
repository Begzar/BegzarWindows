import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isShowArrowBtn;

  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isShowArrowBtn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            icon,
            color: Colors.grey[400],
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              fontFamily: 'sm',
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'sm',
              ),
            ),
          ),
          trailing: isShowArrowBtn
              ? Icon(
                  Icons.arrow_circle_left_outlined,
                  color: Colors.grey[400],
                  size: 28,
                )
              : null,
        ),
      ),
    );
  }
}
