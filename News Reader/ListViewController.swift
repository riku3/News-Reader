import UIKit
import Alamofire
import SDWebImage
import PagingMenuController

class ListViewController: UIViewController {
    
    static var articles1: Array<Article> = []
    static var articles2: Array<Article> = []
    static var articles3: Array<Article> = []
    
    struct Article:Codable {
        var title: String
        var link: String
        var site_name: String
        var image: String
        var pub_date: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("https://q0jxf9yhbi.execute-api.ap-northeast-1.amazonaws.com/prod/articles", method: .get).responseJSON { response in
            switch response.result {
               case .success:
                   let articles = try! JSONDecoder().decode([Article].self, from: response.data!)
                   for article in articles {
                    let siteName = article.site_name
                    if siteName.contains("山と溪谷社のクライミング") || siteName.contains("CLIMBERS") {
                        ListViewController.articles1.append(article)
                    } else if siteName.contains("Mickipedia") || siteName.contains("ALLEZ") {
                        ListViewController.articles2.append(article)
                    } else {
                        ListViewController.articles3.append(article)
                    }
                }
                   let options = PagingMenuOptions()
                   let pagingMenuController = PagingMenuController(options: options)
                   
                   pagingMenuController.view.frame.origin.y += 50
                   pagingMenuController.view.frame.size.height -= 50
                   
                   self.addChild(pagingMenuController)
                   self.view.addSubview(pagingMenuController.view)
                   pagingMenuController.didMove(toParent: self)
               case .failure:
                   return
            }
        }
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
            return .text(title: MenuItemText(text: "News"))
        }
    }
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Blog1"))
        }
    }
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Blog2"))
        }
    }
}
