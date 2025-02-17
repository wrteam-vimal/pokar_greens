import 'package:project/helper/utils/generalImports.dart';

class CustomTextLabel extends StatelessWidget {
  final String? text;
  final String? jsonKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? lines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const CustomTextLabel({
    Key? key,
    this.text,
    this.jsonKey,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.lines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return jsonKey != null
        ? Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return Text(
                context.read<LanguageProvider>().currentLanguage[jsonKey] ??
                    context
                        .read<LanguageProvider>()
                        .currentLocalOfflineLanguage[jsonKey] ??
                    jsonKey,
                style: style ?? TextStyle(color: ColorsRes.mainTextColor),
                textAlign: textAlign,
                maxLines: maxLines,
                textWidthBasis: TextWidthBasis.parent,
                overflow: overflow,
                softWrap: softWrap ?? true,
              );
            },
          )
        : Text(
            text ?? "",
            style: style ?? TextStyle(color: ColorsRes.mainTextColor),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap ?? true,
          );
  }
}
