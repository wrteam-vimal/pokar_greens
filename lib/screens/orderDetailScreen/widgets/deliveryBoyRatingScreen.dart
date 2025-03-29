import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:project/helper/utils/generalImports.dart';

class DeliveryBoyRatingScreen extends StatefulWidget {
  final Order order;

  const DeliveryBoyRatingScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<DeliveryBoyRatingScreen> createState() =>
      _DeliveryBoyRatingScreenState();
}

class _DeliveryBoyRatingScreenState extends State<DeliveryBoyRatingScreen> {
  double _rating = 0;
  String? _selectedReason;
  String _feedback = "";
  bool _showOtherFeedback = false;

  @override
  void initState() {
    super.initState();
    fetchRatingReasons();
  }

  void fetchRatingReasons() {
    final ratingReasonProvider =
        Provider.of<RatingReasonProvider>(context, listen: false);
    ratingReasonProvider.getRatingReason(
      context: context,
      params: {"type": "deliveryBoy"},
    );
  }

  void submitRating() async {
    if (_rating == 0) {
      showMessage(
          context,
          getTranslatedValue(context, "please_provide_star_rating"),
          MessageType.warning);
      return;
    }
    if (_selectedReason == null) {
      showMessage(
          context,
          getTranslatedValue(context, "please_select_rating_reason"),
          MessageType.warning);
      return;
    }

    Map<String, String> params = {
      ApiAndParams.orderId: widget.order.id!,
      ApiAndParams.deliveryBoyId: widget.order.deliveryBoyId!,
      ApiAndParams.rating: _rating.toString(),
      ApiAndParams.reasonId: _selectedReason!,
      if (_feedback != "") ApiAndParams.comments: _feedback
    };

    final deliveryBoyRatingProvider =
        Provider.of<DeliveryBoyRatingProvider>(context, listen: false);

    await deliveryBoyRatingProvider.addRating(context: context, params: params);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ratingReasonProvider = Provider.of<RatingReasonProvider>(context);
    final deliveryBoyRatingProvider =
        Provider.of<DeliveryBoyRatingProvider>(context);

    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "rate_delivery",
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${getTranslatedValue(context, "how_was_your_experience")}\n${getTranslatedValue(context, "rate_your_delivery")}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: ColorsRes.mainTextColor,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Align(
                  alignment: Alignment.centerLeft, child: SizedBox(height: 10)),

              if (ratingReasonProvider.ratingReasonState ==
                  RatingReasonState.loading)
                const Center(child: CircularProgressIndicator())
              else if (ratingReasonProvider.ratingReasonState ==
                  RatingReasonState.error)
                Text(getTranslatedValue(context, "something_went_wrong"),
                    style: TextStyle(color: Colors.red))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (ratingReasonProvider.ratingReasonList?.data ?? [])
                      .map((reason) {
                    final isSelected = _selectedReason == reason.id.toString();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedReason = reason.id.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reason.reason ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              if (!_showOtherFeedback)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOtherFeedback = true;
                    });
                  },
                  child: Text(
                    getTranslatedValue(context, "anything_to_add"),
                    style: TextStyle(color: ColorsRes.appColor),
                  ),
                ),

// Feedback TextField
              if (_showOtherFeedback) ...[
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: getTranslatedValue(
                        context, "share_your_delivery_experience"),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsRes.appColor)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsRes.appColor)),
                  ),
                  maxLines: 3,
                  onChanged: (val) => _feedback = val,
                ),
              ],
              // To avoid overlap with bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: deliveryBoyRatingProvider.deliveryBoyRatingAddState ==
                    DeliveryBoyRatingAddState.loading
                ? null
                : submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsRes.appColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: deliveryBoyRatingProvider.deliveryBoyRatingAddState ==
                    DeliveryBoyRatingAddState.loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: ColorsRes.bgColorLight, strokeWidth: 2),
                  )
                : Text(getTranslatedValue(context, "submit"),
                    style:
                        TextStyle(fontSize: 16, color: ColorsRes.bgColorLight)),
          ),
        ),
      ),
    );
  }
}
