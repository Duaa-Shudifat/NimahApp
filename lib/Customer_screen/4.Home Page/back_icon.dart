import 'package:flutter/material.dart';

class BackButtonPositioned extends StatelessWidget {
  final Widget? targetPage;
  final bool useNavigatorPop;

  const BackButtonPositioned({
    super.key,
    this.targetPage,
    this.useNavigatorPop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 15,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.deepOrange,
        ),
        onPressed: () {
          // 1. إذا كان المطلوب هو الرجوع العادي للخلف
          if (useNavigatorPop) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
          // 2. إذا تم تحديد صفحة معينة للذهاب إليها
          else if (targetPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => targetPage!),
            );
          }
          // 3. حالة احتياطية إذا لم يتم تحديد شيء
          else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}