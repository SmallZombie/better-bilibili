import 'base_config.dart';

class AccountConfig extends BaseConfig<AccountConfigData> {
  bool _initialized = false;

  AccountConfig()
    : super(
        fileName: 'account.json',
        data: AccountConfigData(
          // 默认需要有一个空白账户，因为即使在未登录情况下，仍然需要存储 wbi 和 buvid 等信息
          accounts: [AccountData(uid: '0')],
          currentAccountId: '0',
        ),
      );

  @override
  AccountConfigData fromJson(Map<String, dynamic> json) {
    return AccountConfigData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(AccountConfigData data) {
    return data.toJson();
  }

  /// 读取或创建默认配置到内存
  Future<void> ensureInitialized() async {
    if (_initialized) return;

    await load();
    _initialized = true;
  }

  /// 获取当前账号
  AccountData getCurrentAccount() {
    try {
      return findAccountByUid(data.currentAccountId);
    } catch (_) {}

    // 如果找不到账号就返回空账号，这里还要额外确保空账号存在
    try {
      return findAccountByUid('0');
    } catch (e) {
      final account = addAccount(AccountData(uid: '0'));

      // 这里故意不等保存完
      save();

      return account;
    }
  }

  /// 添加账号
  AccountData addAccount(AccountData account) {
    // 检查是否已存在
    if (data.accounts.any((a) => a.uid == account.uid)) {
      throw ArgumentError('账号 ID 已存在: ${account.uid}');
    }

    data.accounts.add(account);

    return account;
  }

  /// 更新账号
  void updateAccount(AccountData account) {
    final index = data.accounts.indexWhere((a) => a.uid == account.uid);
    if (index == -1) {
      throw ArgumentError('账号不存在: ${account.uid}');
    }

    data.accounts[index] = account;
  }

  /// 删除账号
  void removeAccount(String accountId) {
    data.accounts.removeWhere((a) => a.uid == accountId);

    // 如果删除的是当前账号，清空当前账号
    if (data.currentAccountId == accountId) {
      data.currentAccountId = '0';
    }
  }

  /// 设置当前账号
  void setCurrentAccount(String accountId) {
    if (!data.accounts.any((a) => a.uid == accountId)) {
      throw ArgumentError('账号不存在: $accountId');
    }

    data.currentAccountId = accountId;
  }

  /// 尝试通过 UID 查找账号
  AccountData findAccountByUid(String uid) {
    return data.accounts.firstWhere((a) => a.uid == uid);
  }
}

class AccountConfigData {
  List<AccountData> accounts;
  String currentAccountId;

  AccountConfigData({required this.accounts, required this.currentAccountId});

