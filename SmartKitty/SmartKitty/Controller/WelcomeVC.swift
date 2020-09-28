//
//  WelcomeVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 31.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class WelcomeVC: UIViewController, UIScrollViewDelegate {
    
    //MARK: - PROPERTIES
    //data for slides
    var titles = [
        "Meet your assistant",
        "Know your data",
        "Communicate better"
    ]
    var slideDescription = [
        "Enjoy the mobile dashboard for your Smartcat LSP account",
        "Have all your project related details at your fingertips",
        "Send project links to your colleagues in a snap"
    ]
    var imgs = ["Hello", "Graphs", "Chat"]
    
    var scrollWidth: CGFloat! = 0.0
    var scrollHeight: CGFloat! = 0.0
    
    //MARK: - OUTLETS
    @IBOutlet weak var signInButton: PrimaryButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //get dynamic width and height of scrollview and save it
    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSlides()
    }
    
    func addSlides() {
        //crete the slides and add them
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

        for index in 0..<titles.count {
            frame.origin.x = scrollWidth * CGFloat(index)
            frame.size = CGSize(width: scrollWidth, height: scrollHeight)

            let slide = UIView(frame: frame)

            //subviews
            let imageView = UIImageView.init(image: UIImage.init(named: imgs[index]))
            imageView.frame = CGRect(x:0,y:0,width:250,height:250)
            imageView.contentMode = .scaleAspectFit
            imageView.center = CGPoint(x:scrollWidth/2,y: scrollHeight/2 - 50)
          
            let txt1 = UILabel.init(frame: CGRect(x:32,y:imageView.frame.maxY+30,width:scrollWidth-64,height:30))
            txt1.textAlignment = .center
            txt1.font = UIFont.boldSystemFont(ofSize: 20.0)
            txt1.text = titles[index]

            let txt2 = UILabel.init(frame: CGRect(x:48,y:txt1.frame.maxY+10,width:scrollWidth-96,height:50))
            txt2.textAlignment = .center
            txt2.numberOfLines = 3
            txt2.font = UIFont.systemFont(ofSize: 16.0)
            txt2.text = slideDescription[index]

            slide.addSubview(imageView)
            slide.addSubview(txt1)
            slide.addSubview(txt2)
            scrollView.addSubview(slide)

        }
        
        //set width of scrollview to accomodate all the slides
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(titles.count), height: scrollHeight)

        //disable vertical scroll/bounce
        self.scrollView.contentSize.height = 1.0

        //initial state
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0

    }
   
    
    //indicator
    @IBAction func pageChanged(_ sender: Any) {
        scrollView!.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageControl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndiactorForCurrentPage()
    }

    func setIndiactorForCurrentPage()  {
        let page = (scrollView?.contentOffset.x)!/scrollWidth
        pageControl?.currentPage = Int(page)
    }

    
    //MARK: - GET STARTED TAPPED
    @IBAction func signInTapped(_ sender: Any) {
        goToNextVC()
    }
    
    func goToNextVC() {
        let instructionVC = self.storyboard?.instantiateViewController(identifier: "InstructionVC") as! InstructionVC
        instructionVC.modalPresentationStyle = .fullScreen
        instructionVC.modalTransitionStyle = .crossDissolve
        present(instructionVC, animated: true, completion: nil)
    }
    
 
}
