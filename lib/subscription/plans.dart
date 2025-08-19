import 'package:flutter/material.dart';
import 'package:medcare/subscription/payment.dart';


class VIPPlansPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VIP Plans", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color(0xFF5D56AF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanCard(
              context,
              title: "Plan 1",
              duration: "1 MONTH",
              price: "49.99 EGP /month",
              total: "49.99 EGP every month",
            ),
            SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: "Plan 2",
              duration: "3 MONTH",
              price: "39.99 EGP /month",
              total: "119.99 EGP every three month",
            ),
            SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: "Plan 3",
              duration: "6 MONTH",
              price: "29.99 EGP /month",
              total: "179.99 EGP every six month",
            ),
            SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: "Plan 4",
              duration: "12 MONTH",
              price: "24.99 EGP /month",
              total: "299.99 EGP every twelve month",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String duration,
    required String price,
    required String total,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(plan: title, price: price),
          ),
        );
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.tealAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Plan Label
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            // Plan Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  total,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
