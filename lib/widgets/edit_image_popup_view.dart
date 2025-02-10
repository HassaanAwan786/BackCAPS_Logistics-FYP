import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import '../core/utils/utils.dart';
import '../model/ImageProperties.dart';

Future<File?> showEditImagePopup(BuildContext context, var image, {
  required String title,
  required List<String> list,
  required String presetImageLocation,
}) async {
  Completer<File?> completer = Completer<File?>();
  showDialog<File?>(
    context: context,
    builder: (_) => AlertDialog(
      content: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kDefaultRounding),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await showModalBottomSheet<File?>(
                            context: context,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Gap(16),
                                        GridView.count(
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: List.generate(
                                            list.length,
                                            (int index) => ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      kDefaultRounding),
                                              child: Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      final unsignedImage =
                                                          await ImageProperties
                                                              .convertImageToUnsigned(Image(
                                                                  image: AssetImage(
                                                                      list[
                                                                          index])));
                                                      final imagePath =
                                                          await ImageProperties
                                                              .savePathFromImage(
                                                                  unsignedImage);
                                                      image = File(imagePath);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Image(
                                                      image: AssetImage(
                                                          list[
                                                              index]),
                                                      height: 70,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Image(
                                  image: AssetImage(presetImageLocation),
                                  height: 74),
                              Text("Presets", style: poppins_bold),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            TableCell(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultRounding),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              image = await getImageFromSource(context, ImageSource.camera, image);
                              Navigator.pop(context);
                              // return image;
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(Icons.camera_alt_outlined),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultRounding),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              image = await getImageFromSource(context, ImageSource.gallery, image);
                              Navigator.pop(context);
                              // return image;
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(Icons.photo_library_outlined),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    ),
  ).then((value) => completer.complete(image));
  return completer.future;
}

Future<dynamic> getImageFromSource(
    BuildContext context, ImageSource source, var image) async {
  Completer<File?> completer = Completer<File?>();
  try {
    final picker = ImagePicker();
    Utils.showLoadingIndicator(context);
    final imagePick = await picker.pickImage(source: source);
    final imageTemporary = File(imagePick!.path);
    // setState(() => image = imageTemporary);
    image = imageTemporary;
    Navigator.pop(context);
    completer.complete(image);
  } catch (e) {
    Utils.showAlertPopup(context, "Image Error", "Error: $e");
    completer.complete(null);
  }
  return completer.future;
}

Future<ImageSource> showScanPopup(BuildContext context) async {
  Completer<ImageSource> completer = Completer<ImageSource>();
  ImageSource? source;
  showDialog(context: context, builder: (_) => AlertDialog(
    content: Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultRounding),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    source = ImageSource.camera;
                    Navigator.pop(context);
                    // return image;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined),
                          ],
                        ),
                        Text("Camera", style: poppins_bold,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultRounding),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    source = ImageSource.gallery;
                    Navigator.pop(context);
                    // return image;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_outlined),
                          ],
                        ),
                        Text("Gallery", style: poppins_bold,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  )).then((value) => completer.complete(source));
  return completer.future;
}