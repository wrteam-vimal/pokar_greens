import 'package:project/helper/utils/generalImports.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  //TODO REMOVE EMAIL AND PASSWORD
  final TextEditingController editEmailTextEditingController =
      TextEditingController();
  final TextEditingController editPasswordTextEditingController =
      TextEditingController();
  final TextEditingController editConfirmPasswordTextEditingController =
      TextEditingController();
  bool isDark = Constant.session.getBoolData(SessionManager.isDarkTheme);
  bool showPasswordWidget = false;
  bool isLoading = false;
  final pinController = TextEditingController();

  void ToggleComponentsWidget(bool showMobileWidget) {
    setState(() {
      showPasswordWidget = showMobileWidget;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 0,
            child: Image.asset(
              Constant.getAssetsPath(0, "bg.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 0,
            child: Image.asset(
              Constant.getAssetsPath(0, "bg_overlay.png"),
              fit: BoxFit.fill,
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: loginWidgets(),
          ),
          PositionedDirectional(
            top: 20,
            start: 0,
            child: backButtonText(),
          ),
        ],
      ),
    );
  }

  Widget backButtonText() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: SizedBox(
            child: defaultImg(
              boxFit: BoxFit.contain,
              image: "ic_arrow_back",
              iconColor: ColorsRes.mainTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget proceedBtn() {
    return (isLoading)
        ? Container(
            height: 55,
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          )
        : gradientBtnWidget(
            context,
            10,
            title: getTranslatedValue(
              context,
              showPasswordWidget ? "change_password" : "send_otp",
            ).toUpperCase(),
            callback: () async {
              if (await fieldValidation() == true) {
                isLoading = true;
                setState(() {});
                if (!showPasswordWidget) {
                  sendOTPForgotPasswordApi(params: {
                    ApiAndParams.email: editEmailTextEditingController.text
                  }, context: context)
                      .then(
                    (value) {
                      if (value[ApiAndParams.status].toString() == "1") {
                        isLoading = false;
                        ToggleComponentsWidget(true);
                        showMessage(
                          context,
                          getTranslatedValue(
                            context,
                            value[ApiAndParams.message].toString(),
                          ),
                          MessageType.success,
                        );
                      } else {
                        showMessage(
                          context,
                          getTranslatedValue(
                            context,
                            value[ApiAndParams.message].toString(),
                          ),
                          MessageType.warning,
                        );
                        isLoading = false;
                        setState(() {});
                      }
                    },
                  );
                } else {
                  forgotPasswordApi(context: context, params: {
                    ApiAndParams.email: editEmailTextEditingController.text,
                    ApiAndParams.otp: pinController.text,
                    ApiAndParams.password:
                        editPasswordTextEditingController.text,
                    ApiAndParams.passwordConfirmation:
                        editConfirmPasswordTextEditingController.text,
                  }).then(
                    (value) {
                      isLoading = false;
                      setState(() {});
                      showMessage(
                          context,
                          getTranslatedValue(
                            context,
                            value[ApiAndParams.message].toString(),
                          ),
                          (value[ApiAndParams.status].toString() == "1")
                              ? MessageType.success
                              : MessageType.warning);

                      if (value[ApiAndParams.status].toString() == "1") {
                        Navigator.pop(context);
                      }
                    },
                  );
                }
              }
            },
          );
  }

  Widget loginWidgets() {
    return Container(
      padding: EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextLabel(
            jsonKey: getTranslatedValue(context, "forgot_password_title"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 30,
              color: ColorsRes.appColor,
            ),
          ),
          getSizedBox(height: Constant.size20),
          emailPasswordWidget(),
          getSizedBox(height: Constant.size20),
          proceedBtn(),
          getSizedBox(height: Constant.size20),
        ],
      ),
    );
  }

  emailPasswordWidget() {
    return Column(
      children: [
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          maxLines: 1,
          TextInputType.emailAddress,
        ),
        AnimatedOpacity(
          opacity: showPasswordWidget ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Visibility(
            visible: showPasswordWidget,
            child: Column(
              children: [
                SizedBox(height: Constant.size15),
                otpPinWidget(context: context, pinController: pinController),
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
              ],
            ),
          ),
        ),
      ],
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
      String? emailValidate = await emailValidation(
        editEmailTextEditingController.text,
      );

      String? passwordValidate = await emptyValidation(
        editPasswordTextEditingController.text,
      );

      if (emailValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_email",
          ),
          MessageType.warning,
        );
        return false;
      } else if (showPasswordWidget) {
        if (passwordValidate == "") {
          showMessage(
            context,
            getTranslatedValue(
              context,
              "enter_valid_password",
            ),
            MessageType.warning,
          );
          return false;
        } else if (editPasswordTextEditingController.text.length <= 5) {
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
      } else {
        return true;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
