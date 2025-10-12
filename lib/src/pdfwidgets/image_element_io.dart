import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/dom.dart' as dom;
import 'package:http/http.dart';
import 'package:image/image.dart' as img;

import '../../htmltopdfwidgets.dart';

Future<Widget> parseImageElement(dom.Element element,
    {required HtmlTagStyle customStyles}) async {
  final src = element.attributes["src"];
  try {
    if (src != null) {
      if (src.startsWith("data:image/")) {
        // To handle a case if someone added a space after base64 string
        final List<String> components = src.split(",");

        if (components.length > 1) {
          var base64Encoded = components.last;
          Uint8List listData = base64Decode(base64Encoded);
          return Image(MemoryImage(listData),
              alignment: customStyles.imageAlignment);
        }
        return Text("$src");
      }
      if (src.startsWith("http") || src.startsWith("https")) {
        final netImage = await _saveImage(src);
        return Image(MemoryImage(netImage),
            alignment: customStyles.imageAlignment);
      }

      final localImage = File(src);
      if (await localImage.exists()) {
        var localImageBytes = await _getFileBytes(localImage);
        return Image(MemoryImage(localImageBytes));
      }
    }
    return Text("$src");
  } catch (e) {
    return Text("$src");
  }
}

const imageMaxHeight = 450;
Future<Uint8List> _getFileBytes(File imageFile) async {
  final Uint8List byteList = await imageFile.readAsBytes();
  final image = img.decodeImage(byteList);
  if (image == null) return byteList;
  int height = image.height;
  print("height width: $height, width: ${image.width}");
  if (height > imageMaxHeight) {
    height = imageMaxHeight;
  }
  final resized = img.copyResize(image, height: height, maintainAspect: true);
  print("resized width: ${resized.width}, height: ${resized.height}");
  return Uint8List.fromList(img.encodeJpg(resized));
  // return byteList;
}

/// Function to download and save an image from a URL
Future<Uint8List> _saveImage(String url) async {
  try {
    /// Download image
    final Response response = await get(Uri.parse(url));

    /// Get temporary directory

    return response.bodyBytes;
  } catch (e) {
    throw Exception(e);
  }
}
