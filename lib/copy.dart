import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfr_golf2/fb/fb_orga_info.dart';

import 'package:tfr_golf2/model/constant.dart';
import 'package:tfr_golf2/model/util.dart';
import 'package:tfr_golf2/auth/auth_check.dart';
import 'package:tfr_golf2/fb/fb_client_info.dart';
import 'package:tfr_golf2/fb/fb_store_info.dart';
import 'package:tfr_golf2/fb/fb_price_info.dart';
import 'package:tfr_golf2/fb/fb_staff_info.dart';
import 'package:tfr_golf2/view/client_edit_view.dart';
import 'package:tfr_golf2/view/client_list_custom_preview.dart';
import 'package:tfr_golf2/widget/circl_widget.dart';
import 'package:tfr_golf2/widget/custom_button_widget.dart';
import 'package:tfr_golf2/widget/vertical_scroll_widget.dart';

// 会員一覧画面
class ClientListView extends ConsumerStatefulWidget {
  ClientListView({Key? key}) : super(key: key);

  @override
  _ClientListView createState() => _ClientListView();
}

class _ClientListView extends ConsumerState<ClientListView> {
  late Size _screenSize;

  // クライアント(会員)情報リスト
  List<FbClientInfo> _clientList = [];
  List<FbClientInfo> _clientList_filter = [];
  List<String> _myStoreDocIDList = [];

  // 自身の従業員情報
  late FbStaffInfo _myStaffItem;

  // 店舗情報リスト
  List<FbStoreInfo> _storeList = [];

  // 選択料金プラン情報リスト
  List<FbPriceInfo> _priceList = [];

  bool _firstFlag_Client = true;
  bool _firstFlag_Store = true;
  bool _firstFlag_Price = true;
  StreamSubscription<QuerySnapshot<Object?>>? _subsc_Client;
  StreamSubscription<QuerySnapshot<Object?>>? _subsc_Store;
  StreamSubscription<QuerySnapshot<Object?>>? _subsc_Price;

  late _ClientDataSource _clientDs;
  DataGridController _gridController = DataGridController();

  List<_GridColmnInfo> _gridColumnList = [];
  // List<_GridColmnInfo> _gridColumnList = [
  //   _GridColmnInfo('edit', '編集', 70),
  //   _GridColmnInfo('fullName', '名前', 180),
  //   _GridColmnInfo('fullNameKana', 'ふりがな', 180),
  //   _GridColmnInfo('storeName', '所属店舗', 180),
  //   _GridColmnInfo('courseName', 'コース', 180),
  //   _GridColmnInfo('accountType', 'アカウント', 120),
  //   _GridColmnInfo('phoneNo', '電話番号', 140),
  //   _GridColmnInfo('birthday', '生年月日', 140),
  //   _GridColmnInfo('age', '年齢', 80),
  //   _GridColmnInfo('sex', '性別', 80),
  //   _GridColmnInfo('email', 'メールアドレス', 260),
  //   _GridColmnInfo('joinDt', '入会日', 140),
  //   _GridColmnInfo('freeTorialDt', '体験入会日', 140),
  //   _GridColmnInfo('entryAt', '作成日', 140),
  // ];

  // 項目名ドロップダウンリスト
  List<DropdownMenuItem<_GridColmnInfo>> _gridMenuList = [];

  late _GridColmnInfo _selGridMenu;

  // フィルタ条件リスト(名前、ふりがな、電話番号、メールアドレス)
  List<_FilterTypeInfo> _filterTypeList1 = [
    _FilterTypeInfo('= (等しい)', FilterType.equals),
    _FilterTypeInfo('≠ (等しくない)', FilterType.notEqual),
    _FilterTypeInfo('次のキーワードを含む', FilterType.contains),
    _FilterTypeInfo('次のキーワードを含まない', FilterType.doesNotContain),
  ];

