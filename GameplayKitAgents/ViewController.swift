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
    lazy var timer: CADisplayLink =
    {
        [unowned self] in
        
        return CADisplayLink(target: self, selector: Selector("step"))
    }()
    
    let agentSystem =  GKComponentSystem(componentClass: GKAgent2D.self)

   
    let agents = [GKAgent2D]()
    let seekTarget = GKAgent2D()
    let obstacle = GKCircleObstacle(radius: 25)
    
    let agentsLayer = CAShapeLayer()
    let obstaclesLayer = CAShapeLayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // UI
        
        view.layer.addSublayer(agentsLayer)
        view.layer.addSublayer(obstaclesLayer)
        agentsLayer.strokeColor = UIColor.blackColor().CGColor
        
        // agents
        
        var agents = [GKAgent2D]()
        
        for _ in 0 ... 100
        {
            let agent = GKAgent2D()
            
            let randomDistance = drand48() * 10
            let randomAngle = drand48() * M_PI * 2
            
            agent.radius = 2
            agent.position.x = Float(sin(randomAngle) * randomDistance)
            agent.position.y = Float(cos(randomAngle) * randomDistance)
            
            agents.append(agent)
        }
        
        let wanderGoal = GKGoal(toWander: 0.5)
        let sepGoal = GKGoal(toSeparateFromAgents: agents, maxDistance: 20, maxAngle: 0)
        let align = GKGoal(toAlignWithAgents: agents, maxDistance: 20, maxAngle: 0)
        let cohesion = GKGoal(toCohereWithAgents: agents, maxDistance: 20, maxAngle: 0)

        let avoid = GKGoal(toAvoidObstacles: [obstacle], maxPredictionTime: 5)
        
        
        
        let seek = GKGoal(toSeekAgent: seekTarget)
        
        let behaviour = GKBehavior(goals: [wanderGoal, align, sepGoal, seek, avoid, cohesion])
        
        behaviour.setWeight(5, forGoal: seek)
        behaviour.setWeight(100, forGoal: sepGoal)
        behaviour.setWeight(20, forGoal: wanderGoal)
        behaviour.setWeight(100, forGoal: avoid)
        behaviour.setWeight(60, forGoal: cohesion)
        
        for agent in agents
        {
            agent.behavior = behaviour
            
            agentSystem.addComponent(agent)
        }
        
        seekTarget.position.y = -50
        obstacle.position.y = -25
        
        drawObstacles()
        
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    func drawObstacles()
    {
        obstaclesLayer.strokeColor = UIColor.redColor().CGColor
        obstaclesLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        let position = CGPoint(x: view.frame.width / 2 + CGFloat(obstacle.position.x * 10),
            y: view.frame.height / 2 + CGFloat(obstacle.position.y * 10))
        
        let circle = UIBezierPath(ovalInRect: CGRect(origin: position,
            size: CGSize(width: CGFloat(obstacle.radius * 2), height: CGFloat(obstacle.radius * 2))))
        
        bezierPath.appendPath(circle)
        
        obstaclesLayer.path = bezierPath.CGPath
        
    }
    
    func step()
    {
        agentSystem.updateWithDeltaTime(0.25)
        
        let bezierPath = UIBezierPath()
        
        for agent in agentSystem.getGKAgent2D() where agent != seekTarget
        {
            let position = CGPoint(x: view.frame.width / 2 + CGFloat(agent.position.x * 10),
                y: view.frame.height / 2 + CGFloat(agent.position.y * 10))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position, size: CGSize(width: 10, height: 10)))
            
            bezierPath.appendPath(circle)
        }
        
        agentsLayer.path = bezierPath.CGPath
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

