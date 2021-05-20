//
//  RatingControl.swift
//  TechProject
//
//  Created by Zhalgas Yegizgarin on 8/21/19.
//  Copyright © 2019 Zhalgas Yegizgarin. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    var rating = 0 {
        didSet{
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet{
            setupButtons()
        }
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    @objc func ratingButtonTapped(button: UIButton){
        
        guard let index = ratingButtons.firstIndex(of: button) else {
            return
        }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else{
            rating = selectedRating
        }
    }
    
    private func setupButtons(){
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "star1.0", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "star0.0-1", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "star1.0 copy", in: bundle, compatibleWith: self.traitCollection)
        
        
        for _ in 0 ..< starCount {
            
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
            
        }
        updateButtonSelectionState()
        
    }
    private func updateButtonSelectionState(){
        for (index, button) in ratingButtons.enumerated(){
            button.isSelected = index < rating
        }
    }

}
