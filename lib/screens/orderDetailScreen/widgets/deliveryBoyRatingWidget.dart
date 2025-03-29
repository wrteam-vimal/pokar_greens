import 'package:project/helper/utils/generalImports.dart';

class DeliveryBoyRatingWidget extends StatelessWidget {
  final Order order;

  const DeliveryBoyRatingWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, deliveryBoyRatingScreen,
              arguments: [order]);
        },
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  jsonKey: "delivery_boy",
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColorsRes.mainTextColor
                  ),
                ),
                Text(order.deliveryBoyName ?? "",style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ColorsRes.subTitleTextColorLight
                ),),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.rate_review_outlined,
              color: ColorsRes.appColor,
            ),
          ],
        ),
      ),
    );
  }
}
