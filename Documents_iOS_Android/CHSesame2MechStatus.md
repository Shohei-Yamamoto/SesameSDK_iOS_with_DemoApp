## iOS
```Swift
public protocol CHSesame2MechStatus {

    func getBatteryVoltage() -> Float
    //電池の電圧の取得、単位: 0V ~ 7.2V

    func getBatteryPrecentage() -> Int
    
    var position:Int16{ get }
    //セサミのリアルタイムの角度。範圍： -32767~0~32767 ; -32768 は意義のない的デフォルト值。 例0˚ ⇄ 0 で 360˚ ⇄ 1024 

    var isInLockRange : Bool{ get }
    //施錠範囲であるか否か　の判断   
    
    var isInUnlockRange : Bool { get }
    //解錠範囲であるか否か　の判断

}
```
## Android
```Kotlin
class CHSesame2MechStatus(data: ByteArray) {

    fun getBatteryVoltage(): Float
    
    fun getBatteryPrecentage(): Int 
    
    val position:Short

    var isInLockRange:Boolean
    
    var isInUnlockRange:Boolean
}

```
