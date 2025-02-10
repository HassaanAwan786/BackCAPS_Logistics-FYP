import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class ImageProperties{
  static Future<String> saveImageFromPath(String imagePath) async{
    try{
      //Get application path using path_provider plugin
      final appPath = await getApplicationDocumentsDirectory();

      //Join the path of application with private_images
      final privateDirectory = Directory(join(appPath.path, 'private_images'));

      //Check if the private_images directory exists or not
      if(!privateDirectory.existsSync()){
        //if not then create the directory
        privateDirectory.createSync();
      }

      final imageName = basename(imagePath);
      final imageFile = File(imagePath);
      final destinationFile = File(join(privateDirectory.path, imageName));
      await imageFile.copy(destinationFile.path);

      return destinationFile.path;
    }catch(e){
      print("Something went wrong: ${e.toString()}");
      return "";
    }
  }
  static Future<String> getName(String imagePath) async{
    try{
      return basename(imagePath);
    }catch(e){
      print(e.toString());
      return "Null";
    }
  }
  static Future<String> savePathFromImage(Uint8List imageBytes) async {
    try{
      final appDirectory = await getApplicationDocumentsDirectory();
      final fileName = "IMG_${DateTime.now().millisecondsSinceEpoch}";
      final filePath = "${appDirectory.path}/$fileName";
      await File(filePath).writeAsBytes(imageBytes);
      return filePath;
    }catch(e){
      print(e.toString());
      return "";
    }
  }
  static Future<Uint8List> convertImageToUnsigned(Image image) async {
    ImageProvider imageProvider = image.image;
    ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
    Completer<Uint8List> completer = Completer();

    // Convert the loaded image to UInt8List
    imageStream.addListener(ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
      ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uInt8list = byteData!.buffer.asUint8List();
      completer.complete(uInt8list);
    }));

    Uint8List imageUInt8List = await completer.future;
    return imageUInt8List;
  }

  static Future<Uint8List?> convertFilterToImage(GlobalKey colorFilteredImageKey) async {
    //This code is needed to be changed
    RenderRepaintBoundary renderRepaintBoundary =
    colorFilteredImageKey.currentContext?.findRenderObject()
    as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 4);
    ByteData? byteData =
    await boxImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}