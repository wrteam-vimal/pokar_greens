import 'package:project/helper/utils/generalImports.dart';

class GetTimeSlots extends StatelessWidget {
  const GetTimeSlots({super.key});

  Future<void> getOrderCharges(
      BuildContext context, String? freeDelivery) async {
    Map<String, String> params = {
      ApiAndParams.latitude: context
              .read<CheckoutProvider>()
              .selectedAddress
              ?.latitude
              ?.toString() ??
          Constant.session.getData(SessionManager.keyLatitude),
      ApiAndParams.longitude: context
              .read<CheckoutProvider>()
              .selectedAddress
              ?.longitude
              ?.toString() ??
          Constant.session.getData(SessionManager.keyLongitude),
      ApiAndParams.isCheckout: "1",
      if (freeDelivery != null) ApiAndParams.freeDelivery: freeDelivery
    };

    if (Constant.selectedPromoCodeId != "0") {
      params[ApiAndParams.promoCodeId] = Constant.selectedPromoCodeId;
    }

    await context.read<CheckoutProvider>().getOrderChargesProvider(
          context: context,
          params: params,
        );
  }

  @override
  Widget build(BuildContext context) {
    List lblMonthsNames = [
      "months_names_january",
      "months_names_february",
      "months_names_march",
      "months_names_april",
      "months_names_may",
      "months_names_june",
      "months_names_july",
      "months_names_august",
      "months_names_september",
      "months_names_october",
      "months_names_november",
      "months_names_december",
    ];

    List lblWeekDaysNames = [
      "week_days_names_monday",
      "week_days_names_tuesday",
      "week_days_names_wednesday",
      "week_days_names_thursday",
      "week_days_names_friday",
      "week_days_names_saturday",
      "week_days_names_sunday",
    ];
    return Container(
      decoration: DesignConfig.boxDecorationSpecific(
          Theme.of(context).cardColor, 10, true, false),
      width: context.width,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: Constant.size10, top: Constant.size10, end: Constant.size10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: context
                          .read<CheckoutProvider>()
                          .timeSlotsData
                          ?.timeSlotsIsEnabled ==
                      "true"
                  ? "preferred_delivery_date_time"
                  : "estimate_delivery_date",
              softWrap: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(
              height: Constant.size10,
            ),
            if (context
                    .read<CheckoutProvider>()
                    .timeSlotsData
                    ?.timeSlotsIsEnabled ==
                "true")
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    int.parse(context
                            .read<CheckoutProvider>()
                            .timeSlotsData
                            ?.timeSlotsAllowedDays ??
                        "0"),
                    (index) {
                      int daysStartFrom = int.parse(context
                                  .read<CheckoutProvider>()
                                  .timeSlotsData
                                  ?.estimateDeliveryDays
                                  .toString() ??
                              "0") -
                          1;
                      late DateTime dateTime =
                          DateTime.now().add(Duration(days: daysStartFrom));
                      if (index == 0 &&
                          context.read<CheckoutProvider>().selectedDate ==
                              null) {
                        String date = dateTime.day.toString();
                        String month = dateTime.month.toString();
                        String year = dateTime.year.toString();
                        context.read<CheckoutProvider>().selectedDate =
                            "$date-$month-$year";
                      }

                      return GestureDetector(
                        onTap: () {
                          context.read<CheckoutProvider>().setSelectedTime(-1);
                          context
                              .read<CheckoutProvider>()
                              .setSelectedDate(index);
                          String date = dateTime
                              .add(Duration(days: index))
                              .day
                              .toString();
                          String month = dateTime
                              .add(Duration(days: index))
                              .month
                              .toString();
                          String year = dateTime
                              .add(Duration(days: index))
                              .year
                              .toString();
                          context.read<CheckoutProvider>().selectedDate =
                              "$date-$month-$year";
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin:
                              const EdgeInsetsDirectional.fromSTEB(0, 5, 10, 5),
                          decoration: BoxDecoration(
                              color: context
                                          .read<CheckoutProvider>()
                                          .selectedDateId ==
                                      index
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: Constant.borderRadius7,
                              border: Border.all(
                                width: context
                                            .read<CheckoutProvider>()
                                            .selectedDateId ==
                                        index
                                    ? 1
                                    : 0.3,
                                color: context
                                            .read<CheckoutProvider>()
                                            .selectedDateId ==
                                        index
                                    ? ColorsRes.appColor
                                    : ColorsRes.grey,
                              )),
                          child: Column(
                            children: [
                              CustomTextLabel(
                                jsonKey: lblWeekDaysNames[dateTime
                                        .add(Duration(days: index))
                                        .weekday -
                                    1],
                                style: TextStyle(
                                  color: context
                                              .read<CheckoutProvider>()
                                              .selectedDateId ==
                                          index
                                      ? ColorsRes.mainTextColor
                                      : ColorsRes.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                  dateTime
                                      .add(Duration(days: index))
                                      .day
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context
                                                .read<CheckoutProvider>()
                                                .selectedDateId ==
                                            index
                                        ? ColorsRes.mainTextColor
                                        : ColorsRes.grey,
                                  )),
                              CustomTextLabel(
                                jsonKey: lblMonthsNames[
                                    dateTime.add(Duration(days: index)).month -
                                        1],
                                style: TextStyle(
                                  color: context
                                              .read<CheckoutProvider>()
                                              .selectedDateId ==
                                          index
                                      ? ColorsRes.mainTextColor
                                      : ColorsRes.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (context
                    .read<CheckoutProvider>()
                    .timeSlotsData
                    ?.timeSlotsIsEnabled !=
                "true")
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          getTranslatedValue(context, "estimate_delivery_date"),
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          " ${DateTime.now().add(Duration(days: Constant.estimateDeliveryDays)).toString().formatEstimateDate()}",
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            getSizedBox(
              height: Constant.size5,
            ),
            if (context
                    .read<CheckoutProvider>()
                    .timeSlotsData
                    ?.timeSlotsIsEnabled ==
                "true")
              Column(
                children: List.generate(
                  context
                          .read<CheckoutProvider>()
                          .timeSlotsData
                          ?.timeSlots
                          .length ??
                      0,
                  (index) {
                    var now = DateTime.now();
                    bool isActive = false;
                    bool isToday = context
                                .read<CheckoutProvider>()
                                .timeSlotsData
                                ?.estimateDeliveryDays
                                .toString() ==
                            "1" &&
                        context.read<CheckoutProvider>().selectedDateId == 0;
                    String time = context
                            .read<CheckoutProvider>()
                            .timeSlotsData
                            ?.timeSlots[index]
                            .lastOrderTime
                            .toString() ??
                        "";

                    late DateTime dateTime = now.copyWith(
                        hour: int.parse(time.split(":")[0]),
                        microsecond: int.parse(time.split(":")[1]),
                        second: int.parse(time.split(":")[2]));

                    if (now.isAfter(dateTime)) {
                      if (isToday) {
                        isActive = false;
                      } else {
                        isActive = true;
                      }
                    } else {
                      isActive = true;
                    }
                    if (index == 0) {
                      context
                          .read<CheckoutProvider>()
                          .addOrResetTimeSlots(true);
                    }
                    if (isActive) {
                      context
                          .read<CheckoutProvider>()
                          .addOrResetTimeSlots(false);

                      if (context
                              .read<CheckoutProvider>()
                              .initiallySelectedIndex ==
                          -1) {
                        context
                            .read<CheckoutProvider>()
                            .setSelectedTimeWithoutNotify(index);
                      }
                      return GestureDetector(
                        onTap: () {
                          context
                              .read<CheckoutProvider>()
                              .setSelectedTime(index);
                        },
                        child: Container(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              bottom: BorderSide(
                                width: 1,
                                color: context
                                            .read<CheckoutProvider>()
                                            .timeSlotsData
                                            ?.timeSlots
                                            .length ==
                                        index + 1
                                    ? Colors.transparent
                                    : ColorsRes.grey.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            // Ensures no extra space is taken
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // Aligns items properly
                                children: [
                                  CustomTextLabel(
                                    text: context
                                            .read<CheckoutProvider>()
                                            .timeSlotsData
                                            ?.timeSlots[index]
                                            .title ??
                                        "",
                                    style: TextStyle(
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomRadio(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    inactiveColor: ColorsRes.mainTextColor,
                                    value: context
                                        .read<CheckoutProvider>()
                                        .selectedTime,
                                    groupValue: index,
                                    activeColor: ColorsRes.appColor,
                                    onChanged: (value) {
                                      context
                                          .read<CheckoutProvider>()
                                          .setSelectedTime(index);

                                      getOrderCharges(
                                          context,
                                          context
                                              .read<CheckoutProvider>()
                                              .timeSlotsData!
                                              .timeSlots[index]
                                              .freeDelivery);
                                      /*  if (context
                                          .read<CheckoutProvider>()
                                          .selectedTime ==
                                          index &&
                                          context
                                              .read<CheckoutProvider>()
                                              .timeSlotsData
                                              ?.timeSlots[index]
                                              .freeDelivery ==
                                              "1") {
                                        */ /*context
                                            .read<CheckoutProvider>()
                                            .totalAmount = context
                                                .read<CheckoutProvider>()
                                                .totalAmount -
                                            context
                                                .read<CheckoutProvider>()
                                                .deliveryCharge;
                                        context
                                            .read<CheckoutProvider>()
                                            .deliveryCharge = 0;*/ /*
                                      } else {
                                        */ /*context
                                            .read<CheckoutProvider>()
                                            .totalAmount = context
                                                .read<CheckoutProvider>()
                                                .totalAmount +
                                            context
                                                .read<CheckoutProvider>()
                                                .deliveryCharge;

                                        context
                                                .read<CheckoutProvider>()
                                                .deliveryCharge =
                                            double.parse(context
                                                    .read<CheckoutProvider>()
                                                    .deliveryChargeData
                                                    ?.deliveryCharge
                                                    ?.totalDeliveryCharge ??
                                                "0");*/ /*
                                      }*/
                                    },
                                  ),
                                ],
                              ),
                              if (context
                                          .read<CheckoutProvider>()
                                          .selectedTime ==
                                      index &&
                                  context
                                          .read<CheckoutProvider>()
                                          .timeSlotsData
                                          ?.timeSlots[index]
                                          .freeDelivery ==
                                      "1")
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  // Reduce spacing
                                  child: CustomTextLabel(
                                    text: getTranslatedValue(
                                        context, "eligible_for_free_delivery"),
                                    style: TextStyle(
                                      color: ColorsRes.appColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
