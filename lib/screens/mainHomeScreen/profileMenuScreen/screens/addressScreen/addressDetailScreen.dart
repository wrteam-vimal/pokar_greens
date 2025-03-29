import 'package:project/helper/utils/generalImports.dart';

class AddressDetailScreen extends StatefulWidget {
  final UserAddressData? address;
  final BuildContext addressProviderContext;

  const AddressDetailScreen({
    Key? key,
    this.address,
    required this.addressProviderContext,
  }) : super(key: key);

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

enum AddressType { home, office, other }

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController edtName = TextEditingController();
  final TextEditingController edtMobile = TextEditingController();
  final TextEditingController edtAltMobile = TextEditingController();
  final TextEditingController edtAddress = TextEditingController();
  final TextEditingController edtLandmark = TextEditingController();
  final TextEditingController edtCity = TextEditingController();
  final TextEditingController edtArea = TextEditingController();
  final TextEditingController edtZipcode = TextEditingController();
  final TextEditingController edtCountry = TextEditingController();
  final TextEditingController edtState = TextEditingController();
  bool isLoading = false;
  bool isDefaultAddress = false;
  String longitude = "";
  String latitude = "";
  AddressType selectedAddressType = AddressType.home;

  //Address types
  static Map addressTypes = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        addressTypes = {
          "home": getTranslatedValue(
            context,
            "address_type_home",
          ),
          "office": getTranslatedValue(
            context,
            "address_type_office",
          ),
          "other": getTranslatedValue(
            context,
            "address_type_other",
          ),
        };