  // フィルタ条件リスト(所属店舗、コース、アカウント、性別)
  List<_FilterTypeInfo> _filterTypeList2 = [
    _FilterTypeInfo('次のいずれかを含む', FilterType.contains),
    _FilterTypeInfo('次のいずれも含まない', FilterType.doesNotContain),
  ];

  // フィルタ条件リスト(生年月日、入会日、体験入会日、作成日)
  List<_FilterTypeInfo> _filterTypeList3 = [
    _FilterTypeInfo('= (等しい)', FilterType.equals),
    _FilterTypeInfo('≠ (等しくない)', FilterType.notEqual),
    _FilterTypeInfo('≦ (以前)', FilterType.lessThanOrEqual),
    _FilterTypeInfo('< (より前)', FilterType.lessThan),
    _FilterTypeInfo('≧ (以降)', FilterType.greaterThanOrEqual),
    _FilterTypeInfo('> (より後)', FilterType.greaterThan),
  ];

  // フィルタ条件リスト(年齢)
  List<_FilterTypeInfo> _filterTypeList4 = [
    _FilterTypeInfo('= (等しい)', FilterType.equals),
    _FilterTypeInfo('≠ (等しくない)', FilterType.notEqual),
    _FilterTypeInfo('≦ (以下)', FilterType.lessThanOrEqual),
    _FilterTypeInfo('< (より下)', FilterType.lessThan),
    _FilterTypeInfo('≧ (以上)', FilterType.greaterThanOrEqual),
    _FilterTypeInfo('> (より上)', FilterType.greaterThan),
  ];

  // フィルタ条件ドロップダウンリスト
  List<DropdownMenuItem<_FilterTypeInfo>> _filterMenuList = [];

  late _FilterTypeInfo _selFilterMenu;

  String _filterValue = '';

  late FbOrgaInfo _orgaItem;

  bool _isClearButtonOn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _gridColumnList = [
      _GridColmnInfo('edit', '編集', 70, []),
      _GridColmnInfo('fullName', '名前', 180, _filterTypeList1),
      _GridColmnInfo('fullNameKana', 'ふりがな', 180, _filterTypeList1),
      _GridColmnInfo('storeName', '所属店舗', 180, _filterTypeList2),
      _GridColmnInfo('courseName', 'コース', 180, _filterTypeList2),
      _GridColmnInfo('accountType', 'アカウント', 120, _filterTypeList2),
      _GridColmnInfo('phoneNo', '電話番号', 140, _filterTypeList1),
      _GridColmnInfo('birthday', '生年月日', 140, _filterTypeList3),
      _GridColmnInfo('age', '年齢', 80, _filterTypeList4),
      _GridColmnInfo('sex', '性別', 80, _filterTypeList2),
      _GridColmnInfo('email', 'メールアドレス', 260, _filterTypeList1),
      _GridColmnInfo('joinDt', '入会日', 140, _filterTypeList3),
      _GridColmnInfo('freeTorialDt', '体験入会日', 140, _filterTypeList3),
      _GridColmnInfo('entryAt', '作成日', 140, _filterTypeList3),
    ];

    // 自身の従業員情報取得
    _myStaffItem = FbStaffInfo.getMyStaffItem();

    // クライアント情報リスト取得(ストリーム)
    _subsc_Client = FbClientInfo.getStreamClientList().listen((queSnap) {
      // クライアント情報リスト変換
      _clientList = FbClientInfo.convSnapToClientList(queSnap);
      // 選択クライアント情報設定
      FbClientInfo.setSelClientList(_clientList);
      // _clientList_filter = _clientList;
      print('クライアント情報リスト取得：' + _clientList.length.toString());
      if (mounted) {
        setState(() {
          _firstFlag_Client = false;
        });
      }
    });

