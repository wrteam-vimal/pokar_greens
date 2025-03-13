import 'package:project/helper/utils/generalImports.dart';

class SelectLocationAddressScreen extends StatefulWidget {
  const SelectLocationAddressScreen({super.key});

  @override
  State<SelectLocationAddressScreen> createState() =>
      _SelectLocationAddressScreenState();
}

class _SelectLocationAddressScreenState
    extends State<SelectLocationAddressScreen> {
  ScrollController scrollController = ScrollController();

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<AddressProvider>().hasMoreData) {
          context.read<AddressProvider>().getAddressProvider(context: context);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //fetch cartList from api
    Future.delayed(Duration.zero).then((value) async {
      await context
          .read<AddressProvider>()
          .getAddressProvider(context: context);

      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "select_location",
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: Constant.size10),
        child: Column(
          children: [locationWidget(), savedAddress()],
        ),
      ),
    );
  }

  Widget savedAddress() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Stack(
          children: [
            setRefreshIndicator(
                refreshCallback: () async {
                  context
                      .read<CartListProvider>()
                      .getAllCartItems(context: context);
                  context.read<AddressProvider>().offset = 0;
                  context.read<AddressProvider>().addresses = [];
                  await context
                      .read<AddressProvider>()
                      .getAddressProvider(context: context);
                },
                child: (addressProvider.addressState == AddressState.loaded ||
                        addressProvider.addressState == AddressState.editing)
                    ? ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          savedAddressLbl(),
                          Column(
                            children: List.generate(
                                addressProvider.addresses.length, (index) {
                              UserAddressData address =
                                  addressProvider.addresses[index];
                              return ChangeNotifierProvider(
                                create: (context) => CityByLatLongProvider(),
                                child: GestureDetector(
                                  onTap: () {
                                    checkLocationDelivery(address.latitude!,
                                            address.longitude!)
                                        .then(
                                      (value) {
                                        if (context
                                            .read<CityByLatLongProvider>()
                                            .isDeliverable) {
                                          context
                                              .read<CartListProvider>()
                                              .getAllCartItems(
                                                  context: context);
                                          Constant.session.setData(
                                              SessionManager.keyAddress,
                                              Constant
                                                  .cityAddressMap["address"],
                                              true);
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            mainHomeScreen,
                                            (Route<dynamic> route) => false,
                                          );
                                        } else {
                                          showMessage(
                                              context,
                                              getTranslatedValue(context,
                                                  "does_not_delivery_long_message"),
                                              MessageType.error);
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsetsDirectional.all(10),
                                    margin: EdgeInsetsDirectional.only(
                                        start: 10, end: 10, top: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextLabel(
                                                    text: address.name ?? "",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: ColorsRes
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              getSizedBox(
                                                height: Constant.size7,
                                              ),
                                              CustomTextLabel(
                                                text:
                                                    "${address.area},${address.landmark}, ${address.address}, ${address.state}, ${address.city}, ${address.country} - ${address.pincode} ",
                                                softWrap: true,
                                                style: TextStyle(
                                                    /*fontSize: 18,*/
                                                    color: ColorsRes
                                                        .subTitleMainTextColor),
                                              ),
                                              getSizedBox(
                                                height: Constant.size7,
                                              ),
                                              /*!context
                                                      .read<
                                                          CityByLatLongProvider>()
                                                      .isDeliverable
                                                  ? CustomTextLabel(
                                                      jsonKey:
                                                          "does_not_delivery_long_message",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .apply(
                                                            color: ColorsRes
                                                                .appColorRed,
                                                          ),
                                                    )
                                                  : const SizedBox.shrink(),*/
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          if (addressProvider.addressState ==
                              AddressState.loadingMore)
                            getAddressShimmer(),
                        ],
                      )
                    : addressProvider.addressState == AddressState.loading
                        ? getAddressListShimmer()
                        : addressProvider.addressState == AddressState.error
                            ? const SizedBox.shrink()
                            : const SizedBox.shrink()),
            if (addressProvider.addressState == AddressState.editing)
              PositionedDirectional(
                top: 0,
                end: 0,
                start: 0,
                bottom: 0,
                child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: const Center(child: CircularProgressIndicator())),
              )
          ],
        );
      },
    );
  }

  getAddressShimmer() {
    return CustomShimmer(
      borderRadius: Constant.size10,
      width: double.infinity,
      height: 120,
      margin: EdgeInsets.all(Constant.size5),
    );
  }

  getAddressListShimmer() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(10, (index) => getAddressShimmer()),
    );
  }

  Widget savedAddressLbl() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.3),
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), // Space around text
          child: CustomTextLabel(
            jsonKey: "saved_address",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsRes.mainTextColor.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.3),
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }

  Future checkLocationDelivery(String latitude, String longitude) async {
    Map<String, dynamic> params = {};

    params[ApiAndParams.longitude] = latitude;
    params[ApiAndParams.latitude] = longitude;

    await context
        .read<CityByLatLongProvider>()
        .getCityByLatLongApiProvider(context: context, params: params);
  }

  Widget locationWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      // Reduced vertical margin
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 0,
            dense: true,
            visualDensity: VisualDensity.compact,
            // Reduce extra padding
            onTap: () {
              Navigator.pushNamed(context, confirmLocationScreen,
                  arguments: [null, "location"]).then((value) async {
                if (value is bool && value) {
                  Map<String, String> params =
                      await Constant.getProductsDefaultParams();
                  await context
                      .read<HomeScreenProvider>()
                      .getHomeScreenApiProvider(
                          context: context, params: params);
                }
              });
            },
            leading: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: Constant.size12, bottom: Constant.size14),
              child: Icon(
                Icons.my_location,
                color: ColorsRes.appColor,
                size: 20,
              ),
            ),
            title: CustomTextLabel(
              jsonKey: "choose_location",
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  color: ColorsRes.appColor,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Constant.session
                    .getData(SessionManager.keyAddress)
                    .isNotEmpty
                ? CustomTextLabel(
                    text: Constant.session.getData(SessionManager.keyAddress),
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13, color: ColorsRes.mainTextColor),
                  )
                : CustomTextLabel(
                    jsonKey: "add_new_address",
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13, color: ColorsRes.mainTextColor),
                  ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: ColorsRes.mainTextColor.withValues(alpha: 0.5),
                size: 15),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Divider(
                color: ColorsRes.subTitleTextColorDark.withValues(alpha: 0.3),
                height: 1),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 0,
            dense: true,
            visualDensity: VisualDensity.compact,
            // Reduce extra padding
            onTap: () {
              Navigator.pushNamed(context, addressDetailScreen,
                  arguments: [null, context]);

              /*Navigator.pushNamed(context, confirmLocationScreen,
                  arguments: [null, "location"]).then((value) async {
                if (value is bool && value) {
                  Map<String, String> params =
                      await Constant.getProductsDefaultParams();
                  await context
                      .read<HomeScreenProvider>()
                      .getHomeScreenApiProvider(
                          context: context, params: params);
                }
              });*/
            },
            leading: Padding(
              padding: EdgeInsetsDirectional.only(end: Constant.size10),
              child: Icon(Icons.add, color: ColorsRes.appColor, size: 20),
            ),
            title: CustomTextLabel(
              jsonKey: "add_address",
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  color: ColorsRes.appColor,
                  fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: ColorsRes.mainTextColor.withValues(alpha: 0.5),
                size: 15),
          ),
        ],
      ),
    );
  }
}
