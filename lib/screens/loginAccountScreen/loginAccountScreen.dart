import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/helper/utils/generalImports.dart';

enum AuthProviders { phone, google, apple, emailPassword }

class LoginAccountScreen extends StatefulWidget {
  final String? from;

  const LoginAccountScreen({Key? key, this.from}) : super(key: key);

  @override
  State<LoginAccountScreen> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccountScreen> {
  CountryCode? selectedCountryCode;

  // TODO REMOVE DEMO NUMBER FROM HERE
  TextEditingController editMobileTextEditingController =
      TextEditingController();
  final TextEditingController editEmailTextEditingController =
      TextEditingController();
  final TextEditingController editPasswordTextEditingController =
      TextEditingController();
  final pinController = TextEditingController();
  String otpVerificationId = "";
  int? forceResendingToken;
  bool showMobileNumberWidget = Constant.authTypePhoneLogin == "1",
      showOtpWidget = false,
      isLoading = false;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);

  AuthProviders authProvider = Constant.authTypePhoneLogin == "1"
      ? AuthProviders.phone
      : Constant.authTypeEmailLogin == "1"
          ? AuthProviders.emailPassword
          : Constant.authTypeGoogleLogin == "1"
              ? AuthProviders.google
              : AuthProviders.apple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          backgroundImageWidget(),
          backgroundOverlayImageWidget(),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: loginWidgets(),
          ),
          if (isLoading && authProvider != AuthProviders.phone)
            PositionedDirectional(
              top: 0,
              end: 0,
              bottom: 0,
              start: 0,
              child: Container(
                color: Colors.black.withValues(alpha:0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorsRes.appColor,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            top: 40,
            end: 10,
            child: skipLoginText(),
          ),
        ],
      ),
    );
  }

  Widget proceedBtn() {
    return (isLoading && authProvider == AuthProviders.phone)
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
              "login",
            ).toUpperCase(),
            callback: () {
              if (authProvider == AuthProviders.phone) {
                loginWithPhoneNumber();
              } else if (authProvider == AuthProviders.emailPassword) {
                loginWithEmailIdPassword();
              }
            },
          );
  }

  Widget skipLoginText() {
    return GestureDetector(
      onTap: () async {
        if (isLoading == false) {
          Constant.session
              .setBoolData(SessionManager.keySkipLogin, true, false);
          await getRedirection();
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: CustomTextLabel(
          jsonKey: "skip_login",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorsRes.mainTextColor,
              ),
        ),
      ),
    );
  }

  Widget loginWidgets() {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      constraints: BoxConstraints(
        maxHeight: context.height * 0.76,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            getSizedBox(height: Constant.size20),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 20, end: 20),
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleSmall!.merge(
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 30,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                  text: "${getTranslatedValue(
                    context,
                    "welcome",
                  )} ",
                  children: <TextSpan>[
                    TextSpan(
                      text: "${getTranslatedValue(context, "app_name")}!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 30,
                        color: ColorsRes.appColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (Constant.authTypePhoneLogin == "1" ||
                Constant.authTypeEmailLogin == "1") ...[
              getSizedBox(height: Constant.size40),
              AnimatedOpacity(
                opacity: showMobileNumberWidget ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Visibility(
                  visible: showMobileNumberWidget,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(start: 20, end: 20),
                    decoration: DesignConfig.boxDecoration(
                        Theme.of(context).scaffoldBackgroundColor, 10),
                    child: mobileNoWidget(),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: !showMobileNumberWidget ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Visibility(
                  visible: !showMobileNumberWidget,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(start: 20, end: 20),
                    child: emailPasswordWidget(),
                  ),
                ),
              ),
              getSizedBox(height: Constant.size20),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                child: proceedBtn(),
              ),
              getSizedBox(height: Constant.size20),
              if (authProvider == AuthProviders.emailPassword)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      editProfileScreen,
                      arguments: [
                        "email_register",
                        {
                          ApiAndParams.type: "email",
                          ApiAndParams.fcmToken: Constant.session
                              .getData(SessionManager.keyFCMToken),
                        }
                      ],
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomTextLabel(
                          jsonKey: "dont_have_an_account",
                          style: TextStyle(
                            color: ColorsRes.subTitleMainTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        getSizedBox(width: 5),
                        CustomTextLabel(
                          jsonKey: "wants_to_register",
                          style: TextStyle(
                            color: ColorsRes.appColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              getSizedBox(height: Constant.size20),
              if (Platform.isIOS && Constant.authTypeAppleLogin == "1" ||
                  Constant.authTypeGoogleLogin == "1")
                buildDottedDivider(context),
              getSizedBox(height: Constant.size20),
            ],
            if (Platform.isIOS && Constant.authTypeAppleLogin == "1") ...[
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                child: SocialMediaLoginButtonWidget(
                  text: "continue_with_apple",
                  logo: "apple_logo",
                  logoColor: ColorsRes.mainTextColor,
                  onPressed: () async {
                    authProvider = AuthProviders.apple;
                    await signInWithApple(
                      context: context,
                      firebaseAuth: firebaseAuth,
                      googleSignIn: googleSignIn,
                    ).then(
                      (value) {
                        setState(() {
                          isLoading = true;
                        });
                        if (value is UserCredential) {
                          setState(() {
                            isLoading = false;
                          });
                          backendApiProcess(value.user);
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          showMessage(
                              context, value.toString(), MessageType.error);
                        }
                      },
                    );
                  },
                ),
              ),
              getSizedBox(height: 10),
            ],
            if (Constant.authTypeGoogleLogin == "1")
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                child: SocialMediaLoginButtonWidget(
                  text: "continue_with_google",
                  logo: "google_logo",
                  onPressed: () async {
                    authProvider = AuthProviders.google;
                    signOut(
                            googleSignIn: googleSignIn,
                            authProvider: authProvider,
                            firebaseAuth: firebaseAuth)
                        .then(
                      (value) async {
                        await signInWithGoogle(
                          context: context,
                          firebaseAuth: firebaseAuth,
                          googleSignIn: googleSignIn,
                        ).then(
                          (value) {
                            if (value is UserCredential) {
                              backendApiProcess(value.user);
                            } else {
                              showMessage(
                                  context, value.toString(), MessageType.error);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            if (Constant.authTypeEmailLogin == "1" &&
                Constant.authTypePhoneLogin == "1") ...[
              if (showMobileNumberWidget)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                  child: SocialMediaLoginButtonWidget(
                    text: "continue_with_email",
                    logo: "email_logo",
                    logoColor: ColorsRes.appColor,
                    onPressed: () async {
                      authProvider = AuthProviders.emailPassword;
                      showMobileNumberWidget = false;
                      setState(() {});
                    },
                  ),
                ),
              if (!showMobileNumberWidget)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                  child: SocialMediaLoginButtonWidget(
                    text: "continue_with_phone",
                    logo: "phone_logo",
                    logoColor: ColorsRes.appColor,
                    onPressed: () async {
                      authProvider = AuthProviders.phone;
                      showMobileNumberWidget = true;
                      setState(() {});
                    },
                  ),
                ),
            ],
            getSizedBox(height: Constant.size20),
            Divider(color: ColorsRes.subTitleMainTextColor),
            getSizedBox(height: Constant.size20),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 30, end: 30),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleSmall!.merge(
                          TextStyle(
                            fontWeight: FontWeight.w400,
                            color: ColorsRes.subTitleMainTextColor,
                          ),
                        ),
                    text: "${getTranslatedValue(
                      context,
                      "agreement_message_1",
                    )}\t",
                    children: <TextSpan>[
                      TextSpan(
                          text: getTranslatedValue(context, "terms_of_service"),
                          style: TextStyle(
                            color: ColorsRes.appColor,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, webViewScreen,
                                  arguments: getTranslatedValue(
                                    context,
                                    "terms_and_conditions",
                                  ));
                            }),
                      TextSpan(
                          text: "\t${getTranslatedValue(
                            context,
                            "and",
                          )}\t",
                          style: TextStyle(
                            color: ColorsRes.subTitleMainTextColor,
                          )),
                      TextSpan(
                        text: getTranslatedValue(context, "privacy_policy"),
                        style: TextStyle(
                          color: ColorsRes.appColor,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                              context,
                              webViewScreen,
                              arguments: getTranslatedValue(
                                context,
                                "privacy_policy",
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            getSizedBox(height: Constant.size20),
          ],
        ),
      ),
    );
  }

  mobileNoWidget() {
    return Row(
      children: [
        getSizedBox(width: Constant.size5),
        IgnorePointer(
          ignoring: isLoading,
          child: CountryCodePicker(
            onInit: (countryCode) {
              selectedCountryCode = countryCode;
            },
            onChanged: (countryCode) {
              selectedCountryCode = countryCode;
            },
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
                borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
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
        getSizedBox(width: Constant.size10),
        Expanded(
          child: TextField(
            controller: editMobileTextEditingController,
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
              hintStyle: TextStyle(color: Colors.grey[300]),
              hintText: "",
            ),
          ),
        )
      ],
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
          leadingIcon: Icon(
            Icons.alternate_email_outlined,
            color: ColorsRes.grey,
            size: 25,
          ),
          maxLines: 1,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          TextInputType.emailAddress,
        ),
        getSizedBox(height: Constant.size20),
        Consumer<PasswordShowHideProvider>(
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
              leadingIcon: Icon(
                Icons.password_rounded,
                color: ColorsRes.grey,
                size: 25,
              ),
              maxLines: 1,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
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
        getSizedBox(height: Constant.size10),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                forgotPasswordScreen,
              );
            },
            child: CustomTextLabel(
              jsonKey: "forgot_password",
              style: TextStyle(
                color: ColorsRes.appColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (showOtpWidget) getSizedBox(height: Constant.size10),
        if (showOtpWidget)
          AnimatedOpacity(
            opacity: showOtpWidget ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Visibility(
              visible: showOtpWidget,
              child: Column(
                children: [
                  SizedBox(height: Constant.size15),
                  otpPinWidget(context: context, pinController: pinController)
                ],
              ),
            ),
          ),
      ],
    );
  }

  getRedirection() async {
    if (Constant.session.getBoolData(SessionManager.keySkipLogin) ||
        Constant.session.getBoolData(SessionManager.isUserLogin)) {
      Navigator.pushReplacementNamed(
        context,
        mainHomeScreen,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        mainHomeScreen,
        (route) => false,
      );
    }
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
    } else if (authProvider == AuthProviders.phone) {
      String? mobileValidate = await phoneValidation(
        editMobileTextEditingController.text,
      );
      if (mobileValidate == "") {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_mobile",
          ),
          MessageType.warning,
        );
        return false;
      } else if (mobileValidate != null &&
          editMobileTextEditingController.text.length > 15) {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_mobile",
          ),
          MessageType.warning,
        );
        return false;
      } else {
        return true;
      }
    } else if (authProvider == AuthProviders.emailPassword) {
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
      } else if (passwordValidate == "") {
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
      return false;
    }
  }

  loginWithPhoneNumber() async {
    var validation = await fieldValidation();
    if (validation) {
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });
      firebaseLoginProcess();
    }
  }

  loginWithEmailIdPassword() async {
    var validation = (await fieldValidation());
    if (validation) {
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });
      backendApiProcess(null);
    }
  }

  firebaseLoginProcess() async {
    authProvider == AuthProviders.phone;
    setState(() {});
    if (editMobileTextEditingController.text.isNotEmpty) {
      if (Constant.firebaseAuthentication == "1") {
        await firebaseAuth.verifyPhoneNumber(
          timeout: Duration(minutes: 1, seconds: 30),
          phoneNumber:
              '${selectedCountryCode!.dialCode}${editMobileTextEditingController.text}',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            showMessage(
              context,
              e.message!,
              MessageType.warning,
            );

            setState(() {
              isLoading = false;
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            forceResendingToken = resendToken;
            isLoading = false;
            setState(() {
              otpVerificationId = verificationId;

              List<dynamic> firebaseArguments = [
                firebaseAuth,
                otpVerificationId,
                editMobileTextEditingController.text,
                selectedCountryCode!,
                widget.from ?? null
              ];
              Navigator.pushNamed(context, otpScreen,
                  arguments: firebaseArguments);
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          forceResendingToken: forceResendingToken,
        );
      } else if (Constant.customSmsGatewayOtpBased == "1") {
        context.read<UserProfileProvider>().sendCustomOTPSmsProvider(
          context: context,
          params: {
            ApiAndParams.phone:
                "$selectedCountryCode${editMobileTextEditingController.text}"
          },
        ).then(
          (value) {
            if (value == "1") {
              List<dynamic> firebaseArguments = [
                firebaseAuth,
                otpVerificationId,
                editMobileTextEditingController.text,
                selectedCountryCode!,
                widget.from ?? null
              ];
              Navigator.pushNamed(context, otpScreen,
                  arguments: firebaseArguments);
            } else {
              setState(() {
                isLoading = false;
              });
              showMessage(
                context,
                getTranslatedValue(
                  context,
                  "custom_send_sms_error_message",
                ),
                MessageType.warning,
              );
            }
          },
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  backendApiProcess(User? user) async {
    if (showOtpWidget) {
      context
          .read<UserProfileProvider>()
          .verifyRegisteredEmailProvider(
              context: context,
              params: {
                ApiAndParams.email: editEmailTextEditingController.text,
                ApiAndParams.code: pinController.text,
              },
              from: "login")
          .then(
        (value) async {
          await callLoginApi(user);
        },
      );
    } else {
      await callLoginApi(user);
    }
  }

  Future callLoginApi(User? user) async {
    Map<String, String> params = {
      ApiAndParams.id: authProvider == AuthProviders.phone
          ? editMobileTextEditingController.text
          : authProvider == AuthProviders.emailPassword
              ? editEmailTextEditingController.text
              : user?.email.toString() ?? "",
      ApiAndParams.type: authProvider == AuthProviders.phone
          ? "phone"
          : authProvider == AuthProviders.google
              ? "google"
              : authProvider == AuthProviders.apple
                  ? "apple"
                  : authProvider == AuthProviders.emailPassword
                      ? "email"
                      : "",
      ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
      ApiAndParams.fcmToken:
          Constant.session.getData(SessionManager.keyFCMToken),
    };

    if (authProvider == AuthProviders.emailPassword) {
      params[ApiAndParams.password] =
          editPasswordTextEditingController.text.trim();
    }

    await context
        .read<UserProfileProvider>()
        .loginApi(context: context, params: params)
        .then(
      (value) async {
        isLoading = false;
        setState(() {});
        if (value == 1) {
          if (widget.from == "add_to_cart") {
            addGuestCartBulkToCartWhileLogin(
              context: context,
              params: Constant.setGuestCartParams(
                cartList: context.read<CartListProvider>().cartList,
              ),
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          } else if (Constant.session.getBoolData(SessionManager.isUserLogin)) {
            if (context.read<CartListProvider>().cartList.isNotEmpty) {
              addGuestCartBulkToCartWhileLogin(
                context: context,
                params: Constant.setGuestCartParams(
                  cartList: context.read<CartListProvider>().cartList,
                ),
              ).then(
                (value) => Navigator.of(context).pushNamedAndRemoveUntil(
                  mainHomeScreen,
                  (Route<dynamic> route) => false,
                ),
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                mainHomeScreen,
                (Route<dynamic> route) => false,
              );
            }
          }
        } else if (value == 2) {
          showOtpWidget = true;
          setState(() {});
        } else {
          setState(() {
            isLoading = false;
          });
          if (user != null) {
            Constant.session.setData(SessionManager.keyUserImage,
                firebaseAuth.currentUser!.photoURL.toString(), false);

            Navigator.of(context).pushNamed(
              editProfileScreen,
              arguments: [
                widget.from ?? "register",
                {
                  ApiAndParams.id: authProvider == AuthProviders.phone
                      ? editMobileTextEditingController.text
                      : user.email.toString(),
                  ApiAndParams.type: authProvider == AuthProviders.phone
                      ? "phone"
                      : authProvider == AuthProviders.google
                          ? "google"
                          : "apple",
                  ApiAndParams.name:
                      firebaseAuth.currentUser!.displayName ?? "",
                  ApiAndParams.email: firebaseAuth.currentUser!.email ?? "",
                  ApiAndParams.countryCode: "",
                  ApiAndParams.mobile:
                      firebaseAuth.currentUser!.phoneNumber ?? "",
                  ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
                  ApiAndParams.fcmToken:
                      Constant.session.getData(SessionManager.keyFCMToken),
                }
              ],
            );
          } else {
            if (value == 0) {
              showMessage(
                context,
                getTranslatedValue(
                  context,
                  "user_not_registered",
                ),
                MessageType.warning,
              );
            } else {
              showMessage(
                context,
                getTranslatedValue(
                  context,
                  "something_went_wrong",
                ),
                MessageType.warning,
              );
            }
          }
        }
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CountryCode?>(
        'selectedCountryCode', selectedCountryCode));
  }
}
