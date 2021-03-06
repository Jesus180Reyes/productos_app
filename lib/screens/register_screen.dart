import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/auth_background.dart';
import 'package:productos_app/widgets/card_container.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
              ),
              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Crear Cuenta',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(height: 39),
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: LoginForm(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                    Colors.indigo.withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.all(
                    StadiumBorder(),
                  ),
                ),
                child: Text(
                  'Ya tienes una Cuenta?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    @override
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: 'john@example.com',
                labelText: 'Correo Electronico',
                prefixIcon: Icons.alternate_email_rounded,
              ),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);
                return regExp.hasMatch(value ?? '')
                    ? null
                    : ' El Correo ingresado no es Correcto, Intenta de nuevo.';
              },
            ),
            SizedBox(height: 30),
            TextFormField(
              obscureText: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '******',
                labelText: 'Contrasena',
                prefixIcon: Icons.lock_outline,
              ),
              onChanged: (value) => loginForm.email = value,
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La Contrasena debe ser mayor a 6 caracteres';
              },
            ),
            SizedBox(height: 30),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.deepPurple,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 15,
                ),
                child: Text(
                  loginForm.isLoading ? 'Iniciando Sesion...' : 'Ingresar:',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      if (!loginForm.isValidForm()) return;
                      loginForm.isLoading = true;
                      await Future.delayed(Duration(seconds: 3));
                      loginForm.isLoading = false;
                      Navigator.pushReplacementNamed(context, 'home');
                    },
            ),
          ],
        ),
      ),
    );
  }
}
