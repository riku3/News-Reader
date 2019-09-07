import UIKit
import PagingMenuController

class ListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)
        
        pagingMenuController.view.frame.origin.y += 50
        pagingMenuController.view.frame.size.height -= 50
        
        addChild(pagingMenuController)
        view.addSubview(pagingMenuController.view)
        pagingMenuController.didMove(toParent: self)
    }
}

private struct PagingMenuOptions: PagingMenuControllerCustomizable {
    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    fileprivate var pagingControllers: [UIViewController] {
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page1") as! PageMenuViewController1
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page2") as! PageMenuViewController2
        let vc3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page3") as! PageMenuViewController3
        return [vc1, vc2, vc3]
    }
    
    fileprivate struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .segmentedControl
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItem1(), MenuItem2(), MenuItem3()]
        }
        var focusMode: MenuFocusMode {
            return .underline(height: 4.0, color: UIColor.black, horizontalPadding: 0.0, verticalPadding: 0.0)
        }
    }
    
    fileprivate struct MenuItem1: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "First Menu"))
        }
    }
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Second Menu"))
        }
    }
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Third Menu"))
        }
    }
}
