import 'dart:developer';

import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String text;

  const LoadingButton({super.key, required this.onPressed, required this.text, required MaterialColor color, required Color textColor});

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  // @override
  // Widget build(BuildContext context) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.max,
  //     children: [
  //       Expanded(
  //         child: ElevatedButton(
  //          style: ElevatedButton.styleFrom(
  //           padding: const EdgeInsets.symmetric(vertical: 12),
  //           backgroundColor: Colors.green, // Set background color
  //           foregroundColor: Colors.white, // Set text color
  //         ), // Set text color
  //           onPressed:
  //               (_isLoading || widget.onPressed == null) ? null : _loadFuture,
  //           child: _isLoading
  //               ? const SizedBox(
  //                   height: 22,
  //                   width: 22,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     color: Colors.white, //set loader color
  //                   ))
  //               : Text(widget.text),
  //         ),
  //       ),
  //     ],
  //   );
  // }
Widget build(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.green, // Button background color
            foregroundColor: Colors.white,  // Button text color
          ),
          onPressed: (_isLoading || widget.onPressed == null) ? null : _loadFuture,
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white, // Loader color to white
                  ),
                )
              : Text(widget.text),
        ),
      ),
    ],
  );
}



  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error $e')));
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}