//
//  MainViewController.swift
//  inSparkle
//
//  Created by Trever on 11/16/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var toolbarCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var homeViewController : UIViewController!
    var messagesViewController : UIViewController!
    var pocViewController : UIViewController!
    var workOrdersViewController : UIViewController!
    var soiViewController : UIViewController!
    var adminViewController : UIViewController!
    var moreViewController : UIViewController!
    
    var viewControllers : [UIViewController]!
    
    var selectedIndex : Int = 0
    
    var selectionsToDisplay : [String] = ["Home"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "homeViewController")
        self.messagesViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "messagesNav")
        self.pocViewController = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "pocNav")
        self.workOrdersViewController = UIStoryboard(name: "WorkOrderMain", bundle: nil).instantiateViewController(withIdentifier: "woNav")
        self.soiViewController = UIStoryboard(name: "SOI", bundle: nil).instantiateViewController(withIdentifier: "soiNav")
        self.adminViewController = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "adminNav")
        self.moreViewController = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "moreNav")
        
        viewControllers = [homeViewController, messagesViewController, pocViewController, workOrdersViewController, soiViewController, adminViewController, moreViewController]
        
        self.toolbarCollectionView.delegate = self
        self.toolbarCollectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if EmployeeData.universalEmployee != nil {
            let userType = EmployeeData.universalEmployee.roleType
            let all = ["Home", "Messages", "POC", "Work Orders", "SOI", "Admin", "More"]
            do {
                try userType?.fetch()
                
                switch userType!.roleName {
                case "Service Admin":
                    self.selectionsToDisplay = all
                case "Sales Admin":
                    self.selectionsToDisplay = all
                case "Sales":
                    self.selectionsToDisplay = ["Home", "Messages", "POC", "Work Orders", "SOI", "More"]
                default:
                    break
                }
                
                self.toolbarCollectionView.performBatchUpdates({
                    let section = IndexSet(integer: 0)
                    self.toolbarCollectionView.reloadSections(section)
                }, completion: nil)
                
            } catch {
                
            }
            
            let homeIndex = IndexPath(item: 0, section: 0)
            self.toolbarCollectionView.selectItem(at: homeIndex, animated: true, scrollPosition: .bottom)
            homeViewController.view.frame = containerView.bounds
            homeViewController.view.contentMode = .redraw
            containerView.addSubview(homeViewController.view)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectionsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = toolbarCollectionView.dequeueReusableCell(withReuseIdentifier: "toolbarCell", for: indexPath) as! ToolbarCollectionViewCell
        var cellIcon = cell.toolbarCellIcon.image
        
        switch self.selectionsToDisplay[indexPath.row] {
        case "Home":
            cellIcon = UIImage(named: "HomeIcon")
            cell.backgroundColor = Colors.sparkleGreen
        case "Messages":
            cellIcon = UIImage(named: "MessagesIcon")
        case "POC":
            cellIcon = UIImage(named: "POCIcon")
        case "Work Orders":
            cellIcon = UIImage(named: "WorkOrdersIcon")
        case "SOI":
            cellIcon = UIImage(named: "SOIIcon")
        case "Admin":
            cellIcon = UIImage(named: "AdministratorIcon")
        case "More":
            cellIcon = UIImage(named: "MoreIcon")
        default:
            break
        }
        
        cell.tag = indexPath.item
        
        cell.toolbarCellIcon.image = cellIcon
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = toolbarCollectionView.cellForItem(at: indexPath)!
        let cells = toolbarCollectionView.visibleCells
        
        for cell in cells {
            if cell.backgroundColor != nil {
                cell.backgroundColor = nil
            }
        }
        
        let previousIndex = selectedIndex
        let previousVC = viewControllers[previousIndex]
        selectedIndex = cell.tag
        
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        let vc = viewControllers[selectedIndex]
        
        addChildViewController(vc)
        vc.view.frame = containerView.bounds
        vc.view.contentMode = .redraw
        containerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        
        cell.backgroundColor = Colors.sparkleGreen
        
    }
    
    
}
