//
//  AgentsView.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 18/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import GameplayKit

class AgentsView: UIView
{
    lazy var timer: CADisplayLink =
    {
        [unowned self] in
        return CADisplayLink(target: self, selector: Selector("step"))
    }()
    
    let wanderGoal = GKGoal(toWander: 0.5)
    
    lazy var separateGoal: GKGoal =
    {
        [unowned self] in
        GKGoal(toSeparateFromAgents: self.agentSystem.getGKAgent2D(), maxDistance: 10, maxAngle: Float(2 * M_PI))
    }()
    
    lazy var alignGoal: GKGoal =
    {
        [unowned self] in
        GKGoal(toAlignWithAgents: self.agentSystem.getGKAgent2D(), maxDistance: 20, maxAngle: Float(2 * M_PI))
    }()
    
    lazy var cohesionGoal: GKGoal =
    {
        [unowned self] in
        GKGoal(toCohereWithAgents: self.agentSystem.getGKAgent2D(), maxDistance: 20, maxAngle: Float(2 * M_PI))
    }()
    
    lazy var avoidGoal:GKGoal =
    {
        [unowned self] in
        GKGoal(toAvoidObstacles: self.obstacles, maxPredictionTime: 1)
    }()
    
    lazy var seekGoal:GKGoal =
    {
        [unowned self] in
        GKGoal(toSeekAgent: self.targets.first!)
    }()
    
    let obstacles = [GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100)]
    
    let agentSystem =  GKComponentSystem(componentClass: GKAgent2D.self)
    
    let targets = [GKAgent2D()]
    
    let agentsLayer = CAShapeLayer()
    let obstaclesLayer = CAShapeLayer()
    let seekGoalsLayer = CAShapeLayer()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}