//
//  RegisterDeviceListViewModel.swift
//  SesameUI
//
//  Created by YuHan Hsiao on 2020/6/22.
//  Copyright © 2020 CandyHouse. All rights reserved.
//

import Foundation
import SesameSDK

public protocol RegisterDeviceListViewModelDelegate: class {
    func registerSesame2Succeed()
}

public final class RegisterDeviceListViewModel: ViewModel {
    enum Action {
        case dfu
    }

    private var sesame2s: [CHSesame2] = [] {
        didSet {
            sesame2s.first?.connect(){_ in}
//            for sesame in sesame2s {
//                sesame.connect(){_ in}
//            }
        }
    }
    
    private var dfuHelper: DFUHelper?
    
    public private(set) var emptyMessage = "co.candyhouse.sesame-sdk-test-app.NoNewDevices".localized
    public private(set) var backButtonImage = "icons_filled_close"
    private(set) var mySesameText = "ドラえもん".localized
    private(set) var dfuActionText = "co.candyhouse.sesame-sdk-test-app.Start".localized
    
    public var statusUpdated: ViewStatusHandler?
    public var delegate: RegisterDeviceListViewModelDelegate?
    
    public init() {
        CHBLEDelegatesManager.shared.addObserver(self)
    }
    
    public var numberOfRows: Int {
        sesame2s.count
    }
    
    public func registerCellModelForRow(_ row: Int) -> RegisterCellModel {
        RegisterCellModel(sesame2: sesame2s[row])
    }
    
    public func didSelectCellAtRow(_ row: Int) {
        let sesame2 = sesame2s[row]
        sesame2.connect(){_ in}
        
        switch sesame2.deviceStatus {
        case .readytoRegister:
            registerSesame2(sesame2)
            statusUpdated?(.loading)
        case .dfumode:
            statusUpdated?(.update(Action.dfu))
        default:
            sesame2.delegate = self
            statusUpdated?(.loading)
        }
    }
    
    private func registerSesame2(_ sesame2: CHSesame2) {

        sesame2.registerSesame2( { result in
            switch result {

            case .success(_):
                defer {
                    self.statusUpdated?(.update(nil))
                    self.delegate?.registerSesame2Succeed()
                }
                
                L.d("註冊成功", "configureLockPosition")
                
                Sesame2Store.shared.deletePropertyAndHisotryForDevice(sesame2)
                
                guard let encodedHistoryTag = self.mySesameText.data(using: .utf8) else {
                    assertionFailure("Encode historyTag failed")
                    return
                }
                
                L.d("註冊成功", "setHistoryTag", self.mySesameText)
                
                sesame2.setHistoryTag(encodedHistoryTag) { result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        self.statusUpdated?(.finished(.failure(error)))
                    }
                }
                
                sesame2.configureLockPosition(lockTarget: 0, unlockTarget: 256){ result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        self.statusUpdated?(.finished(.failure(error)))
                    }
                }
                
            case .failure(let error):
                L.d(error.errorDescription())
                self.statusUpdated?(.finished(.failure(error)))
            }
        })
    }
    
    func dfuFileName() -> String? {
        guard let filePath = Constant
            .resourceBundle
            .url(forResource: nil,
                 withExtension: ".zip") else {
                return nil
        }
        return filePath.lastPathComponent
    }
    
    func dfuDeviceAtIndexPath(_ indexPath: IndexPath, observer: DFUHelperObserver) {
        let sesame2 = sesame2s[indexPath.row]
        guard let filePath = Constant
            .resourceBundle
            .url(forResource: nil,
                 withExtension: ".zip"),
            let zipData = try? Data(contentsOf: filePath) else {
                return
        }
        
        sesame2.updateFirmware { result in
            switch result {
            case .success(let peripheral):
                guard let peripheral = peripheral.data else {
                    L.d("Request commad failed.")
                    return
                }
                L.d("Success.")
                self.dfuHelper = CHDFUHelper(peripheral: peripheral, zipData: zipData)
                self.dfuHelper?.observer = observer
                self.dfuHelper?.start()
            case .failure(let error):
                L.d(error.errorDescription())
                self.statusUpdated?(.finished(.failure(error)))
            }
        }
    }
    
    func cancelDFU() {
        dfuHelper?.abort()
        dfuHelper = nil
    }
    
    func viewDidDisappear() {
        cancelDFU()
    }
    
    deinit {
        CHBLEDelegatesManager.shared.removeObserver(self)
    }
}

extension RegisterDeviceListViewModel: CHBleManagerDelegate {

    public func didDiscoverUnRegisteredSesame2s(sesame2s: [CHSesame2]) {
        self.sesame2s = sesame2s.sorted(by: {
            return $0.rssi!.intValue > $1.rssi!.intValue
        })
        statusUpdated?(.update(nil))
    }
}

extension RegisterDeviceListViewModel: CHSesame2Delegate {
    public func onBleDeviceStatusChanged(device: CHSesame2, status: CHSesame2Status) {
        if status == .readytoRegister {
            registerSesame2(device)
        }
    }
}
