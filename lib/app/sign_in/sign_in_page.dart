import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jia/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

enum FormType { login, register }

class _SignInPageState extends State<SignInPage> {
  bool _absorb = false;

  Future<void> _auth(BuildContext context) async {
    try {
      final auth = Provider.of<FirebaseAuthService>(context, listen: false);
      if (_formType == FormType.login) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailAndPassword(
            context, _email, _password, _name, _id, 'guest');
      }
    } catch (e) {
      _errMsg = '';
      setState(() {
        if (e.toString().contains('[firebase_auth/wrong-password]')) {
          _errMsg = "Password salah";
        } else if (e.toString().contains('[firebase_auth/user-not-found]')) {
          _errMsg = "Email belum terdaftar";
        } else if (e.toString().contains('[firebase_auth/invalid-email]')) {
          _errMsg = "Penulisan email salah";
        } else if (e
            .toString()
            .contains('[firebase_auth/email-already-in-use]')) {
          _errMsg = "Email telah terdaftar";
        } else if (e.toString().contains('[firebase_auth/too-many-requests]')) {
          _errMsg = "Terlalu banyak kesalahan, coba lagi nanti";
        } else if (e.toString().contains('[firebase_auth/user-disabled]')) {
          _errMsg = "Maaf akun ini diblokir, silahkan menghubungi admin";
        } else if (e.toString().contains('[firebase_auth/weak-password]')) {
          _errMsg = "Password terlalu mudah";
        } else if (e
            .toString()
            .contains('[firebase_auth/network-request-failed]')) {
          _errMsg = "Internet bermasalah";
        } else if (e.toString().contains('[firebase_auth/unknown]')) {
          _errMsg = "koneksi internet lambat";
        }
      });
      dialog(context, _errMsg)
          .whenComplete(() => setState(() => _isLoading = false));
      print('Error: $e');
    }
  }

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _name;
  int _id;
  String _errMsg;
  bool _isLoading = false;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      NetworkConfig.pingUrls = ['https://mockbin.com/request'];
      NetworkConfig.pollIntervalMs = 500;
      NetworkConfig.timeoutMs = 2000;

      NetworkState.startPolling();

      final ns = new NetworkState();
      bool key = false;
      ns.addListener(() async {
        final hasConnection = key ? false : await ns.isConnected;
        if (hasConnection) {
          key = true;
          _auth(context);
          NetworkState.stopPolling();
        }
        Future.delayed(Duration(seconds: 6), () {
          if (!key) {
            key = true;
            dialog(context, 'Periksa sambungan internet Anda')
                .whenComplete(() => setState(() => _isLoading = false));
            NetworkState.stopPolling();
          }
        });
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _absorb ? true : false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('Sign in')),
        body: Center(
          child: AspectRatio(
            aspectRatio: 0.6,
            child: Container(
              child: new Form(
                key: formKey,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildInputs() + buildSubmitButtons(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        new TextFormField(
          decoration:
              new InputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
          validator: (value) =>
              value.isEmpty ? 'Email tidak boleh kosong' : null,
          onSaved: (value) => _email = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Password', icon: Icon(Icons.vpn_key_rounded)),
          validator: (value) =>
              value.isEmpty ? 'Password tidak boleh kosong' : null,
          onSaved: (value) => _password = value,
          obscureText: true,
        )
      ];
    } else {
      return [
        new TextFormField(
          decoration: new InputDecoration(labelText: 'Name'),
          validator: (value) =>
              value.isEmpty ? 'Name tidak boleh kosong' : null,
          onSaved: (value) => _name = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: 'Email'),
          validator: (value) =>
              value.isEmpty ? 'Email tidak boleh kosong' : null,
          onSaved: (value) => _email = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: 'Password'),
          validator: (value) =>
              value.isEmpty ? 'Password tidak boleh kosong' : null,
          onSaved: (value) => _password = value,
          obscureText: true,
        ),
        new TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: new InputDecoration(labelText: 'ID'),
          validator: (value) => value.isEmpty ? 'id tidak boleh kosong' : null,
          onSaved: (value) => _id = int.parse(value),
        )
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        Padding(padding: EdgeInsets.all(15.0)),
        !_isLoading
            ? new ElevatedButton.icon(
                icon: Icon(Icons.person),
                label: new Text(
                  'Login',
                  style: new TextStyle(fontSize: 20.0),
                ),
                onPressed: validateAndSubmit,
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        // new FlatButton(
        //   child: new Text(
        //     'Create an account',
        //     style: new TextStyle(fontSize: 20.0),
        //   ),
        //   onPressed: moveToRegister,
        // )
      ];
    } else {
      return [
        Padding(padding: EdgeInsets.all(15.0)),
        !_isLoading
            ? new ElevatedButton(
                child: new Text(
                  'Create an account',
                  style: new TextStyle(fontSize: 20.0),
                ),
                onPressed: validateAndSubmit,
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        new ElevatedButton(
          child: new Text(
            'Have an account? Login',
            style: new TextStyle(fontSize: 20.0),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
