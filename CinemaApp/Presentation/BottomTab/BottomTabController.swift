//
//  BottomTabController.swift
//  CinemaApp
//
//  Created by 박현렬 on 4/25/24.
//

import UIKit

class BottomTabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupViewControllers()
        UITabBar.appearance().tintColor = UIColor(named: "LabelTextColor")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupViewControllers() {
        // 첫 번째 탭 - MovieListViewController
        let movieListViewController = UIStoryboard(name: "MovieList", bundle: nil).instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
        let movieListTabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        movieListViewController.tabBarItem = movieListTabBarItem
        
        
        // 두 번째 탭 - SearchViewController
        let searchViewController = UIStoryboard(name: "SearchMovie", bundle: nil).instantiateViewController(withIdentifier: "SerachMovieViewController")
        let searchTabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))
        searchViewController.tabBarItem = searchTabBarItem
        
        // 두 번째 탭 - SearchViewController
        let movieMapViewController = UIStoryboard(name: "MovieMap", bundle: nil).instantiateViewController(withIdentifier: "MovieMapViewController")
        let movieMapTabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "location"), selectedImage: UIImage(systemName: "location.fill"))
        movieMapViewController.tabBarItem = movieMapTabBarItem
        
        // 네 번째 탭 - ProfileViewController
        let profileViewController = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(withIdentifier: "MyPageViewController") as! MyPageViewController
        let profileTabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        profileViewController.tabBarItem = profileTabBarItem
        let navigationProfile = UINavigationController(rootViewController: profileViewController)
        
        // 뷰 컨트롤러 배열 생성
        let viewControllers = [movieListViewController, searchViewController, movieMapViewController, navigationProfile]
        
        // 탭바 컨트롤러의 뷰 컨트롤러 설정
        self.setViewControllers(viewControllers, animated: false)
    }
}
