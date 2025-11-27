import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_card.dart';


class MicronutrientButton extends StatelessWidget {
  final List<Map<String, dynamic>>? micronutrients;
  final VoidCallback? onTap;


  const MicronutrientButton({super.key, this.micronutrients, this.onTap});


  @override
  Widget build(BuildContext context) {
    final hasData = micronutrients != null && micronutrients!.isNotEmpty;


    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black)
        ),
        child: Row(
          children: [

            Icon(Icons.spa, color: Colors.black),

            const SizedBox(width: 12),

            Expanded(
              child: hasData
                ? ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(),
                      itemCount: micronutrients!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 210,
                          child: Center(
                            child: MicroNutrientCard(
                              micronutrient: micronutrients![index],
                              onDelete: () {}, 
                              compact: true,
                            ),
                          ),
                        );
                      }
                    ),
                  )
                : const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Micronutrients",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
            ),

            SizedBox(width: 8),

            const Icon(Icons.chevron_right, color: Colors.grey),

          ],
        ),
      ),
    );
  }
}
