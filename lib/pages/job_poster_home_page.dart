import 'package:flutter/material.dart';
import 'package:quick_hire/global_variables.dart';

class JobPosterHomePage extends StatelessWidget {
  const JobPosterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        toolbarHeight: 130,
        title: Text(
          'Hello, Steve',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
            iconSize: 50,
            padding: EdgeInsets.all(10),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person),
            iconSize: 50,
            padding: EdgeInsets.all(10),
          ),
        ],
      ),

      // Body uses ListView for scrolling
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color.fromRGBO(225, 225, 225, 1)),
              ),
              hintText: 'Search jobs',
              hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              prefixIcon: Icon(Icons.search, size: 35),
            ),
          ),

          SizedBox(height: 30),

          // Categories Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applications',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Job Cards (Vertical ListView)
          ListView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final job = jobs[index];

              //cards
              return Card(
                margin: EdgeInsets.only(bottom: 15),
                child: SizedBox(
                  height: 80,
                  child: ListTile(
                    leading: Image.asset(
                      job['imageUrl'] as String,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      job['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      job['company'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text("MKW${job['price']}"),
                  ),
                ),
              );
            },
          ),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(0, 45, 114, 1.0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Post a Job',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
