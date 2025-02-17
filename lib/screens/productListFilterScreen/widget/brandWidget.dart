import 'package:project/helper/utils/generalImports.dart';

getBrandWidget(List<Brands> brands, BuildContext context) {
  return GridView.builder(
    itemCount: brands.length,
    padding: EdgeInsets.symmetric(
        horizontal: Constant.size10, vertical: Constant.size10),
    shrinkWrap: true,
    itemBuilder: (BuildContext context, int index) {
      Brands brand = brands[index];
      return GestureDetector(
        onTap: () {
          context
              .read<ProductFilterProvider>()
              .addRemoveBrandIds(brand.id.toString());
        },
        child: Card(
          elevation: 0,
          shape: DesignConfig.setRoundedBorder(10),
          color: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: Constant.borderRadius10,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: setNetworkImg(
                          image: brand.imageUrl, boxFit: BoxFit.cover),
                    ),
                    if (context
                        .watch<ProductFilterProvider>()
                        .selectedBrands
                        .contains(brand.id.toString()))
                      PositionedDirectional(
                        top: 0,
                        start: 0,
                        bottom: 0,
                        end: 0,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha:0.8),
                                borderRadius: Constant.borderRadius10),
                            child: Icon(
                              Icons.check_rounded,
                              color: ColorsRes.appColor,
                              size: 60,
                            )),
                      ),
                  ],
                ),
              ),
              getSizedBox(
                height: Constant.size10,
              ),
              CustomTextLabel(
                text: brand.name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.74,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10),
  );
}
