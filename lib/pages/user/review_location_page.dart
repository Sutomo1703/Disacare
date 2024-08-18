import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UserLocationReviewPage extends StatefulWidget {
  final String locationName;
  final String? docId;
  const UserLocationReviewPage({super.key, required this.locationName, this.docId});

  @override
  State<UserLocationReviewPage> createState() => _UserLocationReviewPageState();
}

class _UserLocationReviewPageState extends State<UserLocationReviewPage> {
  late FirebaseFirestore _firestore;
  int selectedRating = 0;
  List<Color> buttonColors = List.filled(6, Colors.black);

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  bool isLiked(DocumentSnapshot review) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final likedBy = review['likedBy'];
    return likedBy != null && likedBy.contains(currentUserID);
  }

  bool isDisliked(DocumentSnapshot review) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final dislikedBy = review['dislikedBy'];
    return dislikedBy != null && dislikedBy.contains(currentUserID);
  }

  Future<void> toggleLike(DocumentSnapshot review) async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final likedBy = List<String>.from(review['likedBy'] ?? []);
    final dislikedBy = List<String>.from(review['dislikedBy'] ?? []);

    if (likedBy.contains(currentUserID)) {
      likedBy.remove(currentUserID);
    } else {
      likedBy.add(currentUserID);
      dislikedBy.remove(currentUserID);
    }

    final int likeCount = likedBy.length;
    final int dislikeCount = dislikedBy.length;

    await _firestore
        .collection('lokasi')
        .doc(widget.docId)
        .collection('review')
        .doc(review.id)
        .set({
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
    }, SetOptions(merge: true));
  }

  Future<void> toggleDislike(DocumentSnapshot review) async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final likedBy = List<String>.from(review['likedBy'] ?? []);
    final dislikedBy = List<String>.from(review['dislikedBy'] ?? []);

    if (dislikedBy.contains(currentUserID)) {
      dislikedBy.remove(currentUserID);
    } else {
      dislikedBy.add(currentUserID);
      likedBy.remove(currentUserID);
    }

    final int likeCount = likedBy.length;
    final int dislikeCount = dislikedBy.length;

    await _firestore
        .collection('lokasi')
        .doc(widget.docId)
        .collection('review')
        .doc(review.id)
        .set({
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
    }, SetOptions(merge: true));
  }

  // Filter reviews based on selected rating
  List<DocumentSnapshot> filterReviewsByRating(List<DocumentSnapshot> reviews) {
    if (selectedRating == 0) {
      return reviews;
    } else {
      return reviews
          .where((review) => review['rating'] == selectedRating)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.locationName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // All
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 0;
                            buttonColors = List.filled(6, Colors.black);
                            buttonColors[0] = Colors.blue;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[0];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Semua',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      // 5 Star
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 5;
                            for (int i = 0; i < 6; i++) {
                              buttonColors[i] =
                                  i == 5 ? Colors.blue : Colors.black;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[5];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      //4 Star
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 4;
                            for (int i = 0; i < 6; i++) {
                              buttonColors[i] =
                                  i == 4 ? Colors.blue : Colors.black;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[4];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '4',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      // 3 Star
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 3;
                            for (int i = 0; i < 6; i++) {
                              buttonColors[i] =
                                  i == 3 ? Colors.blue : Colors.black;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[3];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      // 2 Star
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 2;
                            for (int i = 0; i < 6; i++) {
                              buttonColors[i] =
                                  i == 2 ? Colors.blue : Colors.black;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[2];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      // 1 Star
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 1;
                            for (int i = 0; i < 6; i++) {
                              buttonColors[i] =
                                  i == 1 ? Colors.blue : Colors.black;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return buttonColors[1];
                            },
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('lokasi')
                    .doc(widget.docId)
                    .collection('review')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Review untuk lokasi ini kosong, silahkan post review',
                            style: TextStyle(fontSize: 15),
                          ),
                        );
                      }
                      // Filter reviews based on selected rating
                      final filteredReviews =
                          filterReviewsByRating(snapshot.data!.docs);
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredReviews.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          var review = filteredReviews[index];
                          final Map<String, dynamic>? reviewData =
                              review.data() as Map<String, dynamic>?;
                          if (reviewData == null ||
                              !reviewData.containsKey('likedBy')) {
                            review.reference.update({'likedBy': []});
                          }
                          if (reviewData == null ||
                              !reviewData.containsKey('dislikedBy')) {
                            review.reference.update({'dislikedBy': []});
                          }

                          // Get vote counts
                          final likeCount = reviewData?['likeCount'] ?? 0;
                          final dislikeCount = reviewData?['dislikeCount'] ?? 0;

                          return ListTile(
                            title: Text(
                              review['username'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Rating: ${review['rating']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      RatingBarIndicator(
                                        rating: review['rating'].toDouble(),
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 15),
                                  child: Text(
                                    review['review_content'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                review['picture'] != null
                                    ? Image.network(
                                        review['picture'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up_outlined),
                                      onPressed: () {
                                        toggleLike(review);
                                      },
                                      color:
                                          isLiked(review) ? Colors.blue : null,
                                    ),
                                    Text(
                                      likeCount.toString(),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.thumb_down_outlined),
                                      onPressed: () {
                                        toggleDislike(review);
                                      },
                                      color: isDisliked(review)
                                          ? Colors.blue
                                          : null,
                                    ),
                                    Text(
                                      dislikeCount.toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
