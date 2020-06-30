//
//  GeneralTabViewCoordinator.swift
//  SesameUI
//
//  Created by YuHan Hsiao on 2020/6/18.
//  Copyright © 2020 CandyHouse. All rights reserved.
//

import UIKit

public class GeneralTabViewCoordinator: Coordinator {
    public var childCoordinators: [String: Coordinator] = [:]
    public weak var presentedViewController: UIViewController?
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let bluetoothListCoordinator = BluetoothDevicesListCoordinator(navigationViewController: UINavigationController())
        bluetoothListCoordinator.start()
        
        let friendsViewControllerCoordinator = FriendsViewControllerCoordinator(navigationController: UINavigationController())
        friendsViewControllerCoordinator.start()
        
        let meViewCoordinator = MeViewCoordinator(navigationController: UINavigationController())
        meViewCoordinator.start()
        
        guard let entryViewController = UIStoryboard.viewControllers.generalTabViewController,
            let deviceListViewController = bluetoothListCoordinator.presentedViewController,
            let friendListViewController = friendsViewControllerCoordinator.presentedViewController,
            let meViewController = meViewCoordinator.presentedViewController else {
                return
        }
        
        let deviceListItem = UITabBarItem(title: "Sesame".localStr,
                                          image: UIImage.SVGImage(named:"keychain_original"),
                                          selectedImage: UIImage.SVGImage(named:"keychain_tint"))
        
        let contactItem = UITabBarItem(title: "Contacts".localStr,
                                       image: UIImage.SVGImage(named:"icons_outlined_contacts",fillColor: UIColor.gray),
                                       selectedImage: UIImage.SVGImage(named:"icons_filled_contacts",fillColor: .sesameGreen))
        
        let meItem = UITabBarItem(title: "Me".localStr,
                                  image: UIImage.SVGImage(named:"icons_outlined_me",fillColor: UIColor.gray),
                                  selectedImage: UIImage.SVGImage(named:"icons_filled_official-accounts",fillColor: .sesameGreen))
        
        
        deviceListViewController.tabBarItem = deviceListItem
        friendListViewController.tabBarItem = contactItem
        meViewController.tabBarItem = meItem

        entryViewController.setViewControllers([bluetoothListCoordinator.navigationController,
                                                friendsViewControllerCoordinator.navigationController,
                                                meViewCoordinator.navigationController],
                                               animated: false)
        
        navigationController.pushViewController(entryViewController, animated: false)
        presentedViewController = entryViewController
    }
}
