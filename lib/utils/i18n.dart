import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static const _t = Translations.from('en_us', {
    "Two-Factor Authentication": {
      "en_us": "Two-Factor Authentication",
      "zh_cn": "二步验证",
      "zh_tw": "二步驗證",
      "ja_jp": "二要素認証"
    },
    "Scan QR Code": {"en_us": "Scan QR Code", "zh_cn": "扫描二维码", "zh_tw": "掃描二維碼", "ja_jp": "QR コードをスキャンする"},
    "Manual Input": {"en_us": "Manual Input", "zh_cn": "手动输入", "zh_tw": "手動輸入", "ja_jp": "手動入力"},
    "Parse URI": {"en_us": "Parse URI", "zh_cn": "解析 URI", "zh_tw": "解析 URI", "ja_jp": "URI の解析"},
    "Verify Your Identity": {
      "en_us": "Verify Your Identity",
      "zh_cn": "请验证您的身份信息",
      "zh_tw": "請驗證您的身份信息",
      "ja_jp": "身元情報を確認してください"
    },
    "Settings": {"en_us": "Settings", "zh_cn": "设置", "zh_tw": "設定", "ja_jp": "設定"},
    "Appearance": {"en_us": "Appearance", "zh_cn": "外观", "zh_tw": "外觀", "ja_jp": "外観"},
    "Dynamic Color": {"en_us": "Dynamic Color", "zh_cn": "动态取色", "zh_tw": "動態取色", "ja_jp": "ダイナミックカラー"},
    "Follow System Desktop for Theme Color": {
      "en_us": "Follow System Desktop for Theme Color",
      "zh_cn": "跟随系统桌面自动获取主题色",
      "zh_tw": "跟隨系統桌面自動獲取主題色",
      "ja_jp": "システムデスクトップのテーマカラーを自動的に追従"
    },
    "Select Color": {"en_us": "Select Color", "zh_cn": "选取颜色", "zh_tw": "選取顏色", "ja_jp": "色を選択"},
    "Manually Select a Color as Seed": {
      "en_us": "Manually Select a Color as Seed",
      "zh_cn": "手动选择一个色彩，这将作为种子被应用",
      "zh_tw": "手動選擇一個色彩，這將作為種子被應用",
      "ja_jp": "手動で色を選択し、これをシードとして適用する"
    },
    "Data": {"en_us": "Data", "zh_cn": "数据", "zh_tw": "資料", "ja_jp": "データ"},
    "Security Authentication": {
      "en_us": "Security Authentication",
      "zh_cn": "安全认证",
      "zh_tw": "安全認證",
      "ja_jp": "セキュリティ認証"
    },
    "Perform Security Verification on Startup": {
      "en_us": "Perform Security Verification on Startup",
      "zh_cn": "启动时进行安全验证",
      "zh_tw": "啟動時進行安全驗證",
      "ja_jp": "起動時にセキュリティ検証を実行する"
    },
    "System has not registered any authentication method": {
      "en_us": "System has not registered any authentication method",
      "zh_cn": "您的系统没有注册任何认证方式",
      "zh_tw": "您的系統沒有註冊任何認證方式",
      "ja_jp": "システムには認証方法が登録されていません"
    },
    "Backup and Restore": {"en_us": "Backup and Restore", "zh_cn": "备份和恢复", "zh_tw": "備份和還原", "ja_jp": "バックアップと復元"},
    "Data Cloud Backup to Reduce Risk of Accidental Loss": {
      "en_us": "Data Cloud Backup to Reduce Risk of Accidental Loss",
      "zh_cn": "数据上云，减少意外丢失风险",
      "zh_tw": "資料上雲，減少意外丟失風險",
      "ja_jp": "データのクラウドバックアップによる誤失のリスクの軽減"
    },
    "About": {"en_us": "About", "zh_cn": "关于", "zh_tw": "關於", "ja_jp": "について"},
    "Open Source License": {"en_us": "Open Source License", "zh_cn": "开源许可", "zh_tw": "開源許可", "ja_jp": "オープンソースライセンス"},
    "No Them, No Me": {
      "en_us": "No Them, No Me",
      "zh_cn": "没有他们就没有我 :)",
      "zh_tw": "沒有他們就沒有我 :)",
      "ja_jp": "彼らがいなければ、私はいない :)"
    },
    "Project Homepage": {"en_us": "Project Homepage", "zh_cn": "项目主页", "zh_tw": "專案主頁", "ja_jp": "プロジェクトホームページ"},
    "View Source Code and Buy Me a Coffee": {
      "en_us": "View Source Code and Buy Me a Coffee",
      "zh_cn": "来看看不知所云的源代码并且请我喝咖啡",
      "zh_tw": "來看看不知所云的源碼並且請我喝咖啡",
      "ja_jp": "わからないソースコードを見てみて、コーヒーをご馳走してください"
    },
    "Link access failed": {
      "en_us": "Link access failed",
      "zh_cn": "链接访问失败",
      "zh_tw": "連結訪問失敗",
      "ja_jp": "リンクのアクセスに失敗しました"
    },
    "Color picker": {"en_us": "Color picker", "zh_cn": "颜色选择器", "zh_tw": "顏色選擇器", "ja_jp": "カラーピッカー"},
    "Cancel": {"en_us": "Cancel", "zh_cn": "取消", "zh_tw": "取消", "ja_jp": "キャンセル"},
    "OK": {"en_us": "OK", "zh_cn": "确定", "zh_tw": "確定", "ja_jp": "OK"},
    "Account": {"en_us": "Account", "zh_cn": "帐户", "zh_tw": "帳戶", "ja_jp": "アカウント"},
    "Cloud Connection Type": {
      "en_us": "Cloud Connection Type",
      "zh_cn": "云连接类型",
      "zh_tw": "雲連接類型",
      "ja_jp": "クラウド接続タイプ"
    },
    "Current Storage Location": {
      "en_us": "Current Storage Location",
      "zh_cn": "当前存储于",
      "zh_tw": "目前存儲於",
      "ja_jp": "現在の保存場所"
    },
    "Current Usage": {"en_us": "Current Usage", "zh_cn": "当前使用", "zh_tw": "目前使用", "ja_jp": "現在の利用状況"},
    "Login Account": {"en_us": "Login Account", "zh_cn": "登录账户", "zh_tw": "登入帳戶", "ja_jp": "ログインアカウント"},
    "You may need a reliable network connection.": {
      "en_us": "You may need a reliable network connection.",
      "zh_cn": "可能需要你有可靠的网络条件。",
      "zh_tw": "可能需要你有可靠的網路條件。",
      "ja_jp": "可能需要你有可靠的ネットワーク条件。"
    },
    "Storage location": {"en_us": "Storage location", "zh_cn": "简体中文", "zh_tw": "繁体中文", "ja_jp": "日文"},
    "Current storage path": {"en_us": "Current storage path", "zh_cn": "当前存储路径", "zh_tw": "當前儲存路徑", "ja_jp": "現在の保存パス"},
    "Your data will be encrypted using RSA before being stored in the cloud. However, the corresponding public and private keys can be found in the source code of this application. Please be cautious and ensure proper backup of your data.":
        {
      "en_us":
          "Your data will be encrypted using RSA before being stored in the cloud. However, the corresponding public and private keys can be found in the source code of this application. Please be cautious and ensure proper backup of your data.",
      "zh_cn": "您的数据会经过 RSA 加密后存放在云端，但是其对应的公私钥均可以在本应用的源代码中找到，请自行注意保管妥当备份数据。",
      "zh_tw": "您的資料將會經過 RSA 加密後儲存在雲端，但是其對應的公私鑰均可以在本應用的源代碼中找到，請自行注意保管妥當備份資料。",
      "ja_jp":
          "お客様のデータは、RSA で暗号化された後、クラウドに保存されます。ただし、対応する公開鍵および秘密鍵は、このアプリケーションのソースコード中に見つけることができますので、データを適切にバックアップし、注意して保管してください。"
    },
    "Export Backup": {"en_us": "Export Backup", "zh_cn": "导出备份", "zh_tw": "匯出備份", "ja_jp": "バックアップのエクスポート"},
    "Local": {"en_us": "Local", "zh_cn": "本地", "zh_tw": "本地", "ja_jp": "ローカル"},
    "Currently backed up in": {
      "en_us": "Currently backed up in",
      "zh_cn": "目前备份于",
      "zh_tw": "目前備份於",
      "ja_jp": "現在のバックアップ場所"
    },
    "Import backup file": {
      "en_us": "Import backup file",
      "zh_cn": "导入备份文件",
      "zh_tw": "匯入備份檔案",
      "ja_jp": "バックアップファイルのインポート"
    },
    "Only supports exporting data from the application itself": {
      "en_us": "Only supports exporting data from the application itself",
      "zh_cn": "暂时只支持应用本身的导出数据",
      "zh_tw": "暫時只支援應用程式本身的匯出資料",
      "ja_jp": "現時点ではアプリケーション自体からのデータのエクスポートのみサポートされています"
    },
    "Cloud backup location": {
      "en_us": "Cloud backup location",
      "zh_cn": "云备份位置",
      "zh_tw": "雲端備份位置",
      "ja_jp": "クラウドバックアップの場所"
    },
    "Cloud backup account": {
      "en_us": "Cloud backup account",
      "zh_cn": "云备份账户",
      "zh_tw": "雲端備份帳戶",
      "ja_jp": "クラウドバックアップアカウント"
    },
    "Change account": {"en_us": "Change account", "zh_cn": "更换帐号", "zh_tw": "更換帳號", "ja_jp": "アカウントを変更する"},
    "Logout": {"en_us": "Logout", "zh_cn": "登出", "zh_tw": "登出", "ja_jp": "ログアウト"},
    "Third Party Disclaimer": {
      "en_us": "Third Party Disclaimer",
      "zh_cn": "第三方声明",
      "zh_tw": "第三方聲明",
      "ja_jp": "第三者の免責事項"
    },
    "Import from URI": {"en_us": "Import from URI", "zh_cn": "从 URI 导入", "zh_tw": "從 URI 匯入", "ja_jp": "URI からのインポート"},
    "URI Link": {"en_us": "URI Link", "zh_cn": "URI 链接", "zh_tw": "URI 連結", "ja_jp": "URI リンク"},
    "Import": {"en_us": "Import", "zh_cn": "导入", "zh_tw": "匯入", "ja_jp": "インポート"},
    "The URI link you imported does not contain valid data.": {
      "en_us": "The URI link you imported does not contain valid data.",
      "zh_cn": "您导入的 URI 链接不包含有效数据。",
      "zh_tw": "您匯入的 URI 連結不包含有效資料。",
      "ja_jp": "インポートした URI リンクには有効なデータが含まれていません。"
    },
    "Add New Item": {"en_us": "Add New Item", "zh_cn": "添加新条目", "zh_tw": "新增項目", "ja_jp": "新しい項目を追加する"},
    "Save": {"en_us": "Save", "zh_cn": "保存", "zh_tw": "儲存", "ja_jp": "保存"},
    "Name": {"en_us": "Name", "zh_cn": "名称", "zh_tw": "名稱", "ja_jp": "名前"},
    "Service Provider": {"en_us": "Service Provider", "zh_cn": "服务商", "zh_tw": "服務提供者", "ja_jp": "サービスプロバイダー"},
    "Access Key": {"en_us": "Access Key", "zh_cn": "密钥", "zh_tw": "金鑰", "ja_jp": "アクセスキー"},
    "Time Interval": {"en_us": "Time Interval", "zh_cn": "时间间隔", "zh_tw": "時間間隔", "ja_jp": "時間間隔"},
    "Counter": {"en_us": "Counter", "zh_cn": "计数器", "zh_tw": "計數器", "ja_jp": "カウンター"},
    "Digits": {"en_us": "Digits", "zh_cn": "位数", "zh_tw": "位數", "ja_jp": "桁数"},
    "Hash Function": {"en_us": "Hash Function", "zh_cn": "哈希函数", "zh_tw": "雜湊函數", "ja_jp": "ハッシュ関数"},
    "Name cannot be empty": {
      "en_us": "Name cannot be empty",
      "zh_cn": "名称不可为空",
      "zh_tw": "名稱不可為空",
      "ja_jp": "名称は空にできません"
    },
    "Access Key cannot be empty": {
      "en_us": "Access Key cannot be empty",
      "zh_cn": "密钥不能为空",
      "zh_tw": "金鑰不能為空",
      "ja_jp": "アクセスキーは空にできません"
    },
    "Access Key is not a valid Base32 encoding": {
      "en_us": "Access Key is not a valid Base32 encoding",
      "zh_cn": "密钥不是有效的 Base32 编码",
      "zh_tw": "金鑰不是有效的 Base32 編碼",
      "ja_jp": "アクセスキーは有効な Base32 エンコーディングではありません"
    },
    "Select Image": {"en_us": "Select Image", "zh_cn": "选取图像", "zh_tw": "選取圖像", "ja_jp": "画像を選択する"},
    "Switch Language": {"en_us": "Switch Language", "zh_cn": "切换语言", "zh_tw": "切換語言", "ja_jp": "言語を切り替える"},
    "The default setting is usually fine": {
      "en_us": "The default setting is usually fine",
      "zh_cn": "正常来说，默认就好",
      "zh_tw": "通常情況下，預設值就足夠了",
      "ja_jp": "通常、デフォルトの設定が適切です"
    }
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);
}
