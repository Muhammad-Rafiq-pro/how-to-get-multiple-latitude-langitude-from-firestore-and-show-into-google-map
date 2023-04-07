import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:p_dos_user/screens/constant.dart';

class NameSearch extends StatefulWidget {
  @override
  State<NameSearch> createState() => _NameSearchState();
}

class _NameSearchState extends State<NameSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('excel').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return Center(child: Text('Loading...'));
            }
            if (snapshot.data!.size == 0) {
              return Center(child: Text('No data found.'));
            }
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            final filteredDocuments = documents.where(
              (doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['Name'] ??
                        data['name'] ??
                        data["Name (våldtäkt mot barn)"] ??
                        "")
                    .toString()
                    .toLowerCase();
                final address =
                    (data['Address'] ?? data['address'] ?? data['Adress'] ?? "")
                        .toString()
                        .toLowerCase();
                final category = (data['Category'] ??
                        data['category'] ??
                        data["Conviction "] ??
                        "")
                    .toString()
                    .toLowerCase();
                final searchText = _searchText.toLowerCase();
                return name.contains(searchText) ||
                    address.contains(searchText) ||
                    category.contains(searchText);
              },
            ).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                children: [
                  Container(
                    height: 43,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      cursorColor: appColor,
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 17,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchText = '';
                            });
                          },
                          child: Icon(
                            Icons.clear_sharp,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.10),
                        hintText: 'Search By Name, Address, or Category',
                        hintStyle: textFieldStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  filteredDocuments.isEmpty
                      ? Center(child: Text('No results found.'))
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredDocuments.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              final Map<String, dynamic>? data =
                                  (filteredDocuments[index].data())
                                      as Map<String, dynamic>?;
                              final name = (data?['Name'] ??
                                      data?['name'] ??
                                      data?["Name (våldtäkt mot barn)"] ??
                                      '')
                                  .toString();
                              final address = (data?['Address'] ??
                                      data?['address'] ??
                                      data?['Adress'] ??
                                      '')
                                  .toString();
                              final category = (data?['Category'] ??
                                      data?['category'] ??
                                      data?["Conviction "] ??
                                      '')
                                  .toString();
                              final isNameMatched = name
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              final isAddressMatched = address
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              final isCategoryMatched = category
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              // final isAnyFieldMatched = isNameMatched ||
                              //     isAddressMatched ||
                              //     isCategoryMatched;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Name:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        color: _searchText.isNotEmpty &&
                                                isNameMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          name
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 2,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Category:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: _searchText.isNotEmpty &&
                                                isCategoryMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          category
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 2,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Address:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        color: _searchText.isNotEmpty &&
                                                isAddressMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          address
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 5,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Divider(
                                    thickness: 2,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
