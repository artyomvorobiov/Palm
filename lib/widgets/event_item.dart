// import 'package:flutter/material.dart';

// import '../screens/event_detail_screen.dart';

// class EventItem extends StatelessWidget {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String price;
//   final String address;
//   final String time;

//   EventItem(
//       {this.id,
//       this.title,
//       this.imageUrl,
//       this.address,
//       this.price,
//       this.time});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: GridTile(
//         child: GestureDetector(
//           onTap: () {
//             Navigator.of(context).pushNamed(
//               EventDetailScreen.routeName,
//               arguments: id,
//             );
//           },
//           child: Container(
//             decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor,
//                 borderRadius: BorderRadius.all(Radius.circular(20))),
//             width: 100,
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(15),
//                         topRight: Radius.circular(15),
//                       ),
//                       child: Hero(
//                         tag: id,
//                         child: FadeInImage(
//                           width: double.infinity,
//                           height: 127,
//                           fit: BoxFit.cover,
//                           placeholder: AssetImage(
//                               'assets/images/product-placeholder.png'),
//                           image: NetworkImage(
//                               "https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Dead-end_pylon_HVAC_S_2017_negative.jpg/1280px-Dead-end_pylon_HVAC_S_2017_negative.jpg"),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 10,
//                       left: 10,
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         width: 250,
//                         color: Colors.black54,
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: 26, color: Colors.white),
//                           softWrap: true,
//                           overflow: TextOverflow.fade,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.schedule,
//                               ),
//                               SizedBox(
//                                 width: 5,
//                               ),
//                               Text(
//                                 time.toString(),
//                                 style: TextStyle(fontSize: 18),
//                                 //  overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.monetization_on,
//                               ),
//                               SizedBox(
//                                 width: 5,
//                               ),
//                               Text(
//                                 price.toString(),
//                                 style: TextStyle(fontSize: 18),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         width: 350,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.place,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             Container(
//                               width: 250,
//                               child: Text(
//                                 address,
//                                 style: TextStyle(fontSize: 18),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
