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
        
        contentView.backgroundColor = UIColor.redColor()
    }

    var namedGoal: NamedGoal?
    {
        didSet
        {
            slider.value = namedGoal?.weight ?? 0
            slider.namedGoal = namedGoal
            
            label.text = namedGoal?.name ?? ""
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
        label.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2).insetBy(dx: 10, dy: 0)
        
        slider.frame = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2).insetBy(dx: 10, dy: 0)
    }
}

class SliderWithNamedGoal: UISlider
{
    var namedGoal: NamedGoal?
}