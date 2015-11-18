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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(agentsView)
        
        for i in 0 ..< agentsView.behaviour.goalCount
        {
            print (agentsView.behaviour[i].debugDescription)
        }
    }
    
  
    
    override func viewDidLayoutSubviews()
    {
        let shortDimension = min(view.frame.height - topLayoutGuide.length, view.frame.width)
        
        agentsView.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: shortDimension,
            height: shortDimension)
    }
}

extension CGPoint
{
    func offset(dx dx: Float, dy: Float) -> CGPoint
    {
        return offset(dx: CGFloat(dx), dy: CGFloat(dy))
    }
    
    func offset(dx dx: CGFloat, dy: CGFloat) -> CGPoint
    {
        return CGPoint(x: x - dx, y: y - dy)
    }
}

extension GKComponentSystem
{
    func getGKAgent2D() -> [GKAgent2D]
    {
        return components
            .filter({ $0 is GKAgent2D })
            .map({ $0 as! GKAgent2D })
    }
}

