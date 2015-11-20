//
//  ViewController.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 17/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController
{
    let agentsView = AgentsView()
    let agentsEditor = AgentsEditor(namedGoals: [])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(agentsView)
        view.addSubview(agentsEditor)
        
        agentsEditor.namedGoals = agentsView.namedGoals
        agentsEditor.delegate = agentsView
        
        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews()
    {
        let isLandscape = view.frame.width > view.frame.height
        let shortDimension = min(view.frame.height - topLayoutGuide.length, view.frame.width)
        
        agentsView.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: shortDimension,
            height: shortDimension)
        
        agentsEditor.frame = CGRect(x: isLandscape ? shortDimension : 0,
            y: topLayoutGuide.length + (isLandscape ? 0 : shortDimension),
            width: view.frame.width - (isLandscape ? shortDimension : 0),
            height: view.frame.height - topLayoutGuide.length - (isLandscape ? 0 : shortDimension)).insetBy(dx: 10, dy: 10)
    }
}

extension AgentsView: AgentsEditorDelegate
{
    func goalWeightDidChange(namedGoal: NamedGoal)
    {
        setWeight(namedGoal)
    }
    
    func resetAgents()
    {
        for agent in agentSystem.getGKAgent2D()
        {
            let randomRadius = 5 + drand48() * 200
            let randomAngle = drand48() * M_PI * 2
            
            agent.radius = 10
            agent.position.x = Float(sin(randomAngle) * randomRadius)
            agent.position.y = Float(cos(randomAngle) * randomRadius)
            
            agent.maxAcceleration = 50
            agent.maxSpeed = 100
        }
    }
}



