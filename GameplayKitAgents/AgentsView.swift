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
    
    let wanderGoal = NamedGoal(name: "Wander", goal: GKGoal(toWander: 0.5), weight: 60)
    
    lazy var separateGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Separate",
            goal: GKGoal(toSeparateFromAgents: self.agentSystem.getGKAgent2D(), maxDistance: 10, maxAngle: Float(2 * M_PI)),
            weight: 10)
        
    }()
    
    lazy var alignGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Align",
            goal: GKGoal(toAlignWithAgents: self.agentSystem.getGKAgent2D(), maxDistance: 20, maxAngle: Float(2 * M_PI)),
            weight: 25)
    }()
    
    lazy var cohesionGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Cohesion",
            goal: GKGoal(toCohereWithAgents: self.agentSystem.getGKAgent2D(), maxDistance: 20, maxAngle: Float(2 * M_PI)),
            weight: 50)
    }()
    
    lazy var avoidGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Avoid",
            goal: GKGoal(toAvoidObstacles: self.obstacles, maxPredictionTime: 1),
            weight: 100)
    }()
    
    lazy var seekGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Seek",
            goal: GKGoal(toSeekAgent: self.targets.first!),
            weight: 50,
            weightMultiplier: 0.01)
    }()
    
    lazy var namedGoals: [NamedGoal] =
    {
        [unowned self] in
        [self.wanderGoal, self.separateGoal, self.alignGoal, self.cohesionGoal, self.avoidGoal, self.seekGoal]
    }()
    
    let obstacles = [GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100), GKCircleObstacle(radius: 100)]
    
    let agentSystem =  GKComponentSystem(componentClass: GKAgent2D.self)
    let targets = [GKAgent2D()]
    let behaviour = GKBehavior()
    
    let agentsLayer = CAShapeLayer()
    let obstaclesLayer = CAShapeLayer()
    let seekGoalsLayer = CAShapeLayer()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        layer.addSublayer(agentsLayer)
        layer.addSublayer(obstaclesLayer)
        layer.addSublayer(seekGoalsLayer)
        agentsLayer.strokeColor = UIColor.blackColor().CGColor
        agentsLayer.fillColor = nil
        
        // agents
        
        targets.first?.position = vector_float2(-300, -300)
        
        targets.first?.radius = 20
        
        obstacles[0].position = vector_float2(-200, -200)
        obstacles[1].position = vector_float2(-200, 200)
        obstacles[2].position = vector_float2(200, -200)
        obstacles[3].position = vector_float2(200, 200)
        
        for _ in 0 ... 500
        {
            let agent = GKAgent2D()
            
            agentSystem.addComponent(agent)
        }
        
        resetAgents()
        
        for namedGoal in namedGoals
        {
            setWeight(namedGoal)
        }
        
        for agent in agentSystem.getGKAgent2D()
        {
            agent.behavior = behaviour
        }
        
        drawObstacles()
        drawSeekGoals()
        
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setWeight(namedGoal: NamedGoal)
    {
        behaviour.setWeight(namedGoal.weight * namedGoal.weightMultiplier, forGoal: namedGoal.goal)
        
        obstaclesLayer.opacity = behaviour.weightForGoal(avoidGoal.goal) / 100
    }
    
    func drawSeekGoals()
    {
        seekGoalsLayer.strokeColor = UIColor.blueColor().CGColor
        seekGoalsLayer.fillColor = nil
        seekGoalsLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        for seekTarget in targets
        {
            let position = CGPoint(x: frame.width / 2 + CGFloat(seekTarget.position.x),
                y: frame.height / 2 + CGFloat(seekTarget.position.y))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: seekTarget.radius, dy: seekTarget.radius),
                size: CGSize(width: CGFloat(seekTarget.radius * 2), height: CGFloat(seekTarget.radius * 2))))
            
            bezierPath.appendPath(circle)
        }
        
        seekGoalsLayer.path = bezierPath.CGPath
    }
    
    func drawObstacles()
    {
        obstaclesLayer.strokeColor = UIColor.redColor().CGColor
        obstaclesLayer.fillColor = nil
        obstaclesLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        for obstacle in obstacles
        {
            let position = CGPoint(x: frame.width / 2 + CGFloat(obstacle.position.x),
                y: frame.height / 2 + CGFloat(obstacle.position.y))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: obstacle.radius, dy: obstacle.radius),
                size: CGSize(width: CGFloat(obstacle.radius * 2), height: CGFloat(obstacle.radius * 2))))
            
            bezierPath.appendPath(circle)
        }
        
        obstaclesLayer.path = bezierPath.CGPath
        
    }
    
    func step()
    {
        agentSystem.updateWithDeltaTime(0.1)
        
        let bezierPath = UIBezierPath()
        
        for agent in agentSystem.getGKAgent2D() where !targets.contains(agent)
        {
            let position = CGPoint(x: frame.width / 2 + CGFloat(agent.position.x),
                y: frame.height / 2 + CGFloat(agent.position.y))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: agent.radius, dy: agent.radius),
                size: CGSize(width: CGFloat(agent.radius), height: CGFloat(agent.radius))))
            
            bezierPath.appendPath(circle)
        }
        
        agentsLayer.path = bezierPath.CGPath
    }
    
    
    override func layoutSubviews()
    {
        drawObstacles()
        drawSeekGoals()
    }
    
}

