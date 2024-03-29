import 'dart:typed_data';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: DrawApp()
    );
  }
}

class DrawApp extends StatefulWidget {
  const DrawApp({Key? key}) : super(key: key);

  @override
  _DrawAppState createState() => _DrawAppState();
}

class _DrawAppState extends State<DrawApp> {

  // offset points
  List points = [];
  //color of the pen
  Color? color;
  //stroke width
  double strokeWidth = 2.0;
  //key
  GlobalKey globalKey = GlobalKey();
  //uuid generator generates unique id
  Uuid uuid = Uuid();


  //image gallery saver
  Future<void> _save() async {
    try{
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      // print("Png Bytessssss" + "  "+pngBytes.toString());

      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 60,
          name: "${uuid.v1().toString()}");
      print(result);
    }catch(e){
      print("Errorrrrrrrrr" + "  " + e.toString() );
    }
  }
  //



  //init state
  @override
  void initState() {
    super.initState();
    color = Colors.black;

  }

  //picks color from the color picker
  Widget buildColorPicker() => ColorPicker(
    pickerColor: color!,
    onColorChanged: (color) => setState(() {
      this.color = color;
    }),
  );
  void pickColor(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("pick your color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildColorPicker(),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Select",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebMob Drawing App"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: color // color of the main container
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),// color of the  box shadow
                            blurRadius: 5.0,
                            spreadRadius: 1.0
                        )
                      ]
                  ),
                  child: GestureDetector(
                    onPanDown: (details){
                      this.setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = color!
                              ..strokeWidth = strokeWidth
                        ));
                      });
                    },
                    onPanUpdate: (details){
                      this.setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = color!
                              ..strokeWidth = strokeWidth
                        ));
                      });
                    },
                    onPanEnd: (details){
                      this.setState(() {
                        points.add(null);
                      });
                    },
                    child: RepaintBoundary(
                      key: globalKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: CustomPaint(
                          painter:MyCustomPainter(points: points,color: color!) ,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Slider(
                          min: 1.0,
                          max: 5.0,

                          activeColor: color,
                          value: strokeWidth,

                          onChanged: (double value) {
                            this.setState(() {
                              strokeWidth = value;
                            });
                          },
                        ),
                      ),


                      IconButton(onPressed: (){
                        setState(() {
                          points.clear();
                        });

                      }, icon: Icon(Icons.phonelink_erase_rounded,color: color,)),
                      IconButton(onPressed: (){
                        pickColor(context);

                      }, icon: Icon(Icons.color_lens,color: color,)),
                      IconButton(onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Button pressed")));
                        setState(() {
                           _save();
                        });
                      }, icon: Icon(Icons.save))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter{

  List points;
  Color color;

  MyCustomPainter({required this.points,required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint() .. color = Colors.white;
    Rect rect = new Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);


    for(int x =0;x<points.length-1;x++){
      if(points[x] != null && points[x+1] != null){
        canvas.drawLine(points[x].point, points[x+1].point, points[x].areaPaint);
      }else if(points[x] != null && points[x+1] == null){
        canvas.drawPoints(ui.PointMode.points, [points[x].point], points[x].areaPaint);
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class DrawingArea{
  Offset point;
  Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}
