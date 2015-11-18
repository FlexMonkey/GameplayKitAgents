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
            
            let randomRadius = 5 + drand48() * 200
            let randomAngle = drand48() * M_PI * 2
            
            agent.radius = 10
            agent.position.x = Float(sin(randomAngle) * randomRadius)
            agent.position.y = Float(cos(randomAngle) * randomRadius)
            
            agent.maxAcceleration = 50
            agent.maxSpeed = 100
            
            agentSystem.addComponent(agent)
        }
        
        behaviour.setWeight(1, forGoal: seekGoal)
        
        behaviour.setWeight(75, forGoal: separateGoal)
        behaviour.setWeight(0, forGoal: wanderGoal)
        behaviour.setWeight(100, forGoal: cohesionGoal)
        behaviour.setWeight(60, forGoal: alignGoal)
        behaviour.setWeight(100, forGoal: avoidGoal)
        
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