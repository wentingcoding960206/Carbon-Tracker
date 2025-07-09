import 'package:flutter/material.dart';

class MPage extends StatelessWidget{
  const MPage({super.key});
  @override
  Widget build(BuildContext context){
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
        style: BorderStyle.solid,
        //strokeAlign: BorderSide.strokeAlignCenter
      ),
    borderRadius:BorderRadius.circular(40)
    /*borderRadius: BorderRadius.all(
      Radius.circular(40),
    ),*/
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,//up n down
            children: [
              const Text('anonymous',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold, //->bold 
                color: Color.fromRGBO(225, 0, 0, 1),
              ),
              ),
            Container( // padding
              padding: const EdgeInsets.all(8.0),
              //margin:EdgeInsets.all(0),
              //color: Colors.black,
              child: TextField(
                style: const TextStyle(
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  //labelText: 'say something', ->cant change the color or else
                  //helperText: 'say something', ->below the line
                  hintText: 'say something', //->will disappear
                  hintStyle: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                  /*label: Text('say something',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),*/
                  prefixIcon: const Icon(Icons.question_answer),//->at left
                  prefixIconColor: Colors.black54, 
                  //suffixIcon: ->at right 
                  filled: true, //->background
                  fillColor: Colors.white,
                  focusedBorder: border,
                  enabledBorder: border,
                ),
                keyboardType: TextInputType.none ,
                /*keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),*/
              ),
            ),
          ],
        ),//let the word in the mid),
      ),
        /*body: ColoredBox(
          color:Color.fromRGBO(225, 0, 0, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,//up n down
            crossAxisAlignment: CrossAxisAlignment.center,//right n left
            children: [
              Text('0'),
            ],
          ),//let the word in the mid),
        ),*/
    );
  }
}