    // 店舗情報リスト取得(ストリーム)
    _subsc_Store = FbStoreInfo.getStreamStoreList().listen((queSnap) {
      // 店舗情報リスト変換
      _storeList = FbStoreInfo.convSnapToStoreList(queSnap);
      // アカウントが有効でフィルタする
      _storeList =
          _storeList.where((element) => element.accountFlag != false).toList();

      // 選択店舗情報リスト設定
      // FbStoreInfo.setSelStoreList(_storeList);
      FbStoreInfo.setSelStoreList_filter(_storeList);

      print('店舗情報リスト取得：' + _storeList.length.toString());

      if (_myStaffItem.areaItem != null) {
        // 管理者以外の場合は、所属するエリアの店舗DocIDリストを生成する
        _myStoreDocIDList.clear();
        for (var storeItem in _storeList) {
          if (storeItem.areaDocID == _myStaffItem.areaItem!.areaDocID) {
            _myStoreDocIDList.add(storeItem.storeDocID);
          }
        }
      }

      if (mounted) {
        setState(() {
          _firstFlag_Store = false;
        });
      }
    });

    // 料金プラン情報リスト取得(ストリーム)
    _subsc_Price = FbPriceInfo.getStreamPriceList().listen((queSnap) {
      // 料金プラン情報リスト変換
      _priceList = FbPriceInfo.convSnapToPriceList(queSnap);
      // 選択料金プラン情報リスト設定
      FbPriceInfo.setSelPriceList(_priceList);

      print('料金プラン情報リスト取得：' + _priceList.length.toString());
      if (mounted) {
        setState(() {
          _firstFlag_Price = false;
        });
      }
    });

