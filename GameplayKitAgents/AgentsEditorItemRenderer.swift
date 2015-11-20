//
//  AgentsEditorItemRenderer.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 19/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class AgentsEditorItemRenderer: UITableViewCell
{
    let label = UILabel()
    let slider = SliderWithNamedGoal()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(slider)
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    var namedGoal: NamedGoal?
    {
        didSet
        {
            slider.value = namedGoal?.weight ?? 0
            slider.namedGoal = namedGoal
            
            label.text = (namedGoal?.name ?? "") + String(format: ": %.2f", slider.value)
        }
    }
    
    func sliderChangeHandler()
    {
        namedGoal?.weight = slider.value
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        let componentsHeight = label.intrinsicContentSize().height + slider.intrinsicContentSize().height
        
        contentView.frame = CGRect(x: 0,
            y: frame.height / 2 - componentsHeight / 2,
            width: frame.width - 20,
            height: componentsHeight)
        
        label.frame = CGRect(x: 0,
            y: 0,
            width: contentView.frame.width,
            height: label.intrinsicContentSize().height).insetBy(dx: 10, dy: 0)
        
        slider.frame = CGRect(x: 0,
            y: label.intrinsicContentSize().height,
            width: contentView.frame.width,
            height: slider.intrinsicContentSize().height).insetBy(dx: 10, dy: 0)
      

    }
}

class SliderWithNamedGoal: UISlider
{
    var namedGoal: NamedGoal?
}