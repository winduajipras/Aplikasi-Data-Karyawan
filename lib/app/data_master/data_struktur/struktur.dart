import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graphite/core/matrix.dart';
import 'package:graphite/core/typings.dart';
import 'package:graphite/graphite.dart';
import 'package:jia/app/data_master/data_karyawan/master_data_karyawan.dart';
import 'package:jia/app/data_master/data_struktur/add_struktur.dart';
import 'package:jia/app/data_master/data_struktur/edit_struktur.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:network_state/network_state.dart';

class Struktur extends StatefulWidget {
  @override
  _StrukturState createState() => _StrukturState();
}

class _StrukturState extends State<Struktur> {
  List<Color> _colors = [Colors.purple[300], Colors.deepOrange[300]];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var presetComplex = '[{"id":"Jatinom Indah Group","next":[]}]';
  List<NodeInput> list = [];
  List<Map<String, String>> track = [];
  List<String> nodeEdit = [];
  List<String> nodeRemove = [];
  String _selected = 'search';

  Map<String, bool> selected = {};
  Map<String, bool> firstLoad = {};
  Map<String, DocumentReference> ref = {};

  void _onItemSelected(MatrixNode node) {
    selected[node.id] =
        selected[node.id] == null || !selected[node.id] ? true : false;

    int index = list.indexWhere((element) => element.id.startsWith(node.id));
    if (selected[node.id]) {
      // add
      if (firstLoad[node.id] == null || firstLoad[node.id] == false) {
        FirebaseFirestore.instance
            .collection('struktur')
            .where('parent', isEqualTo: node.id.replaceAll("\n", "\\n"))
            .get()
            .then(
          (snapshot) {
            List<DocumentSnapshot> query = [];
            List<String> nodes = [];

            query = snapshot.docs;
            query.sort((a, b) => a.get('nama').compareTo(b.get('nama')));

            for (var element in query) {
              ref[element.get('jabatan') + '\n\n' + element.get('nama')] =
                  element.reference;
              list.add(NodeInput(
                  id: element.get('jabatan') + '\n\n' + element.get('nama'),
                  next: []));
              nodes.add(element.get('jabatan') + '\n\n' + element.get('nama'));
              bool check = false;
              for (var t in track) {
                if (t.values.first ==
                    element.get('jabatan') + '\n\n' + element.get('nama')) {
                  check = true;
                }
              }
              if (!check) {
                track.add({
                  node.id: element.get('jabatan') + '\n\n' + element.get('nama')
                });
              }
            }
            nodeEdit.forEach((n) {
              track.removeWhere((element) =>
                  element.values.first.contains(n) ||
                  element.keys.first.contains(n));
            });
            nodeRemove.forEach((n) {
              track.removeWhere((element) => element.values.first.contains(n));
            });
            list[index] = NodeInput(id: node.id, next: nodes);
            setState(() {});
            firstLoad[node.id] = true;
          },
        );
      } else {
        List<String> nodes = [];
        for (var i in track) {
          if (i.keys.first == node.id) {
            nodes.add(i.values.first);
            list.add(NodeInput(id: i.values.first, next: []));
          }
        }
        list[index] = NodeInput(id: node.id, next: nodes);
      }
    } else {
      // remove
      list[index] = NodeInput(id: node.id, next: []);
      List<String> targetRemoveAll = [];
      for (var i in track) {
        if (i.keys.first == node.id) {
          List<String> targetRemove = [i.values.first];
          for (var j in list) {
            if (targetRemove.contains(j.id)) {
              targetRemove.addAll(j.next);
              list[list.indexWhere((element) => element.id.startsWith(j.id))] =
                  NodeInput(id: j.id, next: []);
            }
          }
          targetRemoveAll.addAll(targetRemove);
        }
      }
      list.removeWhere((element) => targetRemoveAll.contains(element.id));
      for (var k in selected.keys) {
        if (targetRemoveAll.contains(k)) {
          selected[k] = false;
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    list = nodeInputFromJson(presetComplex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideBar(
        page: 'struktur',
      ),
      bottomNavigationBar: new BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        color: Colors.deepOrange,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
            Expanded(
              child: SizedBox(),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                _selected = 'search';
              }),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                _selected = 'add';
              }),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                _selected = 'edit';
              }),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                _selected = 'delete';
              }),
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Struktur'),
      ),
      body: DirectGraph(
        list: list,
        cellWidth: 180.0,
        cellPadding: 14.0,
        contactEdgesDistance: 5.0,
        orientation: MatrixOrientation.Vertical,
        pathBuilder: customEdgePathBuilder,
        builder: (ctx, node) {
          return Stack(
            children: [
              Card(
                elevation: selected[node.id] ?? false ? 25.0 : 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      node.id,
                      textAlign: TextAlign.center,
                      style: selected[node.id] ?? false
                          ? TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow)
                          : TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
              _selected == 'search'
                  ? node.id.lastIndexOf("\n") < 5
                      ? Container()
                      : ElevatedButton.icon(
                          icon: Icon(Icons.person_search),
                          label: Text('Search'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => DataKaryawan(
                                    nama: node.id.substring(
                                        node.id.lastIndexOf("\n") + 1)),
                              ),
                            );
                          },
                        )
                  : _selected == 'add'
                      ? ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add'),
                          onPressed: () {
                            firstLoad[node.id] = false;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => AddStruktur(
                                  parent: node.id.replaceAll('\n', '\\n'),
                                ),
                              ),
                            );
                          },
                        )
                      : _selected == 'edit'
                          ? ElevatedButton.icon(
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                              onPressed: () {
                                for (var f in track) {
                                  if (f.values.first == node.id) {
                                    firstLoad[f.keys.first] = false;
                                  }
                                }
                                FirebaseFirestore.instance
                                    .collection('struktur')
                                    .where('parent',
                                        isEqualTo:
                                            node.id.replaceAll('\n', '\\n'))
                                    .get()
                                    .then((parentSnapshot) async {
                                  var result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EditStruktur(
                                        nama: node.id.substring(
                                            node.id.lastIndexOf("\n") + 1),
                                        jabatan: node.id.substring(
                                            0, node.id.indexOf('\n')),
                                        ref: ref[node.id],
                                        parentSnapshot: parentSnapshot,
                                      ),
                                    ),
                                  );
                                  if (result != '##') {
                                    nodeEdit.add(result);
                                    dialog(context,
                                        'Data terupdate, mohon tutup dan buka kembali cabang diatasnya');
                                  }
                                });
                              },
                            )
                          : ElevatedButton.icon(
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String alertText =
                                        "Apakah anda yakin menghapus [" +
                                            node.id +
                                            "]";
                                    return AlertDialog(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.orange),
                                          Text(' Peringatan '),
                                          Icon(Icons.warning,
                                              color: Colors.orange),
                                        ],
                                      ),
                                      content: Text(alertText),
                                      actions: <Widget>[
                                        ElevatedButton(
                                            onPressed: () {
                                              NetworkConfig.pingUrls = [
                                                'https://mockbin.com/request'
                                              ];
                                              NetworkConfig.pollIntervalMs =
                                                  500;
                                              NetworkConfig.timeoutMs = 2000;

                                              NetworkState.startPolling();

                                              final ns = new NetworkState();
                                              bool key = false;
                                              ns.addListener(() async {
                                                final hasConnection = key
                                                    ? false
                                                    : await ns.isConnected;
                                                if (hasConnection) {
                                                  key = true;
                                                  FirebaseFirestore.instance
                                                      .runTransaction(
                                                          (transaction) async {
                                                    DocumentSnapshot snapshot =
                                                        await transaction
                                                            .get(ref[node.id]);
                                                    transaction.delete(
                                                        snapshot.reference);
                                                  });
                                                  for (var f in track) {
                                                    if (f.values.first ==
                                                        node.id) {
                                                      firstLoad[f.keys.first] =
                                                          false;
                                                    }
                                                  }
                                                  nodeRemove.add(node.id);
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 500),
                                                      () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                    dialog(context,
                                                        'Data terhapus, mohon tutup dan buka kembali cabang diatasnya');
                                                  });
                                                  NetworkState.stopPolling();
                                                }
                                                Future.delayed(
                                                    Duration(seconds: 6), () {
                                                  if (!key) {
                                                    key = true;
                                                    dialog(context,
                                                            'Periksa sambungan internet Anda')
                                                        .whenComplete(() {});
                                                    NetworkState.stopPolling();
                                                  }
                                                });
                                              });
                                            },
                                            child: const Text("Ya")),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text("Tidak"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
            ],
          );
        },
        paintBuilder: (edge) {
          var p = Paint()
            ..color = Colors.blueGrey
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 2;
          if ((selected[edge.from.id] ?? false) &&
              (selected[edge.to.id] ?? false)) {
            p.color = Colors.red;
          }
          return p;
        },
        onNodeTapDown: (_, node) {
          _onItemSelected(node);
        },
      ),
    );
  }
}

Path customEdgePathBuilder(List<List<double>> points) {
  var path = Path();
  path.moveTo(points[0][0], points[0][1]);
  points.sublist(1).forEach((p) {
    path.lineTo(p[0], p[1]);
  });
  return path;
}