        edtName.text = widget.address?.name ?? "";
        edtAltMobile.text = widget.address?.alternateMobile == null ||
                widget.address?.alternateMobile == "null"
            ? ""
            : widget.address!.alternateMobile.toString();
        edtMobile.text = widget.address?.mobile ?? "";
        edtAddress.text = widget.address?.address ?? "";
        edtLandmark.text = widget.address?.landmark ?? "";
        edtCity.text = widget.address?.city ?? "";
        edtArea.text = widget.address?.area ?? "";
        edtZipcode.text = widget.address?.pincode ?? "";
        edtCountry.text = widget.address?.country ?? "";
        edtState.text = widget.address?.state ?? "";
        isDefaultAddress = widget.address?.isDefault == "1";
        if (widget.address?.type?.toLowerCase() == "home") {
          selectedAddressType = AddressType.home;
        } else if (widget.address?.type?.toLowerCase() == "office") {
          selectedAddressType = AddressType.office;
        } else if (widget.address?.type?.toLowerCase() == "other") {
          selectedAddressType = AddressType.other;
        } else {
          selectedAddressType = AddressType.home;
        }
        longitude = widget.address?.longitude ?? "";
        latitude = widget.address?.latitude ?? "";

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "address_detail",
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
        ),
        body: Stack(
          children: [
            ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: Constant.size10, vertical: Constant.size10),
                children: [
                  Form(
                      key: formKey,
                      child: Column(
                        children: [
                          contactWidget(),
                          addressDetailWidget(),
                        ],
                      )),
                  addressTypeWidget()
                ]),
            isLoading == true
                ? PositionedDirectional(
                    top: 0,
                    end: 0,
                    start: 0,
                    bottom: 0,
                    child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                        child:
                            const Center(child: CircularProgressIndicator())),
                  )
                : const SizedBox.shrink()
          ],
        ));
  }

  contactWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "contact_details",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            editBoxWidget(
              context,
              edtName,
              emptyValidation,
              getTranslatedValue(
                context,
                "name",
              ),
              getTranslatedValue(
                context,
                "enter_name",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtMobile,
              phoneValidation,
              getTranslatedValue(
                context,
                "mobile_number",
              ),
              getTranslatedValue(
                context,
                "enter_valid_mobile",
              ),
              TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtAltMobile,
              optionalPhoneValidation,
              getTranslatedValue(
                context,
                "alternate_mobile_number",
              ),
              getTranslatedValue(
                context,
                "enter_valid_mobile",
              ),
              TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ],
        ),
      ),
    );
  }

  addressDetailWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "address_details",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            editBoxWidget(
                isReadOnly: true,
                context,
                edtAddress,
                emptyValidation,
                getTranslatedValue(
                  context,
                  "address",
                ),
                getTranslatedValue(
                  context,
                  "please_select_address_from_map",
                ),
                TextInputType.text,
                maxLength: 191,
                tailIcon: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, confirmLocationScreen,
                        arguments: [null, "address"]).then(
                      (value) {
                        setState(
                          () {
                            edtAddress.text =
                                Constant.cityAddressMap["address"];

                            edtCity.text = Constant.cityAddressMap["city"];

                            edtArea.text = Constant.cityAddressMap["area"];

                            edtLandmark.text =
                                edtLandmark.text.toString().isNotEmpty
                                    ? edtLandmark.text.toString()
                                    : Constant.cityAddressMap["landmark"];

                            edtZipcode.text = edtZipcode.text.isNotEmpty
                                ? edtZipcode.text.toString()
                                : Constant.cityAddressMap["pin_code"];

                            edtCountry.text = Constant.cityAddressMap["country"]
                                    .toString()
                                    .isNotEmpty
                                ? Constant.cityAddressMap["country"]
                                : "";

                            edtState.text = Constant.cityAddressMap["state"]
                                    .toString()
                                    .isNotEmpty
                                ? Constant.cityAddressMap["state"].toString()
                                : "";

                            longitude =
                                Constant.cityAddressMap["longitude"].toString();

                            latitude =
                                Constant.cityAddressMap["latitude"].toString();
                          },
                        );
                        formKey.currentState?.validate();
                      },
                    );
                  },
                  icon: Icon(
                    Icons.my_location_rounded,
                    color: ColorsRes.appColor,
                  ),
                )),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtLandmark,
              emptyValidation,
              getTranslatedValue(
                context,
                "landmark",
              ),
              getTranslatedValue(
                context,
                "enter_landmark",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtCity,
              emptyValidation,
              getTranslatedValue(
                context,
                "city",
              ),
              getTranslatedValue(
                context,
                "please_select_address_from_map",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtArea,
              emptyValidation,
              getTranslatedValue(
                context,
                "area",
              ),
              getTranslatedValue(
                context,
                "enter_area",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtZipcode,
              emptyValidation,
              getTranslatedValue(
                context,
                "pin_code",
              ),
              getTranslatedValue(
                context,
                "enter_pin_code",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtState,
              emptyValidation,
              getTranslatedValue(
                context,
                "state",
              ),
              getTranslatedValue(
                context,
                "enter_state",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtCountry,
              emptyValidation,
              getTranslatedValue(
                context,
                "country",
              ),
              getTranslatedValue(
                context,
                "enter_country",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
          ],
        ),
      ),
    );
  }

  addressTypeWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.size10,
          vertical: Constant.size10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "address_type",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.home,
                        activeColor: ColorsRes.appColor,
                        groupValue: selectedAddressType,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.home;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["home"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.office,
                        groupValue: selectedAddressType,
                        activeColor: ColorsRes.appColor,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.office;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["office"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.other,
                        groupValue: selectedAddressType,
                        activeColor: ColorsRes.appColor,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.other;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["other"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            getSizedBox(height: Constant.size10),
            Row(
              children: [
                CustomCheckbox(
                  value: isDefaultAddress,
                  onChanged: (value) {
                    isDefaultAddress = !isDefaultAddress;
                    setState(
                      () {},
                    );
                  },
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    isDefaultAddress = !isDefaultAddress;
                    setState(
                      () {},
                    );
                  },
                  child: CustomTextLabel(
                    jsonKey: "set_as_default_address",
                  ),
                ))
              ],
            ),
            getSizedBox(height: Constant.size10),
            gradientBtnWidget(
              context,
              8,
              title: (widget.address?.id.toString() ?? "").isNotEmpty
                  ? getTranslatedValue(
                      context,
                      "update",
                    )
                  : getTranslatedValue(
                      context,
                      "add_new_address",
                    ),
              callback: () async {
                formKey.currentState!.save();
                if (formKey.currentState!.validate()) {
                  if (longitude.isEmpty && latitude.isEmpty) {
                    setState(() {
                      isLoading = false;
                    });
                    showMessage(
                      context,
                      getTranslatedValue(
                        context,
                        "please_select_address_from_map",
                      ),
                      MessageType.warning,
                    );
                  } else if (edtMobile.text == edtAltMobile.text) {
                    setState(() {
                      isLoading = false;
                    });
                    showMessage(
                      context,
                      getTranslatedValue(
                        context,
                        "mobile_number_and_alternate_mobile_number_cannot_be_same",
                      ),
                      MessageType.warning,
                    );
                  } else {
                    Map<String, String> params = {};

                    String id = widget.address?.id.toString() ?? "";
                    if (id.isNotEmpty) {
                      params[ApiAndParams.id] = id;
                    }

                    params[ApiAndParams.name] = edtName.text.trim().toString();
                    params[ApiAndParams.mobile] =
                        edtMobile.text.trim().toString();
                    if (selectedAddressType == AddressType.home) {
                      params[ApiAndParams.type] = "home";
                    } else if (selectedAddressType == AddressType.office) {
                      params[ApiAndParams.type] = "office";
                    } else if (selectedAddressType == AddressType.other) {
                      params[ApiAndParams.type] = "other";
                    } else {
                      params[ApiAndParams.type] = "home";
                    }
                    params[ApiAndParams.address] =
                        edtAddress.text.trim().toString();
                    params[ApiAndParams.landmark] =
                        edtLandmark.text.trim().toString();
                    params[ApiAndParams.area] = edtArea.text.trim().toString();
                    params[ApiAndParams.pinCode] =
                        edtZipcode.text.trim().toString();
                    params[ApiAndParams.city] = edtCity.text.trim().toString();
                    params[ApiAndParams.state] =
                        edtState.text.trim().toString();
                    params[ApiAndParams.country] =
                        edtCountry.text.trim().toString();
                    params[ApiAndParams.alternateMobile] =
                        edtAltMobile.text.trim().toString();
                    params[ApiAndParams.latitude] = latitude;
                    params[ApiAndParams.longitude] = longitude;
                    params[ApiAndParams.isDefault] =
                        isDefaultAddress == true ? "1" : "0";

                    widget.addressProviderContext
                        .read<AddressProvider>()
                        .addOrUpdateAddress(
                            context: context,
                            address: widget.address ?? "",
                            params: params,
                            function: () {
                              Navigator.pop(context);
                            });
                    setState(() {
                      isLoading = true;
                    });
                  }
                }
              },
            ),
            getSizedBox(height: Constant.size10),
          ],
        ),
      ),
    );
  }
}
