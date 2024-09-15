import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../constant/constants.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _obscured = true;
  var _isLogin = true;
  var _isUploading = false;
  var _enteredUserName = '';
  var _enteredEmail = '';
  var _enteredPassqord = '';
  File? _selectedImage;

  void _submit() async {
    final formState = _formKey.currentState;

    if (formState == null) {
      return;
    }

    final isValid = formState.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    formState.save();

    try {
      setState(() {
        _isUploading = true;
      });

      if (_isLogin) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassqord);

        setState(() {
          _isUploading = false;
        });
      } else {
        final userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassqord);

        final id = userCredential.user!.uid;

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(id)
            .child('${uuid.generate()}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(id).set({
          'userName': _enteredUserName,
          'email': _enteredEmail,
          'imageProfile': imageUrl
        });

        setState(() {
          _isUploading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isUploading = false;
      });
      // switch(e.code){
      //   case 'email-already-in-use':
      //     print('The account already exists for that email.');
      //     break;
      //   case 'invalid-email':
      //     print('The account already exists for that email.');
      //     break;

      //   default:
      // }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Authentication failed'),
      ));
    }
  }

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: (width < maxWidth) ? double.infinity : maxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  width: 200,
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onSelectedImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            textFormFieldUserName(),
                            const SizedBox(height: 8),
                            textFormFieldEmail(),
                            const SizedBox(height: 8),
                            textFormFieldPassword(),
                            const SizedBox(height: 20),
                            circularProgressIndicator(),
                            buttonLoginSignup(context),
                            const SizedBox(height: 8),
                            buttonForgotPassword(),
                            textOr(context),
                            buttonCreateOrHaveAccount(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Visibility circularProgressIndicator() {
    return Visibility(
      visible: _isUploading,
      child: const CircularProgressIndicator(),
    );
  }

  Visibility buttonCreateOrHaveAccount() {
    return Visibility(
      visible: !_isUploading,
      child: TextButton(
        onPressed: () {
          setState(() {
            _isLogin = !_isLogin;
          });
        },
        child:
            Text(_isLogin ? 'Create an account' : 'I already have an account'),
      ),
    );
  }

  Visibility textOr(BuildContext context) {
    return Visibility(
      visible: _isLogin,
      child: Text(
        'Or',
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Visibility buttonForgotPassword() {
    return Visibility(
      visible: _isLogin,
      child: TextButton(
        onPressed: () {},
        child: const Text('Forgot my password?'),
      ),
    );
  }

  Visibility buttonLoginSignup(BuildContext context) {
    return Visibility(
      visible: !_isUploading,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        onPressed: _submit,
        child: Text(
          _isLogin ? 'Login' : 'Signup',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.surfaceContainer),
        ),
      ),
    );
  }

  TextFormField textFormFieldPassword() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        labelText: 'Password',
        suffixIcon: InkWell(
          onTap: _toggleObscured,
          child: Icon(_obscured
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded),
        ),
        border: borderTextFormField,
      ),
      obscureText: _obscured,
      validator: (value) {
        if (value == null || value.trim().length < 6) {
          return 'Password must be at least 6 characters long';
        }

        return null;
      },
      onSaved: (newValue) {
        _enteredPassqord = newValue!;
      },
    );
  }

  TextFormField textFormFieldEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-Mail',
        filled: true,
        border: borderTextFormField,
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty || !value.contains('@')) {
          return 'Please enter a valid emmail address';
        }
        return null;
      },
      onSaved: (newValue) {
        _enteredEmail = newValue!;
      },
    );
  }

  Visibility textFormFieldUserName() {
    return Visibility(
      visible: !_isLogin,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'User Name',
          filled: true,
          border: borderTextFormField,
        ),
        keyboardType: TextInputType.name,
        enableSuggestions: false,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a valid user name';
          }
          return null;
        },
        onSaved: (newValue) {
          _enteredUserName = newValue!;
        },
      ),
    );
  }
}
