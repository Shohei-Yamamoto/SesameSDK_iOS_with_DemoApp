# CHResult pattern
1. [https://developer.apple.com/documentation/swift/result](https://developer.apple.com/documentation/swift/result)
2. [https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/)
3. typealias CHResult<T> = (Result<CHResultState<T>, Error >) ->  ()

## CHResultState
1. CHResultStateCache: Values from coredata(iOS database / Android Database)
2. CHResultStateNetworks: Values from networks
3. CHResultStateBLE: Values from BLE
4. [todo] CHResultStateIoT: Values from WiFi Access Point

## NSError table
1. [HTTP status codes](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
2. [Apple CBManagerState](https://developer.apple.com/documentation/corebluetooth/cbmanagerstate)

| Error type | Domain | Code | Message | 説明 |推薦文言|ユーザーの対処方法|
|:----------:|:------:|:----:|:-------:|:---:|:---:|:---:|
| Internet |  SesameSDK  |  -1009 |The Internet connection appears to be offline ||通信環境が悪いため、情報を取得できません。しばらく時間をおいてから、再度お試しください。|ユーザーが通信環境を確認し、再度試す。|
| Internet |  SesameSDK  |  403   | Forbidden | No API key |サーバーとの接続に失敗しました。|アプリUI側の実装上の問題やSDK/サーバー不具合。ユーザーでは解決できない。|
| Internet |  SesameSDK  |  400   | Bad request | Wrong Server API parameter <br> (CANDY HOUSE内部問題) |サーバーとの接続に失敗しました。|SDK/サーバー不具合。ユーザーでは解決できない。|
| Internet |  SesameSDK  |  404   | Not found | Wrong URL <br> (CANDY HOUSE内部問題) |サーバーとの接続に失敗しました。|SDK/サーバー不具合。ユーザーでは解決できない。|
| Internet |  SesameSDK  |  502   | Unknown error | CANDY HOUSE server is probably down <br> (CANDY HOUSE内部問題) |サーバーとの接続に失敗しました。しばらく時間をおいてもう一度お試しください。|CANDY HOUSEサーバーで障害発生中。しばらくたってから再度試してもらう。|
| Data |  SesameSDK  |  401 | History authentication failed | 捏造された履歴をサーバーに送ろうとしてる時のエラー |エラーが発生しました。|ユーザーでは解決できない。|
| Data |  SesameSDK  |  480 | PARSE_ERROR | History data parsing failed <br> (CANDY HOUSE内部問題) |エラーが発生しました。|リトライしても発生する場合は、SDK/サーバー不具合。ユーザーでは解決できない。|
| Data |  SesameSDK  |  600 | History tag is longer than 21-byte limit ||エラーが発生しました。|アプリUIの実装の問題。 ユーザーでは解決できない。|
| BLE command <br> (unlogin) | CBCentralManager |  4  | PoweredOff| Bluetooth of this iOS/Android device is off |スマートフォンのBluetoothがOFFになっています。BluetoothをONにしてから再度お試しください。|BluetoothをONにしてから再度試してもらう。|
| BLE command <br> (unlogin) | CBCentralManager |  3  | Unauthorized| This app is not authorised to use Bluetooth by this iOS/Android device |Bluetoothを利用する権限ありません。スマートフォンの「設定」から許可してください。|スマホの設定からアプリにBluetoothの権限が付与されているか確認する。|
| BLE command <br> (unlogin) | CBCentralManager |  2  | Unsupported| This iOS/Android device is not compatible with Bluetooth 4.0 or later |お使いのスマートフォンではBluetooth4.0に対応しておりません。他のスマートフォンをご利用ください。|BLE4.0以上に非対応のスマートフォンで利用しているため、別機種で利用してもらう。|
| BLE command <br> (unlogin) | SesameSDK |  -2 | No BLE signal| セサミデバイスのBluetooth信号が見つからない |セサミデバイスが見つかりません。セサミデバイスに青いランプが点滅していることを確認し、セサミデバイスの近くで再度お試しください。|セサミロック本体のLEDを確認してもらう。点滅しない場合、電池を入れ替える。|
| BLE command <br> (login) |  SesameSDK  |  -1 | Sesame BLE unlogin| セサミデバイスの鍵を未だセサミデバイスに挿入していない |エラーとしてはユーザに見せずにアプリでBLEの接続を試みる。|アプリUI側の実装上の問題。|
| BLE command <br> (login) |  SesameSDK  |  1  | Invalid Format||エラーが発生しました。|SDK不具合。ユーザーでは解決できない。|
| BLE command <br> (login) |  SesameSDK  |  2  | notSupported|そのデバイスが対応していないコマンド|お使いのスマートロックでは本機能はご利用いただけません。||
| BLE command <br> (login) |  SesameSDK  |  3  | resultStorageFail||||
| BLE command <br> (login) |  SesameSDK  |  4  | invalidSig||||
| BLE command <br> (login) |  SesameSDK  |  5  | notFound||||
| BLE command <br> (login) |  SesameSDK  |  6  | unknown| |||
| BLE command <br> (login) |  SesameSDK  |  7  | busy| |||
| BLE command <br> (login) |  SesameSDK  |  8  | invalid Param| |||


| Type of BLE command | items | 説明 |
|:-------------------:|:-----:|:---:|
| BLE command <br> (login)  | lock(), unlock(), toggle(), <br> configureLockPosition(), getAutolockSetting(), enableAutolock(), disableAutolock(), updateFirmware(), updateBleAdvParameter(),<br> disconnect(), resetSesame(),  |セサミデバイスの鍵が必要のBLEコマンド|
| BLE command <br> (unlogin) |  connect(), registerSesame2(), updateFirmware() |セサミデバイスの鍵が不要のBLEコマンド|


# example

## iOS
```swift
sesame2.toggle { result in
    switch result {
       case .success(let chResultState):
           L.d("CHResultState" , chResultState,chResultState.data)
           //["CHResultState", SesameSDK.CHResultStateBLE<SesameSDK.CHEmpty>, SesameSDK.CHEmpty]
       case .failure(let error):
           L.d("error",error)
       }
}
```
## Android
``` kotlin
sesame2.toggle() {
    it.onSuccess {

    }
    it.onFailure {
       L.d ("message" + it)
       L.d("code t" + (it as NSError).code)
       L.d("domaon!!!!!:" + (it as NSError).domaon)
       toastMSG(it.message)
    }
}
```
