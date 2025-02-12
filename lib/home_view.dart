import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment_flutter/urls.dart';
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  double amount = 500;
  Map<String, dynamic>? intentPaymentData;

  showPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet().then((val){
        intentPaymentData = null;
      }).onError((errorMsg, sTrace){
        print(errorMsg);
        print(sTrace);
      });
    }
    on StripeException catch (error){
      print(error);

      showDialog(context: context, builder: (context) {
       return const AlertDialog(
         content: Text('Cancelled'),
       );
      },);
    }
        catch(e)
    {
      print(e);
    }
  }

  makeIntentForPayment(amount, currency) async{
    try{
      Map<String, dynamic>? paymentInfo = {
        'amount' : (int.parse(amount) * 100 ).toString(),
        'currency': currency,
        'payment_method_types[]' : 'card',
      };

      var responseFromStripeApi = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
      body: paymentInfo,
        headers: {
        'Authorization' : 'Bearer $stripeSecretKey',
          'Content-Type' : 'application/x-www-form-urlencoded',
        }
      );
      print('Response: ${responseFromStripeApi.body.toString()}');
      return jsonDecode(responseFromStripeApi.body);

    }
        catch(e){
      print(e);
        }
  }

  paymentSheet(amount, currency) async{
    try{
      intentPaymentData =  await makeIntentForPayment(amount, currency);
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        allowsDelayedPaymentMethods: true,
        paymentIntentClientSecret: intentPaymentData!['client_secret'],
        style: ThemeMode.dark,
        merchantDisplayName: 'Usman'
      )).then((value){
        print(value);
      });

      showPaymentSheet();
    }
        catch(e){
      print(e);
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: (){
          paymentSheet(amount.round().toString(), 'PKR');
        }, child: Text('Press')),
      ),
    );
  }
}
