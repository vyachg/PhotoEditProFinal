import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_painter/image_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';

//Запуск приложения
void main() => runApp(PhotoEditPro());



final _imageKey = GlobalKey<ImagePainterState>();
File? _image;


//загрузка изображения
Future<XFile?> loadImage() async {
  final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
  return image;
}

//сохранение изображения(используется библиотека GallerySaver) и вывод сообщения
void saveImage(BuildContext context) async {
  final image = await _imageKey.currentState?.exportImage();
  ImageGallerySaver.saveImage(image!);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.grey[700],
      padding: const EdgeInsets.only(left: 10),
      content: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Image Exported successfully.",
              style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}

//настройки приложения и обозначение главного виджета MainPage()
class PhotoEditPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhotoEdit Pro',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

//Создание главного виджета(Вкладки и подобное)
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      loadImage().then((value) => {_image = File(value!.path)});
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        onPressed: (){
          setState(() {
            print(_currentIndex);
            if (_currentIndex < 2){
              _currentIndex++;
            } else {
              _currentIndex = 0;
            }
          });
        },
      ),
      appBar: AppBar(
        title: const Text("PhotoEdit PRO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => {
              saveImage(context)
            },
          )
        ],
      ),
      body: [
        //Содержимое вкладок
        const Text(
            "PhotoEditPro",
          textAlign: TextAlign.center,
          textScaleFactor: 3,
        ),
        ImageFilterPage(),
        ImagePainterPage(),
      ][_currentIndex],
    );
  }

}

//Вкладка с рисованием. Библиотека Image_painter.
class ImagePainterPage extends StatefulWidget {
  @override
  _ImagePainterPageState createState() => _ImagePainterPageState();
}

class _ImagePainterPageState extends State<ImagePainterPage> {
  @override
  Widget build(BuildContext context) {
      return ImagePainter.file(
        _image!,
        key: _imageKey,
        scalable: true,
        initialStrokeWidth: 2,
        textDelegate: TextDelegate(),
        initialColor: Colors.red,
        initialPaintMode: PaintMode.freeStyle,
      );
  }
}


//Виджет с фильтрами. Библиотека Image_filter.
class ImageFilterPage extends StatefulWidget {
  const ImageFilterPage({Key? key}) : super(key: key);

  @override
  State<ImageFilterPage> createState() => _ImageFilterPageState();
}

class _ImageFilterPageState extends State<ImageFilterPage> {
  late TextureSource texture;
  late BrightnessShaderConfiguration configuration1;
  late ColorInvertShaderConfiguration configuration2;
  late PixelationShaderConfiguration configuration3;
  late GlassSphereShaderConfiguration configuration4;
  late VignetteShaderConfiguration configuration5;
  bool textureLoaded = false;
  late double reff;
  late ShaderConfiguration configuration;

  late _MainPageState mainpageState;

  //Тут инициализируем виджет и присваиваем переменной texture нашу картинку.
  @override
  void initState(){
    super.initState();
    configuration = BrightnessShaderConfiguration();
    TextureSource.fromFile(_image!)
        .then((value) => texture = value)
        .whenComplete(
          () => setState(() {
        textureLoaded = true;
      }),
    );
  }

  //Далее идут заготовленные пресеты фильтров.
  void conf1(){
    setState(() {
      configuration1 = BrightnessShaderConfiguration();
      configuration1.brightness = 0.5;
      configuration = configuration1;
    });
  }

  void conf2(){
    setState(() {
      configuration2 = ColorInvertShaderConfiguration();
      configuration = configuration2;
    });
  }

  void conf3(){
    setState(() {
      configuration3 = PixelationShaderConfiguration();
      configuration = configuration3;
    });
  }

  void conf4(){
    setState(() {
      configuration4 = GlassSphereShaderConfiguration();
      configuration = configuration4;
    });
  }

  void conf5(){
    setState(() {
      configuration5 = VignetteShaderConfiguration();
      configuration = configuration5;
    });
  }

  //Сам виджет с фильтрами. 5 кнопок для пресетов.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FloatingActionButton(onPressed: conf1, child: Icon(Icons.add_road, color: Colors.grey,),),
          FloatingActionButton(onPressed: conf2, child: Icon(Icons.align_horizontal_right, color: Colors.red,),),
          FloatingActionButton(onPressed: conf3, child: Icon(Icons.analytics, color: Colors.green,),),
          FloatingActionButton(onPressed: conf4, child: Icon(Icons.animation, color: Colors.blue,),),
          FloatingActionButton(onPressed: conf5, child: Icon(Icons.api, color: Colors.black,),),

        ],
      ),
      body:
      //Шаблон из библиотеки для наложения фильтров и вывода изображения
        ImageShaderPreview(
        texture: texture,
        configuration: configuration,
          key: _imageKey,
      ),
    );
  }
}


