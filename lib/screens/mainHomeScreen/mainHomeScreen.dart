import 'package:geolocator/geolocator.dart';
import 'package:project/helper/utils/generalImports.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  State<HomeMainScreen> createState() => HomeMainScreenState();
}

class HomeMainScreenState extends State<HomeMainScreen>
    with WidgetsBindingObserver {
  NetworkStatus networkStatus = NetworkStatus.online;
  bool _openedAppSettings = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _openedAppSettings) {
      _openedAppSettings = false;

      // Reset the flag
      locationPermission(false);
      setState(() {}); // Call the method to fetch the current location
    }
  }

  @override
  void dispose() {
    context
        .read<HomeMainScreenProvider>()
        .scrollController[0]
        .removeListener(() {});
    context
        .read<HomeMainScreenProvider>()
        .scrollController[1]
        .removeListener(() {});
    context
        .read<HomeMainScreenProvider>()
        .scrollController[2]
        .removeListener(() {});
    context
        .read<HomeMainScreenProvider>()
        .scrollController[3]
        .removeListener(() {});
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    if (mounted) {
      context.read<HomeMainScreenProvider>().setPages();
    }
    Future.delayed(
      Duration.zero,
      () async {
        context.read<AppSettingsProvider>().getAppSettingsProvider(context);
        showLocationBottomSheet(context);
        await LocalAwesomeNotification().init(context);
        //LocalNotificationService.init(context);
/*        LocalNotificationService.foregroundNotificationListener();
        LocalNotificationService.handleTerminatedState();*/

        if (Constant.session
            .getData(SessionManager.keyFCMToken)
            .trim()
            .isEmpty) {
          await FirebaseMessaging.instance.getToken().then((token) {
            Constant.session.setData(SessionManager.keyFCMToken, token!, false);

            Map<String, String> params = {
              ApiAndParams.fcmToken:
                  Constant.session.getData(SessionManager.keyFCMToken),
              ApiAndParams.platform: Platform.isAndroid ? "android" : "ios"
            };

            registerFcmKey(context: context, params: params);
          }).onError((e, _) {
            return;
          });
        }

        if ((Constant.session.getData(SessionManager.keyLatitude) == "" &&
                Constant.session.getData(SessionManager.keyLongitude) == "") ||
            (Constant.session.getData(SessionManager.keyLatitude) == "0" &&
                Constant.session.getData(SessionManager.keyLongitude) == "0")) {
          Navigator.pushNamed(context, confirmLocationScreen,
              arguments: [null, "location"]);
        } else {
          if (context.read<HomeMainScreenProvider>().getCurrentPage() == 0) {
            if (Constant.popupBannerEnabled) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog();
                },
              );
            }
          }

          if (Constant.session.isUserLoggedIn()) {
            await context
                .read<AddressProvider>()
                .getAddressProvider(context: context);

            await getAppNotificationSettingsRepository(
                    params: {}, context: context)
                .then(
              (value) async {
                if (value[ApiAndParams.status].toString() == "1") {
                  late AppNotificationSettings notificationSettings =
                      AppNotificationSettings.fromJson(value);
                  if (notificationSettings.data!.isEmpty) {
                    await updateAppNotificationSettingsRepository(params: {
                      ApiAndParams.statusIds: "1,2,3,4,5,6,7,8",
                      ApiAndParams.mobileStatuses: "0,1,1,1,1,1,1,1",
                      ApiAndParams.mailStatuses: "0,1,1,1,1,1,1,1"
                    }, context: context);
                  }
                }
              },
            );
          }
        }

        showLocationBottomSheet(context);

        WidgetsBinding.instance.addObserver(this);
      },
    );

    super.initState();
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

  IconData addressType(UserAddressData address) {
    if (address.type?.toLowerCase() == "home") {
      return Icons.home_outlined;
    } else if (address.type?.toLowerCase() == "office") {
      return Icons.business_center_outlined;
    } else if (address.type?.toLowerCase() == "other") {
      return Icons.person;
    } else {
      return Icons.home_outlined;
    }
  }

  void showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Allows full-screen sheet if needed
      backgroundColor: Colors.transparent,
      // Make it transparent for floating button
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          // Allows floating button to be outside the sheet
          children: [
            // The Main BottomSheet
            Container(
              padding: EdgeInsets.only(top: 20), // Space for close button
              decoration: BoxDecoration(
                color: ColorsRes.bgColorLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Consumer<AddressProvider>(
                    builder: (context, addressProvider, child) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: DesignConfig.boxDecoration(
                                  ColorsRes.cardColorLight, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_off,
                                      color: ColorsRes.appColorRed, size: 30),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getTranslatedValue(context,
                                              "device_location_not_enabled"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  ColorsRes.mainTextColorLight),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          getTranslatedValue(context,
                                              "enable_your_device_location"),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ColorsRes
                                                  .subTitleTextColorLight),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 13),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorsRes.appColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      locationPermission(true);
                                      /* await requestLocationPermission(context);
                                      setState(() {}); */ // Force rebuild
                                    },
                                    child: Text(
                                      getTranslatedValue(context, "enable"),
                                      style: TextStyle(
                                          color: ColorsRes.bgColorLight,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Text(
                                  getTranslatedValue(
                                      context, "select_saved_address"),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsRes.mainTextColorLight),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    getTranslatedValue(context, "see_all"),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorsRes.appColor),
                                  ),
                                ),
                              ],
                            ),
                            (addressProvider.addressState ==
                                        AddressState.loaded ||
                                    addressProvider.addressState ==
                                        AddressState.editing)
                                ? Container(
                                    padding: EdgeInsets.all(12),
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    decoration: DesignConfig.boxDecoration(
                                        ColorsRes.cardColorLight, 10),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          addressProvider.addresses.length,
                                      itemBuilder: (context, index) {
                                        final address =
                                            addressProvider.addresses[index];
                                        return Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(addressType(address),
                                                  size: 24,
                                                  color: ColorsRes
                                                      .mainTextColorLight),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      address.name ?? "",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: ColorsRes
                                                            .mainTextColorLight,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      address.address
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: ColorsRes
                                                            .mainTextColorLight
                                                            .withValues(
                                                                alpha: 0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : addressProvider.addressState ==
                                        AddressState.loading
                                    ? getAddressListShimmer()
                                    : const SizedBox.shrink(),
                            if (addressProvider.addressState ==
                                AddressState.editing)
                              Positioned.fill(
                                child: Container(
                                  color: ColorsRes.appColor,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                              ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.search),
                              title: Text("Search location manually"),
                              onTap: () {
                                // Handle manual search
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Floating Close Button Above BottomSheet
            Positioned(
              top: -55, // Position above bottom sheet
              left: MediaQuery.of(context).size.width / 2 - 17, // Center it
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 17),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }
  }

  void locationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorsRes.bgColorLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: ColorsRes.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),

              // Image/Icon
              Icon(Icons.location_off, size: 60, color: ColorsRes.appColor),

              SizedBox(height: 20),

              // Title
              Text(
                getTranslatedValue(context, 'location_permission_off'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              // Subtitle
              Text(
                getTranslatedValue(
                    context, 'enable_location_permission_delivery_experience'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: ColorsRes.subTitleTextColorLight),
              ),

              SizedBox(height: 25),

              // Enable Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsRes.appColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    locationPermission(false);
                    //Geolocator.requestPermission();
                  },
                  child: Text(
                    getTranslatedValue(context, 'enable_location_permission'),
                    style:
                        TextStyle(fontSize: 16, color: ColorsRes.bgColorLight),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Search Manually Text Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: ColorsRes.appColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: ColorsRes.appColor)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (Constant.session
                        .getBoolData(SessionManager.isUserLogin)) {
                      Navigator.pushNamed(
                        context,
                        selectLocationAddress,
                      ).then((value) async {});
                    } else {
                      Navigator.pushNamed(context, confirmLocationScreen,
                          arguments: [null, "location"]).then((value) async {
                        if (value is bool) {
                          if (value == true) {
                            Map<String, String> params =
                                await Constant.getProductsDefaultParams();
                            await context
                                .read<HomeScreenProvider>()
                                .getHomeScreenApiProvider(
                                    context: context, params: params);
                          }
                        }
                      });
                    }
                  },
                  child: Text(
                    getTranslatedValue(context, 'search_location_manually'),
                    style: TextStyle(
                      color: ColorsRes.appColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  locationPermission(bool init) async {
    LocationPermission permission;

    // Check location permission status
    permission = await Geolocator.checkPermission();

    print("permission***$permission");

    if (permission == LocationPermission.deniedForever) {
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
        locationPermission(init);
      }
      Navigator.pop(context);
      _showLocationServiceInstructions();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        Navigator.pop(context);
        _showLocationServiceInstructions();

        return;
      } else {
        locationPermission(init);
        return;
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      checkLocationDelivery(
              latitude: position.latitude.toString(),
              longitude: position.longitude.toString())
          .then((value) async {
        Constant.session.setData(
            SessionManager.keyLongitude, position.longitude.toString(), false);
        Constant.session.setData(
            SessionManager.keyLatitude, position.latitude.toString(), false);
        if (context.read<CityByLatLongProvider>().isDeliverable) {
          Constant.session.setData(SessionManager.keyAddress,
              Constant.cityAddressMap["address"], true);
          Navigator.pop(context);
        } else {
          return;
        }
      });
    }
  }

  Future checkLocationDelivery(
      {required String latitude, required String longitude}) async {
    Map<String, dynamic> params = {};

    params[ApiAndParams.longitude] = longitude;
    params[ApiAndParams.latitude] = latitude;

    await context
        .read<CityByLatLongProvider>()
        .getCityByLatLongApiProvider(context: context, params: params);
  }

  /* locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    print("permission*****$permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // Show BottomSheet when permission is still denied
      // locationBottomSheet(context);
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
        //locationPermission();
      }
      _showLocationServiceInstructions();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
        //locationPermission();
      }
      _showLocationServiceInstructions();
    }

    */ /* if (permission == LocationPermission.deniedForever) {
      // Show BottomSheet directing user to settings
      locationBottomSheet(context);
      return;
    }*/ /*
  }*/

  void _showLocationServiceInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getTranslatedValue(
            context, 'please_enable_location_services_manually')),
        action: SnackBarAction(
          label: getTranslatedValue(context, 'ok'),
          textColor: ColorsRes.subTitleTextColorLight,
          onPressed: () {
            openAppSettings();
            setState(() {
              _openedAppSettings = true;
            });

            // Optionally handle action button press
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeMainScreenProvider>(
      builder: (context, homeMainScreenProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () {
                showLocationBottomSheet(context);
              },
              child: Text("Test"),
            ),
          ),
          bottomNavigationBar: homeBottomNavigation(
            homeMainScreenProvider.getCurrentPage(),
            homeMainScreenProvider.selectBottomMenu,
            homeMainScreenProvider.getPages().length,
            context,
          ),
          body: networkStatus == NetworkStatus.online
              ? PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (didPop) {
                      return;
                    } else {
                      if (homeMainScreenProvider.currentPage == 0) {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        }
                      } else {
                        setState(() {});
                        homeMainScreenProvider.currentPage = 0;
                      }
                    }
                  },
                  child: IndexedStack(
                    index: homeMainScreenProvider.currentPage,
                    children: homeMainScreenProvider.getPages(),
                  ),
                )
              : Center(
                  child: CustomTextLabel(
                    jsonKey: "check_internet",
                  ),
                ),
        );
      },
    );
  }

  homeBottomNavigation(int selectedIndex, Function selectBottomMenu,
      int totalPage, BuildContext context) {
    List lblHomeBottomMenu = [
      getTranslatedValue(
        context,
        "home_bottom_menu_home",
      ),
      getTranslatedValue(
        context,
        "home_bottom_menu_category",
      ),
      getTranslatedValue(
        context,
        "home_bottom_menu_wishlist",
      ),
      getTranslatedValue(
        context,
        "home_bottom_menu_profile",
      ),
    ];
    return BottomNavigationBar(
        items: List.generate(
          totalPage,
          (index) => BottomNavigationBarItem(
            backgroundColor: Theme.of(context).cardColor,
            icon: getHomeBottomNavigationBarIcons(
                isActive: selectedIndex == index)[index],
            label: lblHomeBottomMenu[index],
          ),
        ),
        type: BottomNavigationBarType.shifting,
        currentIndex: selectedIndex,
        selectedItemColor: ColorsRes.mainTextColor,
        unselectedItemColor: Colors.transparent,
        onTap: (int ind) {
          selectBottomMenu(ind);
        },
        elevation: 5);
  }
}
