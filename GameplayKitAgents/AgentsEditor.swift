//
//  AgentsEditor.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 19/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class AgentsEditor: UIStackView
{
    let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    let resetButton = UIButton()
    
    weak var delegate: AgentsEditorDelegate?
    
    required init(namedGoals: [NamedGoal])
    {
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.lightGrayColor()
        
        addArrangedSubview(tableView)
        
        tableView.registerClass(AgentsEditorItemRenderer.self,
            forCellReuseIdentifier: "AgentsEditorItemRenderer")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 50
        
        resetButton.setTitle("Reset", forState: UIControlState.Normal)
        resetButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        resetButton.addTarget(self, action: "resetClickHandler", forControlEvents: UIControlEvents.TouchDown)
        
        addArrangedSubview(resetButton)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var namedGoals: [NamedGoal]?
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    func resetClickHandler()
    {
        delegate?.resetAgents()
    }
    
    func sliderChangeHandler(slider: SliderWithNamedGoal)
    {
        if let namedGoal = slider.namedGoal
        {
            delegate?.goalWeightDidChange(namedGoal)
        }
    }
    
    override func layoutSubviews()
    {
        axis = UILayoutConstraintAxis.Vertical
    }
}

extension AgentsEditor: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return namedGoals?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AgentsEditorItemRenderer",
            forIndexPath: indexPath) as! AgentsEditorItemRenderer
        
        cell.namedGoal = namedGoals?[indexPath.item]
        
        cell.slider.addTarget(self, action: "sliderChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
        
        return cell
    }
}

extension AgentsEditor: UITableViewDelegate
{
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
}

protocol AgentsEditorDelegate: class
{
    func goalWeightDidChange(namedGoal: NamedGoal)
    func resetAgents()
}
