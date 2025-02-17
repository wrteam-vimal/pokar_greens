import 'package:image_picker_platform_interface/src/types/image_source.dart'
    as ip;
import 'package:project/helper/utils/generalImports.dart';

class EditProfile extends StatefulWidget {
  final String? from;
  final Map<String, String>? loginParams;

  const EditProfile({Key? key, this.from, this.loginParams}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController editUserNameTextEditingController =
      TextEditingController();
  late TextEditingController editEmailTextEditingController =
      TextEditingController();
  late TextEditingController editMobileTextEditingController =
      TextEditingController();

  final TextEditingController editPasswordTextEditingController =
      TextEditingController();

  final TextEditingController editConfirmPasswordTextEditingController =
      TextEditingController();

  CountryCode? selectedCountryCode;
  bool isLoading = false;
  String tempName = "";
  String tempEmail = "";
  String tempMobile = "";
  String selectedImagePath = "";

  bool isEditable = false;
  bool showOtpWidget = false;

  final pinController = TextEditingController();

  void ToggleComponentsWidget(bool showMobileWidget) {
    setState(() {
      showOtpWidget = showMobileWidget;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      if (Constant.session.isUserLoggedIn()) {
        isEditable =
            Constant.session.getData(SessionManager.keyLoginType) == "phone";
      } else {
        isEditable = widget.loginParams?[ApiAndParams.type] == "phone";
      }

      tempName = widget.from == "header"
          ? Constant.session.getData(SessionManager.keyUserName)
          : widget.loginParams?[ApiAndParams.name] ?? "";
      tempEmail = widget.from == "header"
          ? Constant.session.getData(SessionManager.keyEmail)
          : widget.loginParams?[ApiAndParams.email] ?? "";
      tempMobile = widget.from == "header"
          ? Constant.session.getData(SessionManager.keyPhone)
          : widget.loginParams?[ApiAndParams.mobile] ?? "";

      editUserNameTextEditingController = TextEditingController(text: tempName);
      editEmailTextEditingController = TextEditingController(text: tempEmail);
      editMobileTextEditingController = TextEditingController(text: tempMobile);

      selectedImagePath = "";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          text: (widget.from == "register" || widget.from == "email_register")
              ? getTranslatedValue(
                  context,
                  "register",
                )
              : getTranslatedValue(
                  context,
                  "edit_profile",
                ),
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
        showBackButton: widget.from != "register",
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size15),
        children: [
          imgWidget(),
          Container(
            decoration:
                DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Constant.size10, vertical: Constant.size15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  userInfoWidget(),
                  const SizedBox(height: 50),
                  proceedBtn()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  proceedBtn() {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        return userProfileProvider.profileState == ProfileState.loading
            ? const Center(child: CircularProgressIndicator())
            : gradientBtnWidget(
                context,
                10,
                title: getTranslatedValue(
                  context,
                  (!showOtpWidget && widget.from == "email_register")
                      ? "send_otp"
                      : (widget.from == "register_header" ||
                              widget.from == "email_register")
                          ? "register"
                          : "update",
                ),
                callback: () async {
                  try {
                    if (await fieldValidation()) {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        widget.loginParams?[ApiAndParams.name] =
                            editUserNameTextEditingController.text.trim();

                        if (widget.loginParams?[ApiAndParams.type] == "phone" ||
                            Constant.session
                                    .getData(SessionManager.keyLoginType) ==
                                "phone") {
                          if (editEmailTextEditingController.text.isNotEmpty) {
                            widget.loginParams?[ApiAndParams.email] =
                                editEmailTextEditingController.text.trim();
                          }
                        } else {
                          widget.loginParams?[ApiAndParams.email] =
                              editEmailTextEditingController.text.trim();
                        }

                        if (widget.loginParams?[ApiAndParams.type] != "phone" ||
                            Constant.session
                                    .getData(SessionManager.keyLoginType) !=
                                "phone") {
                          if (editMobileTextEditingController.text.isNotEmpty) {
                            widget.loginParams?[ApiAndParams.mobile] =
                                editMobileTextEditingController.text.trim();
                          }
                        } else {
                          widget.loginParams?[ApiAndParams.mobile] =
                              editMobileTextEditingController.text.trim();
                        }

                        if (widget.from == "email_register") {
                          widget.loginParams?[ApiAndParams.password] =
                              editPasswordTextEditingController.text.trim();
                        }
                        if (widget.from == "email_register" && !showOtpWidget) {
                          userProfileProvider
                              .registerAccountApi(
                                  context: context,
                                  params: widget.loginParams ?? {})
                              .then(
                            (value) {
                              if (value == "1") {
                                ToggleComponentsWidget(true);
                              }
                            },
                          );
                        } else if (widget.from == "email_register" &&
                            showOtpWidget) {
                          if (pinController.text.isEmpty) {
                            showMessage(
                              context,
                              getTranslatedValue(context, "otp_required"),
                              MessageType.warning,
                            );
                          } else {
                            userProfileProvider
                                .verifyRegisteredEmailProvider(
                              context: context,
                              params: {
                                ApiAndParams.email:
                                    editEmailTextEditingController.text,
                                ApiAndParams.code: pinController.text,
                              },
                              from: "otp_register",
                            )
                                .then((value) {
                              if (value) {
                                Navigator.pop(context);
                              }
                            });
                          }
                        } else if (widget.from == "register" ||
                            widget.from == "register_header" ||
                            widget.from == "add_to_cart_register") {
                          userProfileProvider
                              .registerAccountApi(
                                  context: context,
                                  params: widget.loginParams ?? {})
                              .then(
                            (value) async {
                              if (value != "0") {
                                if (context
                                    .read<CartListProvider>()
                                    .cartList
                                    .isNotEmpty) {
                                  addGuestCartBulkToCartWhileLogin(
                                    context: context,
                                    params: Constant.setGuestCartParams(
                                      cartList: context
                                          .read<CartListProvider>()
                                          .cartList,
                                    ),
                                  ).then(
                                    (value) {
                                      if (widget.from ==
                                          "add_to_cart_register") {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      } else {
                                        return Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                mainHomeScreen,
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    },
                                  );
                                } else {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      mainHomeScreen,
                                      (Route<dynamic> route) => false);
                                }

                                if (Constant.session.isUserLoggedIn()) {
                                  await context
                                      .read<CartProvider>()
                                      .getCartListProvider(context: context);
                                } else {
                                  if (context
                                      .read<CartListProvider>()
                                      .cartList
                                      .isNotEmpty) {
                                    await context
                                        .read<CartProvider>()
                                        .getGuestCartListProvider(
                                            context: context);
                                  }
                                }
                              }
                            },
                          );
                        } else if (widget.from == "add_to_cart") {
                          Map<String, String> params = {};
                          params[ApiAndParams.name] =
                              editUserNameTextEditingController.text.trim();
                          params[ApiAndParams.email] =
                              editEmailTextEditingController.text.trim();
                          params[ApiAndParams.mobile] =
                              editMobileTextEditingController.text.trim();
                          params[ApiAndParams.countryCode] =
                              selectedCountryCode!.dialCode.toString();
                          userProfileProvider
                              .updateUserProfile(
                                  context: context,
                                  selectedImagePath: selectedImagePath,
                                  params: params)
                              .then(
                            (value) {
                              if (context
                                  .read<CartListProvider>()
                                  .cartList
                                  .isNotEmpty) {
                                addGuestCartBulkToCartWhileLogin(
                                    context: context,
                                    params: Constant.setGuestCartParams(
                                      cartList: context
                                          .read<CartListProvider>()
                                          .cartList,
                                    )).then(
                                  (value) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                );
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    mainHomeScreen,
                                    (Route<dynamic> route) => false);
                              }
                            },
                          );

                          if (Constant.session.isUserLoggedIn()) {
                            await context
                                .read<CartProvider>()
                                .getCartListProvider(context: context);
                          } else {
                            if (context
                                .read<CartListProvider>()
                                .cartList
                                .isNotEmpty) {
                              await context
                                  .read<CartProvider>()
                                  .getGuestCartListProvider(context: context);
                            }
                          }
                        } else {
                          Map<String, String> params = {};
                          params[ApiAndParams.name] =
                              editUserNameTextEditingController.text.trim();
                          params[ApiAndParams.email] =
                              editEmailTextEditingController.text.trim();
                          params[ApiAndParams.mobile] =
                              editMobileTextEditingController.text.trim();
                          params[ApiAndParams.countryCode] =
                              selectedCountryCode!.dialCode.toString();
                          userProfileProvider
                              .updateUserProfile(
                                  context: context,
                                  selectedImagePath: selectedImagePath,
                                  params: params)
                              .then(
                            (value) async {
                              if (value is bool) {
                                if (Constant.session.getData(
                                            SessionManager.keyLatitude) ==
                                        "0" &&
                                    Constant.session.getData(
                                            SessionManager.keyLongitude) ==
                                        "0" &&
                                    Constant.session.getData(
                                            SessionManager.keyAddress) ==
                                        "") {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    confirmLocationScreen,
                                    (Route<dynamic> route) => false,
                                    arguments: [null, "location"],
                                  );
                                } else {
                                  if (widget.from == "header") {
                                    if (context
                                        .read<CartListProvider>()
                                        .cartList
                                        .isNotEmpty) {
                                      addGuestCartBulkToCartWhileLogin(
                                        context: context,
                                        params: Constant.setGuestCartParams(
                                          cartList: context
                                              .read<CartListProvider>()
                                              .cartList,
                                        ),
                                      ).then(
                                        (value) => Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          mainHomeScreen,
                                          (Route<dynamic> route) => false,
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        mainHomeScreen,
                                        (Route<dynamic> route) => false,
                                      );
                                    }
                                  } else if (widget.from == "add_to_cart") {
                                    addGuestCartBulkToCartWhileLogin(
                                        context: context,
                                        params: Constant.setGuestCartParams(
                                          cartList: context
                                              .read<CartListProvider>()
                                              .cartList,
                                        )).then(
                                      (value) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  } else {
                                    showMessage(
                                      context,
                                      getTranslatedValue(context,
                                          "profile_updated_successfully"),
                                      MessageType.success,
                                    );
                                  }
                                }
                                userProfileProvider.changeState();
                              } else {
                                userProfileProvider.changeState();
                                showMessage(
                                  context,
                                  value.toString(),
                                  MessageType.warning,
                                );
                              }

                              if (Constant.session.isUserLoggedIn()) {
                                await context
                                    .read<CartProvider>()
                                    .getCartListProvider(context: context);
                              } else {
                                if (context
                                    .read<CartListProvider>()
                                    .cartList
                                    .isNotEmpty) {
                                  await context
                                      .read<CartProvider>()
                                      .getGuestCartListProvider(
                                          context: context);
                                }
                              }
                            },
                          );
                        }
                      }
                    }
                  } catch (e) {
                    userProfileProvider.changeState();
                    showMessage(
                      context,
                      e.toString(),
                      MessageType.error,
                    );
                  }
                },
              );
      },
    );
  }

  userInfoWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          editBoxWidget(
            context,
            editUserNameTextEditingController,
            emptyValidation,
            getTranslatedValue(
              context,
              "user_name",
            ),
            getTranslatedValue(
              context,
              "enter_user_name",
            ),
            TextInputType.text,
          ),
          SizedBox(height: Constant.size15),
          editBoxWidget(
            context,
            editEmailTextEditingController,
            emailValidation,
            getTranslatedValue(
              context,
              "email",
            ),
            getTranslatedValue(
              context,
              "enter_valid_email",
            ),
            TextInputType.text,
            isEditable: (tempEmail.isEmpty || isEditable),
          ),
          SizedBox(height: Constant.size15),
          mobileNoWidget(),
          if (widget.from == "email_register") ...[
            SizedBox(height: Constant.size15),
            ChangeNotifierProvider<PasswordShowHideProvider>(
              create: (context) => PasswordShowHideProvider(),
              child: Consumer<PasswordShowHideProvider>(
                builder: (context, provider, child) {
                  return editBoxWidget(
                    context,
                    editPasswordTextEditingController,
                    emptyValidation,
                    getTranslatedValue(
                      context,
                      "password",
                    ),
                    getTranslatedValue(
                      context,
                      "enter_valid_password",
                    ),
                    maxLines: 1,
                    obscureText: provider.isPasswordShowing(),
                    tailIcon: GestureDetector(
                      onTap: () {
                        provider.togglePasswordVisibility();
                      },
                      child: defaultImg(
                        image: provider.isPasswordShowing() == true
                            ? "hide_password"
                            : "show_password",
                        iconColor: ColorsRes.grey,
                        width: 13,
                        height: 13,
                        padding: EdgeInsetsDirectional.all(12),
                      ),
                    ),
                    optionalTextInputAction: TextInputAction.done,
                    TextInputType.text,
                  );
                },
              ),
            ),
            SizedBox(height: Constant.size15),
            ChangeNotifierProvider<PasswordShowHideProvider>(
              create: (context) => PasswordShowHideProvider(),
              child: Consumer<PasswordShowHideProvider>(
                builder: (context, provider, child) {
                  return editBoxWidget(
                    context,
                    editConfirmPasswordTextEditingController,
                    emptyValidation,
                    getTranslatedValue(
                      context,
                      "confirm_password",
                    ),
                    getTranslatedValue(
                      context,
                      "enter_valid_confirm_password",
                    ),
                    maxLines: 1,
                    obscureText: provider.isPasswordShowing(),
                    tailIcon: GestureDetector(
                      onTap: () {
                        provider.togglePasswordVisibility();
                      },
                      child: defaultImg(
                        image: provider.isPasswordShowing() == true
                            ? "hide_password"
                            : "show_password",
                        iconColor: ColorsRes.grey,
                        width: 13,
                        height: 13,
                        padding: EdgeInsetsDirectional.all(12),
                      ),
                    ),
                    optionalTextInputAction: TextInputAction.done,
                    TextInputType.text,
                  );
                },
              ),
            ),
            if (showOtpWidget)
              AnimatedOpacity(
                opacity: showOtpWidget ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Visibility(
                  visible: showOtpWidget,
                  child: Column(
                    children: [
                      SizedBox(height: Constant.size15),
                      otpPinWidget(
                          context: context, pinController: pinController),
                    ],
                  ),
                ),
              ),
            SizedBox(height: Constant.size15),
          ]
        ],
      ),
    );
  }

  mobileNoWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorsRes.subTitleMainTextColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          IgnorePointer(
            ignoring: isLoading,
            child: CountryCodePicker(
              onInit: (countryCode) {
                selectedCountryCode = countryCode;
              },
              onChanged: (countryCode) {
                selectedCountryCode = countryCode;
              },
              enabled: !isEditable,
              initialSelection: Constant.initialCountryCode,
              textOverflow: TextOverflow.ellipsis,
              backgroundColor: Theme.of(context).cardColor,
              textStyle: TextStyle(color: ColorsRes.mainTextColor),
              dialogBackgroundColor: Theme.of(context).cardColor,
              dialogSize: Size(context.width, context.height),
              barrierColor: ColorsRes.subTitleMainTextColor,
              padding: EdgeInsets.zero,
              searchDecoration: InputDecoration(
                iconColor: ColorsRes.subTitleMainTextColor,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: ColorsRes.subTitleMainTextColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: ColorsRes.subTitleMainTextColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: ColorsRes.subTitleMainTextColor),
                ),
                focusColor: Theme.of(context).scaffoldBackgroundColor,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ColorsRes.subTitleMainTextColor,
                ),
              ),
              searchStyle: TextStyle(
                color: ColorsRes.subTitleMainTextColor,
              ),
              dialogTextStyle: TextStyle(
                color: ColorsRes.mainTextColor,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: ColorsRes.grey,
            size: 15,
          ),
          getSizedBox(
            width: Constant.size10,
          ),
          Expanded(
            child: TextField(
              controller: editMobileTextEditingController,
              enabled:
                  (!isEditable || editMobileTextEditingController.text.isEmpty),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: TextStyle(
                color: ColorsRes.mainTextColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(color: ColorsRes.grey.withValues(alpha:0.5)),
                hintText: "9999999999",
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> fieldValidation() async {
    bool checkInternet = await checkInternetConnection();
    if (!checkInternet) {
      showMessage(
        context,
        getTranslatedValue(
          context,
          "check_internet",
        ),
        MessageType.warning,
      );
      return false;
    } else {
      String? userNameValidate = await emptyValidation(
        editUserNameTextEditingController.text,
      );

      String? mobileValidate = await phoneValidation(
        editMobileTextEditingController.text,
      );

      String? emailValidate = await emailValidation(
        editEmailTextEditingController.text,
      );

      String? passwordValidate = await emptyValidation(
        editPasswordTextEditingController.text,
      );

      if (userNameValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_user_name",
          ),
          MessageType.warning,
        );
        return false;
      } else if (emailValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_email",
          ),
          MessageType.warning,
        );
        return false;
      } else if (isEditable && mobileValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_mobile",
          ),
          MessageType.warning,
        );
        return false;
      } else if (widget.from == "email_register" && passwordValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_password",
          ),
          MessageType.warning,
        );
        return false;
      } else if (widget.from == "email_register" &&
          (editPasswordTextEditingController.text !=
              editConfirmPasswordTextEditingController.text)) {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "password_and_confirm_password_not_match",
          ),
          MessageType.warning,
        );
        return false;
      } else if (widget.from == "email_register" &&
          editPasswordTextEditingController.text.length <= 5) {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "password_length_is_too_short",
          ),
          MessageType.warning,
        );
        return false;
      } else {
        return true;
      }
    }
  }

  imgWidget() {
    return Center(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 15, end: 15),
            child: ClipRRect(
              borderRadius: Constant.borderRadius10,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: selectedImagePath.isEmpty
                  ? setNetworkImg(
                      height: 100,
                      width: 100,
                      boxFit: BoxFit.cover,
                      image:
                          Constant.session.getData(SessionManager.keyUserImage),
                    )
                  : Image.file(
                      File(selectedImagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (widget.from != "register")
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  showModalBottomSheet<XFile>(
                    context: context,
                    isScrollControlled: true,
                    shape:
                        DesignConfig.setRoundedBorderSpecific(20, istop: true),
                    backgroundColor: Theme.of(context).cardColor,
                    builder: (BuildContext context) {
                      return Wrap(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: 20, end: 20, bottom: 20),
                            child: Column(
                              children: [
                                getSizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: CustomTextLabel(
                                    jsonKey: "select_option",
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .merge(
                                          TextStyle(
                                            letterSpacing: 0.5,
                                            color: ColorsRes.mainTextColor,
                                          ),
                                        ),
                                  ),
                                ),
                                getSizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await hasStoragePermissionGiven().then(
                                          (value) async {
                                            if (await Permission.storage.isGranted ||
                                                await Permission
                                                    .storage.isLimited ||
                                                await Permission
                                                    .photos.isGranted ||
                                                await Permission
                                                    .photos.isLimited) {
                                              ImagePicker()
                                                  .pickImage(
                                                source: ip.ImageSource.gallery,
                                              )
                                                  .then((value) {
                                                if (value != null) {
                                                  Navigator.pop(context, value);
                                                }
                                              });
                                            } else if (await Permission
                                                .storage.isPermanentlyDenied) {
                                              if (!Constant.session.getBoolData(
                                                  SessionManager
                                                      .keyPermissionGalleryHidePromptPermanently)) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return Wrap(
                                                      children: [
                                                        PermissionHandlerBottomSheet(
                                                          titleJsonKey:
                                                              "storage_permission_title",
                                                          messageJsonKey:
                                                              "storage_permission_message",
                                                          sessionKeyForAskNeverShowAgain:
                                                              SessionManager
                                                                  .keyPermissionGalleryHidePromptPermanently,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.image_rounded,
                                        size: 50,
                                      ),
                                      splashColor: ColorsRes.appColor,
                                      splashRadius: 50,
                                      color: ColorsRes.subTitleMainTextColor,
                                      tooltip: getTranslatedValue(
                                          context, "gallery"),
                                    ),
                                    getSizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await hasCameraPermissionGiven(context)
                                            .then(
                                          (value) async {
                                            if (Platform.isAndroid) {
                                              if (value.isGranted) {
                                                ImagePicker()
                                                    .pickImage(
                                                  source:
                                                      ip.ImageSource.camera,
                                                  preferredCameraDevice:
                                                      CameraDevice.front,
                                                  maxHeight: 512,
                                                  maxWidth: 512,
                                                )
                                                    .then(
                                                  (value) {
                                                    if (value != null) {
                                                      Navigator.pop(
                                                          context, value);
                                                    }
                                                  },
                                                );
                                              } else if (value.isDenied) {
                                                await Permission.camera
                                                    .request();
                                              } else if (value
                                                  .isPermanentlyDenied) {
                                                if (!Constant.session
                                                    .getBoolData(SessionManager
                                                        .keyPermissionCameraHidePromptPermanently)) {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return Wrap(
                                                        children: [
                                                          PermissionHandlerBottomSheet(
                                                            titleJsonKey:
                                                                "camera_permission_title",
                                                            messageJsonKey:
                                                                "camera_permission_message",
                                                            sessionKeyForAskNeverShowAgain:
                                                                SessionManager
                                                                    .keyPermissionCameraHidePromptPermanently,
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              }
                                            } else if (Platform.isIOS) {
                                              ImagePicker()
                                                  .pickImage(
                                                source: ip.ImageSource.camera,
                                                preferredCameraDevice:
                                                    CameraDevice.front,
                                                maxHeight: 512,
                                                maxWidth: 512,
                                              )
                                                  .then(
                                                (value) {
                                                  if (value != null) {
                                                    Navigator.pop(
                                                        context, value);
                                                  }
                                                },
                                              );
                                            }
                                                                                    },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.camera_alt_rounded,
                                        color: ColorsRes.subTitleMainTextColor,
                                        size: 50,
                                      ),
                                      splashColor: ColorsRes.appColor,
                                      splashRadius: 50,
                                      color: ColorsRes.subTitleMainTextColor,
                                      tooltip: getTranslatedValue(
                                        context,
                                        "take_photo",
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ).then(
                    (value) {
                      if (value != null) {
                        cropImage(value.path);
                      }
                    },
                  );
                },
                child: Container(
                  decoration: DesignConfig.boxGradient(5),
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsetsDirectional.only(end: 8, top: 8),
                  child: defaultImg(
                    image: "edit_icon",
                    iconColor: ColorsRes.mainIconColor,
                    height: 15,
                    width: 15,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> cropImage(String filePath) async {
    await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 50,
      compressFormat: ImageCompressFormat.png,
      maxHeight: 512,
      maxWidth: 512,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Theme.of(context).cardColor,
          toolbarWidgetColor: ColorsRes.mainTextColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          activeControlsWidgetColor: ColorsRes.appColor,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioPickerButtonHidden: false,
          aspectRatioLockDimensionSwapEnabled: true,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: true,
        ),
      ],
    ).then(
      (croppedFile) {
        if (croppedFile != null) {
          selectedImagePath = croppedFile.path;
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    editUserNameTextEditingController.dispose();
    editEmailTextEditingController.dispose();
    editMobileTextEditingController.dispose();
    super.dispose();
  }
}