  factory AccountConfigData.fromJson(Map<String, dynamic> json) {
    return AccountConfigData(
      accounts: (json['accounts'] as List<dynamic>?)?.map((e) => AccountData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      currentAccountId: json['currentAccountId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'accounts': accounts.map((e) => e.toJson()).toList(), 'currentAccountId': currentAccountId};
  }
}

class AccountData {
  String uid;
  String? nickname;
  String? avatar;
  String? accessToken;
  String? refreshToken;
  int? tokenExpiredAt;
  String? wbiImgKey;
  String? wbiSubKey;
  String? dedeUserID;
  String? dedeUserIdCkMd5;
  String? sid;
  String? biliJct;
  String? buvid3;
  String? buvid4;
  String? biliTicket;
  int? biliTicketExpiredAt;
  String? uuid;
  String? buvidFp;
  // int? level;
  // String? vipIcon;
  // double? coin;
  // double? bcoin;
  // int? dynamicCount;
  // int? followCount;
  // int? fansCount;
  String? userAgent;
  int? windowWidth;
  int? windowHeight;

  AccountData({
    required this.uid,
    this.nickname,
    this.avatar,
    this.accessToken,
    this.tokenExpiredAt,
    this.refreshToken,
    this.dedeUserID,
    this.dedeUserIdCkMd5,
    this.sid,
    this.wbiImgKey,
    this.wbiSubKey,
    this.biliJct,
    this.buvid3,
    this.buvid4,
    this.biliTicket,
    this.biliTicketExpiredAt,
    this.uuid,
    this.buvidFp,
    // this.level,
    // this.vipIcon,
    // this.coin,
    // this.bcoin,
    // this.dynamicCount,
    // this.followCount,
    // this.fansCount,
    this.userAgent,
    this.windowWidth,
    this.windowHeight,
  });

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      accessToken: json['accessToken'] as String?,
      tokenExpiredAt: json['tokenExpiredAt'] as int?,
      refreshToken: json['refreshToken'] as String?,
      dedeUserID: json['dedeUserID'] as String?,
      dedeUserIdCkMd5: json['dedeUserIdCkMd5'] as String?,
      sid: json['sid'] as String?,
      wbiImgKey: json['wbiImgKey'] as String?,
      wbiSubKey: json['wbiSubKey'] as String?,
      biliJct: json['biliJct'] as String?,
      buvid3: json['buvid3'] as String?,
      buvid4: json['buvid4'] as String?,
      biliTicket: json['biliTicket'] as String?,
      biliTicketExpiredAt: json['biliTicketExpiredAt'] as int?,
      uuid: json['uuid'] as String?,
      buvidFp: json['buvidFp'] as String?,
      // level: json['level'] as int?,
      // vipIcon: json['vipIcon'] as String?,
      // coin: json['coin'] as double?,
      // bcoin: json['bcoin'] as double?,
      // dynamicCount: json['dynamicCount'] as int?,
      // followCount: json['followCount'] as int?,
      // fansCount: json['fansCount'] as int?,
      userAgent: json['userAgent'] as String?,
      windowWidth: json['windowWidth'] as int?,
      windowHeight: json['windowHeight'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'avatar': avatar,
      'accessToken': accessToken,
      'tokenExpiredAt': tokenExpiredAt,
      'refreshToken': refreshToken,
      'dedeUserID': dedeUserID,
      'dedeUserIdCkMd5': dedeUserIdCkMd5,
      'sid': sid,
      'wbiImgKey': wbiImgKey,
      'wbiSubKey': wbiSubKey,
      'biliJct': biliJct,
      'buvid3': buvid3,
      'buvid4': buvid4,
      'biliTicket': biliTicket,
      'biliTicketExpiredAt': biliTicketExpiredAt,
      'uuid': uuid,
      'buvidFp': buvidFp,
      // 'level': level,
      // 'vipIcon': vipIcon,
      // 'coin': coin,
      // 'bcoin': bcoin,
      // 'dynamicCount': dynamicCount,
      // 'followCount': followCount,
      // 'fansCount': fansCount,
      'userAgent': userAgent,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
    };
  }

  /// 合并另一个 AccountData 对象，新值会覆盖旧值（null 值不会覆盖）
  void mergeWith(AccountData other) {
    if (other.nickname != null) nickname = other.nickname;
    if (other.avatar != null) avatar = other.avatar;
    if (other.accessToken != null) accessToken = other.accessToken;
    if (other.tokenExpiredAt != null) tokenExpiredAt = other.tokenExpiredAt;
    if (other.refreshToken != null) refreshToken = other.refreshToken;
    if (other.wbiImgKey != null) wbiImgKey = other.wbiImgKey;
    if (other.wbiSubKey != null) wbiSubKey = other.wbiSubKey;
    if (other.dedeUserID != null) dedeUserID = other.dedeUserID;
    if (other.dedeUserIdCkMd5 != null) dedeUserIdCkMd5 = other.dedeUserIdCkMd5;
    if (other.sid != null) sid = other.sid;
    if (other.biliJct != null) biliJct = other.biliJct;
    if (other.buvid3 != null) buvid3 = other.buvid3;
    if (other.buvid4 != null) buvid4 = other.buvid4;
    if (other.biliTicket != null) biliTicket = other.biliTicket;
    if (other.biliTicketExpiredAt != null) biliTicketExpiredAt = other.biliTicketExpiredAt;
    if (other.uuid != null) uuid = other.uuid;
    if (other.buvidFp != null) buvidFp = other.buvidFp;
    // if (other.level != null) level = other.level;
    // if (other.vipIcon != null) vipIcon = other.vipIcon;
    // if (other.coin != null) coin = other.coin;
    // if (other.bcoin != null) bcoin = other.bcoin;
    // if (other.dynamicCount != null) dynamicCount = other.dynamicCount;
    // if (other.followCount != null) followCount = other.followCount;
    // if (other.fansCount != null) fansCount = other.fansCount;
    if (other.userAgent != null) userAgent = other.userAgent;
    if (other.windowWidth != null) windowWidth = other.windowWidth;
    if (other.windowHeight != null) windowHeight = other.windowHeight;
  }
}
