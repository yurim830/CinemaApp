//
//  ViewController.swift
//  CinemaApp
//
//  Created by YJ on 4/22/24.
//

import UIKit
import Kingfisher

class SearchMovieViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var genreSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieListCollectionView: UICollectionView!
    @IBOutlet weak var noticeLabel: UILabel!
    
    // TODO: Key를 발급받아 채워주세요.
    let authenticationKey = ""
    let urlString = "https://api.themoviedb.org/3/search/movie"
    let genreListUrl = "https://api.themoviedb.org/3/genre/movie/list"
    
    let interSpacing: CGFloat = 2
    
    var movieList: [Results] = [] {
        didSet {
            DispatchQueue.main.async {
                self.movieListCollectionView.reloadData()
            }
        }
    }
    
    var filteredMovieList: [Results] = []
    var isFiltered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        movieListCollectionView.dataSource = self
        movieListCollectionView.delegate = self
        view.backgroundColor = UIColor(named: "BackgroundColor")
        getData(query: "") { a in }
        setSearchBar()
        noticeLabelUI()
        getGenreData()
        
        self.genreSegmentedControl.addTarget(self, action: #selector(genreChanged(segment:)), for: .valueChanged)
        
    }
    
    func noticeLabelUI() {
        noticeLabel.text = "검색어 없음"
        noticeLabel.font = UIFont.systemFont(ofSize: 20)
        noticeLabel.textColor = UIColor(named: "LabelTextColor")
        noticeLabel.isHidden = false
        movieListCollectionView.backgroundColor = UIColor(named: "customPrimaryColor")
    }
    
    func setSearchBar() {
        searchBar.placeholder = "영화 제목을 검색하세요."
        searchBar.setImage(UIImage(named: "icClear"), for: UISearchBar.Icon.search, state: .normal)
        searchBar.setImage(UIImage(named: "icCancel"), for: .clear, state: .normal)
        searchBar.barTintColor = UIColor(named: "customPrimaryColor")
        // cancel button color 변경
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
         UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor(named: "customPrimaryColor")
            textfield.textColor = UIColor(named: "LabelTextColor")
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            textfield.textColor = UIColor.white
            // 왼쪽 아이콘 이미지
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
            //오른쪽 x버튼 이미지
            if let rightView = textfield.rightView as? UIImageView {
                rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
                rightView.tintColor = UIColor.white
            }
        }
    }
    
    @objc func genreChanged(segment: UISegmentedControl) {
        isFiltered = true
        filterActionMovie(movieList: movieList)
    
        switch segment.selectedSegmentIndex {
        case 0:
            isFiltered = false
        case 1:
            filterAnimaionMovie(movieList: movieList)
        case 2:
            filterComedyMovie(movieList: movieList)
        case 3:
            filterFantasyMovie(movieList: movieList)
        case 4:
            filterThillerMovie(movieList: movieList)
        case 5:
            filterActionMovie(movieList: movieList)
        default:
            break
        }
            
        movieListCollectionView.reloadData()
    }
    
    func filterActionMovie(movieList: [Results]) {
        filteredMovieList = movieList.filter {
            $0.genre_ids.contains(28)
        }
    }
    
    func filterAnimaionMovie(movieList: [Results]) {
        filteredMovieList = movieList.filter {
            $0.genre_ids.contains(16)
        }
    }
    
    func filterComedyMovie(movieList: [Results]) {
        filteredMovieList = movieList.filter {
            $0.genre_ids.contains(35)
        }
    }
    
    func filterFantasyMovie(movieList: [Results]) {
        filteredMovieList = movieList.filter {
            $0.genre_ids.contains(14)
        }
    }
    
    func filterThillerMovie(movieList: [Results]) {
        filteredMovieList = movieList.filter {
            $0.genre_ids.contains(53)
        }
    }
    
    func getData(query: String, completion: @escaping([Results]) -> Void ) {
        isFiltered = false
        filteredMovieList = []
        
        guard let url = URL(string: urlString) else { return }
        // 파라미터 or 헤더를 추가 -> URLComponents -> URLRequest 안에 components?.url 넣기
        // 헤더 or 파라미터 필요 x -> URLRequest만 생성
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        // 파라미터 설정
        let qureyParam = URLQueryItem(name: "query", value: query)
        let languageParam = URLQueryItem(name: "language", value: "ko-KR")
        let queryItems = [qureyParam, languageParam]
        components?.queryItems = queryItems
        
        guard let componentUrl = components?.url else { return }
        var urlRequest = URLRequest(url: componentUrl)
        
        // 해더 설정
        urlRequest.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(authenticationKey)"
        ]
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Movies.self, from: data)
                self.movieList = result.results
                completion(result.results)
            } catch {
                print("error: \(error)")
            }
        }
        .resume()
    }
    
    func getGenreData() {
        guard let url = URL(string: genreListUrl) else { return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let languageParm: [URLQueryItem] = [URLQueryItem(name: "language", value: "ko")]
        components?.queryItems = languageParm
        
        guard let componentUrl = components?.url else { return }
        var urlRequest = URLRequest(url: componentUrl)

        urlRequest.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(authenticationKey)"
        ]
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else { return }
            // print("data: \(data)")
            // guard let encodedData = String(data: data, encoding: .utf8) else { return }
            // print("unwrappedData:\(encodedData)")
            
            // 통신에 실패했을 경우 alert 띄우기
            guard error == nil else {
                let cancelAction = UIAlertAction(title: "닫기", style: .default)
                let alertController = UIAlertController(title: "⚠️ 경고 ⚠️", message: "네트워크 오류가 발생했습니다.\n다시 시도해 주세요.", preferredStyle: .alert)
                alertController.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(GenresMovieList.self, from: data)
            } catch {
                print("genre data error: \(error)")
            } 
        }
        .resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltered {
            filteredMovieList.count
        } else {
            movieList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.movieListCollectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.indentifier, for: indexPath) as? MovieListCollectionViewCell else { return UICollectionViewCell() }
        
        let movie = isFiltered ? filteredMovieList[indexPath.item] : movieList[indexPath.item]
        
        cell.movieImage.contentMode = .scaleAspectFill
        cell.movieImage.backgroundColor = UIColor(named: "BackgroundColor")
        cell.movieImage.tintColor = UIColor(named: "LabelTextColor")
        cell.movieName.backgroundColor = UIColor(named: "customPrimaryColor")
        cell.movieName.tintColor = UIColor(named: "LabelTextColor")
        cell.movieName.text = movie.title
        if let path = movie.poster_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            let placeholderImage = UIImage(systemName: "movieclapper")
            cell.movieImage.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 화면의 너비
        let screenWidth = collectionView.frame.width
        // 한 줄에 몇 개 둘건지
        let lineItemCount: CGFloat = 3
        // Cell 사이 간격들의 합
        let totalInterSpacing: CGFloat = interSpacing * (lineItemCount - 1)
        // 아이텀 하나 크기
        let itemWidth = (screenWidth - totalInterSpacing) / lineItemCount
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }
    
}

extension SearchMovieViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        getData(query: searchText) { movieResults in
            if self.movieList.count == 0 && searchText != "" {
                DispatchQueue.main.async {
                    self.noticeLabel.isHidden = false
                    self.noticeLabel.text = "이런! 찾으시는 작품이 없습니다."
                    self.noticeLabel.textColor = UIColor(named: "LabelTextColor")
                    self.genreSegmentedControl.selectedSegmentIndex = 0
                }
            } else if self.movieList.count != 0 {
                DispatchQueue.main.async {
                    self.noticeLabel.isHidden = true
                    self.genreSegmentedControl.selectedSegmentIndex = 0
                }
            } else {
                DispatchQueue.main.async {
                    self.noticeLabel.isHidden = false
                    self.noticeLabel.text = "검색어 없음"
                    self.noticeLabel.textColor = UIColor(named: "LabelTextColor")
                    self.genreSegmentedControl.selectedSegmentIndex = 0
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