    // 項目名ドロップダウンリスト
    _gridMenuList = _gridColumnList.map((item) {
      return DropdownMenuItem<_GridColmnInfo>(
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Text(
            item.labelName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        value: item,
      );
    }).toList();

    _gridMenuList.removeAt(0);
    _selGridMenu = _gridColumnList[1];

    // フィルタ条件ドロップダウンリスト
    _filterMenuList = _filterTypeList1.map((item) {
      return DropdownMenuItem<_FilterTypeInfo>(
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Text(
            item.filterName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        value: item,
      );
    }).toList();

    _selFilterMenu = _filterTypeList1.first;
  }

  @override
  void dispose() {
    _subsc_Client?.cancel();
    _subsc_Store?.cancel();
    _subsc_Price?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得する
    _screenSize = MediaQuery.of(context).size;

    // 認証チェック
    if (checkAuth_Manage() == false) {
      // くるくる表示
      return circlFlrexWidget();
    }

    // 管理者の場合
    if (_myStaffItem.permType == PermType.Manager.val) {
      _clientList_filter = []..addAll(_clientList);
    }
    // 管理者以外の場合
    else {
      _clientList_filter = _clientList
          .where(
              (element) => _myStoreDocIDList.contains(element.partStoreDocID))
          .toList();
    }

    // 表示・非表示反映
    _orgaItem = FbOrgaInfo.getSelOrgaItem();
    _gridColumnList = _gridColumnList.map((gridColumn) {
      if (_orgaItem.clientViewColumnShowMap[gridColumn.columnName]!) {
        return gridColumn;
      } else {
        // 非表示は幅0
        return gridColumn..width = 0;
      }
    }).toList();

    return Container(
      padding: EdgeInsets.all(10),
      child: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    if (_firstFlag_Client != false ||
        _firstFlag_Store != false ||
        _firstFlag_Price != false) {
      // くるくる表示
      return circlFlrexWidget();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '会員一覧',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            CustomButtonWidget(
              title: '表示列の設定',
              iconData: Icons.remove_red_eye_outlined,
              onTap: () async {
                ClientListCustomPreview.goScreen(context);
              },
            ),
            SizedBox(width: 30,),
            CustomButtonWidget(
              title: '条件を絞り込む',
              iconData: Icons.filter_alt_outlined,
              onTap: () async {
                bool result = await _filterDialog(context);
                if (result) {
                  _clientDs.addFilter(
                    _selGridMenu.columnName,
                    FilterCondition(
                      type: _selFilterMenu.filterType,
                      value: _filterValue,
                      filterBehavior: FilterBehavior.stringDataType,
                    ),
                  );
                  _isClearButtonOn = true;
                }
              },
            ),
            SizedBox(width: 10,),
            CustomButtonWidget(
              title: '条件のクリア',
              color: _isClearButtonOn ? g_buttonColor : g_buttonColor5,
              onTap: () {
                _clientDs.clearFilters();
                _isClearButtonOn = false;
              },
            ),
            Spacer(),
            CustomButtonWidget(
              title: 'CSVファイル出力',
              onTap: () {
                // 選択クライアント情報設定
                FbClientInfo.setSelClientItem(FbClientInfo());

                ClientEditView.goScreen(context);
              },
            ),
            Visibility(
              visible: g_DebugFlag == g_DebugFlag_ON,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CustomButtonWidget(
                  title: '会員追加',
                  iconData: Icons.add,
                  onTap: () {
                    // 選択クライアント情報設定
                    FbClientInfo.setSelClientItem(FbClientInfo());

                    ClientEditView.goScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        // Visibility(
        //   visible: g_DebugFlag == g_DebugFlag_ON,
        //   child: Column(
        //     children: [
        //       Align(
        //         alignment: Alignment.centerRight,
        //         child: CustomButtonWidget(
        //           title: '会員追加',
        //           iconData: Icons.add,
        //           onTap: () {
        //             // 選択クライアント情報設定
        //             FbClientInfo.setSelClientItem(FbClientInfo());
        //
        //             ClientEditView.goScreen(context);
        //           },
        //         ),
        //         // child: ElevatedButton.icon(
        //         //   icon: Icon(Icons.add),
        //         //   label: Text('会員追加'),
        //         //   onPressed: () {
        //         //     // 選択クライアント情報設定
        //         //     FbClientInfo.setSelClientItem(FbClientInfo());
        //         //
        //         //     ClientEditView.goScreen(context);
        //         //   },
        //         // ),
        //       ),
        //       SizedBox(
        //         height: 10,
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: _gridWidget(),
        ),
      ],
    );
  }

  // グリッド表示
  Widget _gridWidget() {
    _clientDs = _ClientDataSource(_clientList_filter, context, ref);
    _clientDs.updateDataGridSource();

    return Container(
      color: Colors.white,
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          // headerColor: g_backColor,
          headerColor: g_backColor2,
        ),
        child: SfDataGrid(
          controller: _gridController,
          source: _clientDs,
          selectionMode: SelectionMode.single,
          headerGridLinesVisibility: GridLinesVisibility.both,
          gridLinesVisibility: GridLinesVisibility.both,
          isScrollbarAlwaysShown: true,
          navigationMode: GridNavigationMode.row,
          columnWidthMode: ColumnWidthMode.auto,
          frozenColumnsCount: 5,
          // footerFrozenRowsCount: 1,
          allowSorting: true,
          headerRowHeight: 30,
          rowHeight: 30,
          // allowColumnsResizing: true, // 列のリサイジングを許可する
          onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
            _GridColmnInfo? colItem = _gridColumnList.firstWhereOrNull(
                    (element) => element.columnName == details.column.columnName);
            if (colItem != null) {
              colItem.width = details.width;
              setState(() {
                // _gridColumnList[details.column.columnName].width = details.width;
              });
            }
            return true;
          },
          columns: _gridColumnList.map((colItem) {
            return GridColumn(
              columnName: colItem.columnName,
              width: colItem.width,
              allowEditing: false,
              allowSorting: colItem.columnName == 'edit' ? false : true,
              label: Container(
                // padding: EdgeInsets.symmetric(horizontal: 4.0),
                alignment: Alignment.center,
                // color: Colors.grey,
                child: Text(
                  colItem.labelName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 絞り込みダイアログ表示
  Future<bool> _filterDialog(BuildContext context) async {
    _GridColmnInfo gridMenu = _selGridMenu;
    _FilterTypeInfo filterMenu = _selFilterMenu;
    String filterValue = _filterValue;

    bool? result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('会員一覧表示のフィルタ'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return VerticalScrollWidget(
                  childWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('条件'),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                              ),
                              child: DropdownButton<_GridColmnInfo>(
                                key: UniqueKey(),
                                icon: Icon(Icons.expand_more),
                                items: _gridMenuList,
                                value: gridMenu,
                                dropdownColor: Colors.white,
                                underline: Container(),
                                isExpanded: true,
                                style: TextStyle(fontSize: 20, color: g_textColor),
                                onChanged: (val) async {
                                  if (val == null) {
                                    return;
                                  }

                                  gridMenu = val;
                                  // setState(() {});
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                              ),
                              child: DropdownButton<_FilterTypeInfo>(
                                key: UniqueKey(),
                                icon: Icon(Icons.expand_more),
                                items: _filterMenuList,
                                value: filterMenu,
                                dropdownColor: Colors.white,
                                underline: Container(),
                                isExpanded: true,
                                style: TextStyle(fontSize: 20, color: g_textColor),
                                onChanged: (val) async {
                                  if (val == null) {
                                    return;
                                  }

                                  filterMenu = val;
                                  // setState(() {});
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              width: 200,
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 20,
                                  color: g_textColor2,
                                ),
                                initialValue: filterValue,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  filterValue = val;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );},
            ),
            actions: <Widget>[
              CustomButtonWidget(
                title: 'キャンセル',
                onTap: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CustomButtonWidget(
                title: '適用',
                color: g_buttonColor4,
                onTap: () {
                  _selGridMenu = gridMenu;
                  _selFilterMenu = filterMenu;
                  _filterValue = filterValue;
                  Navigator.of(context).pop(true);
                },
              ),
              SizedBox(width: 10,)
            ],
          );
        }
    );
    if (result == null) {
      return Future.value(false);
    } else {
      return Future.value(result);
    }
  }

}

class _GridColmnInfo {
  String columnName;
  String labelName;
  double width;
  List<_FilterTypeInfo> filterList;
  _GridColmnInfo(this.columnName, this.labelName, this.width, this.filterList);
}

class _FilterTypeInfo {
  String filterName;
  FilterType filterType;
  _FilterTypeInfo(this.filterName, this.filterType);
}

class _ClientDataSource extends DataGridSource {
  _ClientDataSource(
      List<FbClientInfo> clientList,
      BuildContext context,
      WidgetRef ref_set,
      ) {
    _clientList = clientList;
    _context = context;
    _ref = ref_set;
    // 選択店舗情報リスト取得
    // _storeList = FbStoreInfo.getSelStoreList();
    _storeList = FbStoreInfo.getSelStoreList_filter();

    // 選択料金プラン報リスト取得
    _priceList = FbPriceInfo.getSelPriceList();

    buildDataGridRows();
  }

  List<FbClientInfo> _clientList = [];
  late BuildContext _context;
  late WidgetRef _ref;
  List<FbStoreInfo> _storeList = [];

  // 料金プラン情報リスト
  static List<FbPriceInfo> _priceList = [];

  void buildDataGridRows() {
    dataGridRows = _clientList.map<DataGridRow>((dataGridRow) {
      var storeItem = _storeList.firstWhereOrNull(
              (element) => element.storeDocID == dataGridRow.partStoreDocID);
      String storeName = storeItem == null ? '' : storeItem.storeName;

      String courseName = '';
      dataGridRow.clientPlanList.forEach((planItem) {
        var priceItem = _priceList.firstWhereOrNull(
                (element) => element.priceDocID == planItem.pricePlanDocID);
        if (priceItem != null) {
          if (courseName != '') {
            courseName += ', ';
          }
          courseName += priceItem.courseName;
        }
      });

      DataGridRow retDataGridRow = DataGridRow(
        cells: [
          DataGridCell<FbClientInfo>(
            columnName: 'edit',
            value: dataGridRow,
          ),
          DataGridCell<String>(
            columnName: 'fullName',
            value: dataGridRow.getFullName(),
          ),
          DataGridCell<String>(
            columnName: 'fullNameKana',
            value: dataGridRow.getFullNameKana(),
          ),
          DataGridCell<String>(
            columnName: 'storeName',
            value: storeName,
          ),
          DataGridCell<String>(
            columnName: 'courseName',
            value: courseName,
          ),
          DataGridCell<String>(
            columnName: 'accountType',
            value: dataGridRow.getAccountTypeText(),
          ),
          DataGridCell<String>(
            columnName: 'phoneNo',
            value: dataGridRow.phoneNo,
          ),
          DataGridCell<String>(
            columnName: 'birthday',
            value: Util.dateToText2(dataGridRow.birthday),
          ),
          DataGridCell<String>(
            columnName: 'age',
            value: dataGridRow.getAgeText(),
          ),
          DataGridCell<String>(
            columnName: 'sex',
            value: dataGridRow.sex,
          ),
          DataGridCell<String>(
            columnName: 'email',
            value: dataGridRow.email,
          ),
          DataGridCell<String>(
            columnName: 'joinDt',
            value: Util.dateToText2(dataGridRow.joinDt),
          ),
          DataGridCell<String>(
            columnName: 'freeTorialDt',
            value: Util.dateToText2(dataGridRow.freeTorialDt),
          ),
          DataGridCell<String>(
            columnName: 'entryAt',
            value: Util.dateToText2(dataGridRow.entryAt),
          ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'fullName',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'fullNameKana',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'storeName',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'courseName',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'accountType',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'joinDt',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'freeTorialDt',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'birthday',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'age',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'sex',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'phoneNo',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'email',
          //   value: dataGridRow,
          // ),
          // DataGridCell<FbClientInfo>(
          //   columnName: 'entryAt',
          //   value: dataGridRow,
          // ),
        ],
      );

      return retDataGridRow;
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (a == null || b == null) {
      return 0;
    }

    String colName = sortColumn.name;
    // FbClientInfo clientItemA = a
    //     .getCells()
    //     .firstWhereOrNull((element) => element.columnName == sortColumn.name)
    //     ?.value;
    // FbClientInfo clientItemB = b
    //     .getCells()
    //     .firstWhereOrNull((element) => element.columnName == sortColumn.name)
    //     ?.value;
    String clientItemA = a
        .getCells()
        .firstWhereOrNull((element) => element.columnName == sortColumn.name)
        ?.value;
    String clientItemB = b
        .getCells()
        .firstWhereOrNull((element) => element.columnName == sortColumn.name)
        ?.value;

    int retVal = 0;
    DateTime clientA_Dt;
    DateTime clientB_Dt;
    final formatter = DateFormat('yyyy年M月d日');

    if (colName == 'freeTorialDt'
        || colName == 'birthday'
        || colName == 'joinDt'
        || colName == 'entryAt' ) {
      clientA_Dt = clientItemA == '' ? DateTime(1900) : formatter.parse(clientItemA);
      clientB_Dt = clientItemB == '' ? DateTime(1900) : formatter.parse(clientItemB);
      retVal = clientA_Dt.compareTo(clientB_Dt);
    } else {
      retVal = clientItemA.compareTo(clientItemB);
    }

    // if (colName == 'fullName') {
    //   retVal = clientItemA.getFullName().compareTo(clientItemB.getFullName());
    // } else if (colName == 'fullNameKana') {
    //   retVal = clientItemA
    //       .getFullNameKana()
    //       .compareTo(clientItemB.getFullNameKana());
    // } else if (colName == 'storeName') {
    //   var storeItemA = _storeList.firstWhereOrNull(
    //       (element) => element.storeDocID == clientItemA.partStoreDocID);
    //   var storeItemB = _storeList.firstWhereOrNull(
    //       (element) => element.storeDocID == clientItemB.partStoreDocID);
    //   String storeNameA = storeItemA == null ? '' : storeItemA.storeName;
    //   String storeNameB = storeItemB == null ? '' : storeItemB.storeName;
    //   retVal = storeNameA.compareTo(storeNameB);
    // } else if (colName == 'courseName') {
    //   // var priceItemA = _priceList.firstWhereOrNull(
    //   //     (element) => element.priceDocID == clientItemA.pricePlanDocID);
    //   // var priceItemB = _priceList.firstWhereOrNull(
    //   //     (element) => element.priceDocID == clientItemB.pricePlanDocID);
    //   // String courseNameA = priceItemA == null ? '' : priceItemA.courseName;
    //   // String courseNameB = priceItemB == null ? '' : priceItemB.courseName;
    //   // retVal = courseNameA.compareTo(courseNameB);
    //   String courseNameA = '';
    //   clientItemA.clientPlanList.forEach((planItem) {
    //     var priceItemA = _priceList.firstWhereOrNull(
    //         (element) => element.priceDocID == planItem.pricePlanDocID);
    //     if (priceItemA != null) {
    //       if (courseNameA != '') {
    //         courseNameA += ', ';
    //       }
    //       courseNameA += priceItemA.courseName;
    //     }
    //   });
    //   String courseNameB = '';
    //   clientItemB.clientPlanList.forEach((planItem) {
    //     var priceItemB = _priceList.firstWhereOrNull(
    //         (element) => element.priceDocID == planItem.pricePlanDocID);
    //     if (priceItemB != null) {
    //       if (courseNameA != '') {
    //         courseNameB += ', ';
    //       }
    //       courseNameB += priceItemB.courseName;
    //     }
    //   });
    //   retVal = courseNameA.compareTo(courseNameB);
    // } else if (colName == 'email') {
    //   retVal = clientItemA.email.compareTo(clientItemB.email);
    // } else if (colName == 'accountType') {
    //   retVal = clientItemA
    //       .getAccountTypeText()
    //       .compareTo(clientItemB.getAccountTypeText());
    // } else if (colName == 'joinDt') {
    //   clientA_Dt =
    //       clientItemA.joinDt != null ? clientItemA.joinDt! : DateTime(1900);
    //   clientB_Dt =
    //       clientItemB.joinDt != null ? clientItemB.joinDt! : DateTime(1900);
    //   retVal = clientA_Dt.compareTo(clientB_Dt);
    // } else if (colName == 'freeTorialDt') {
    //   clientA_Dt = clientItemA.freeTorialDt != null
    //       ? clientItemA.freeTorialDt!
    //       : DateTime(1900);
    //   clientB_Dt = clientItemB.freeTorialDt != null
    //       ? clientItemB.freeTorialDt!
    //       : DateTime(1900);
    //   retVal = clientA_Dt.compareTo(clientB_Dt);
    // } else if (colName == 'birthday') {
    //   clientA_Dt =
    //       clientItemA.birthday != null ? clientItemA.birthday! : DateTime(1900);
    //   clientB_Dt =
    //       clientItemB.birthday != null ? clientItemB.birthday! : DateTime(1900);
    //   retVal = clientA_Dt.compareTo(clientB_Dt);
    // } else if (colName == 'age') {
    //   retVal = clientItemA
    //       .getAgeForBirthday()
    //       .compareTo(clientItemB.getAgeForBirthday());
    // } else if (colName == 'sex') {
    //   retVal = clientItemA.sex.compareTo(clientItemB.sex);
    // } else if (colName == 'phoneNo') {
    //   retVal = clientItemA.phoneNo.compareTo(clientItemB.phoneNo);
    // } else if (colName == 'entryAt') {
    //   retVal = clientItemA.entryAt.compareTo(clientItemB.entryAt);
    // }

    if (retVal > 0) {
      retVal =
      sortColumn.sortDirection == DataGridSortDirection.ascending ? 1 : -1;
    } else if (retVal == -1) {
      retVal =
      sortColumn.sortDirection == DataGridSortDirection.ascending ? -1 : 1;
    }

    return retVal;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    Color? backColor;
    bool lastLineFlag = false;

    return DataGridRowAdapter(
        color: backColor,
        cells: row.getCells().map<Widget>((dataGridCell) {
          Color? textColor;

          AlignmentGeometry alignment = Alignment.centerLeft;
          EdgeInsetsGeometry pad = EdgeInsets.symmetric(horizontal: 4.0);
          // if (dataGridCell.columnName == 'fullName' ||
          //     dataGridCell.columnName == 'fullNameKana' ||
          //     dataGridCell.columnName == 'storeName' ||
          //     dataGridCell.columnName == 'courseName' ||
          //     dataGridCell.columnName == 'email') {
          if (dataGridCell.columnName == 'accountType' ||
              dataGridCell.columnName == 'sex' ||
              dataGridCell.columnName == 'age') {
            alignment = Alignment.center;
            pad = EdgeInsets.symmetric(horizontal: 16);
          }

          // テキスト値取得
          String valText = dataGridCell.value.toString();
          // String valText = _getValText(dataGridCell.columnName, clientItem);

          if (dataGridCell.columnName == 'edit') {
            FbClientInfo clientItem = dataGridCell.value;
            return IconButton(
              icon: Icon(
                Icons.edit,
                size: 16,
              ),
              onPressed: () async {
                // 選択クライアント情報設定
                FbClientInfo.setSelClientItem(clientItem);

                // クライアント編集画面に遷移する
                ClientEditView.goScreen(_context);
              },
            );
          } else {
            return Container(
              alignment: alignment,
              padding: pad,
              child: Text(
                valText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // fontSize: 12,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            );
          }
        }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  // テキスト値取得
  String _getValText(String colName, FbClientInfo clientItem) {
    String valText = '';

    if (colName == 'fullName') {
      valText = clientItem.getFullName();
    } else if (colName == 'fullNameKana') {
      valText = clientItem.getFullNameKana();
    } else if (colName == 'storeName') {
      var storeItem = _storeList.firstWhereOrNull(
              (element) => element.storeDocID == clientItem.partStoreDocID);
      valText = storeItem == null ? '' : storeItem.storeName;
    } else if (colName == 'courseName') {
      // var priceItem = _priceList.firstWhereOrNull(
      //     (element) => element.priceDocID == clientItem.pricePlanDocID);
      // valText = priceItem == null ? '' : priceItem.courseName;
      clientItem.clientPlanList.forEach((planItem) {
        var priceItem = _priceList.firstWhereOrNull(
                (element) => element.priceDocID == planItem.pricePlanDocID);
        if (priceItem != null) {
          if (valText != '') {
            valText += ', ';
          }
          valText += priceItem.courseName;
        }
      });
    } else if (colName == 'email') {
      valText = clientItem.email;
    } else if (colName == 'accountType') {
      valText = clientItem.getAccountTypeText();
    } else if (colName == 'joinDt') {
      valText = Util.dateToText2(clientItem.joinDt);
    } else if (colName == 'freeTorialDt') {
      valText = Util.dateToText2(clientItem.freeTorialDt);
    } else if (colName == 'birthday') {
      valText = Util.dateToText2(clientItem.birthday);
    } else if (colName == 'age') {
      valText = clientItem.getAgeText();
    } else if (colName == 'sex') {
      valText = clientItem.sex;
    } else if (colName == 'phoneNo') {
      valText = clientItem.phoneNo;
    } else if (colName == 'entryAt') {
      valText = Util.dateToText2(clientItem.entryAt);
    }

    return valText;
  }
}
