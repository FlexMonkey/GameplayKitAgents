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
        agentsLayer.fillColor = nil
        
        // agents
        
        var agents = [GKAgent2D]()
        
        for _ in 0 ... 250
        {
            let agent = GKAgent2D()
            
            let randomRadius = 5 + drand48() * 30
            let randomAngle = drand48() * M_PI * 2
            
            agent.radius = 8
            agent.position.x = Float(sin(randomAngle) * randomRadius)
            agent.position.y = Float(cos(randomAngle) * randomRadius)
            
            agents.append(agent)
        }
        
        let wanderGoal = GKGoal(toWander: 0.5)
        let sepGoal = GKGoal(toSeparateFromAgents: agents, maxDistance: 40, maxAngle: Float(2 * M_PI))
        let align = GKGoal(toAlignWithAgents: agents, maxDistance: 20, maxAngle: Float(2 * M_PI))
        let cohesion = GKGoal(toCohereWithAgents: agents, maxDistance: 20, maxAngle: Float(2 * M_PI))

        let avoid = GKGoal(toAvoidObstacles: [obstacle], maxPredictionTime: 2)
        
        
        seekTarget.radius = 20
        let seek = GKGoal(toSeekAgent: seekTarget)
        
        let behaviour = GKBehavior(goals: [wanderGoal, align, sepGoal, seek, cohesion, avoid])
        
        behaviour.setWeight(0.1, forGoal: seek)
        behaviour.setWeight(50, forGoal: sepGoal)
        behaviour.setWeight(5, forGoal: wanderGoal)
        behaviour.setWeight(100, forGoal: avoid)
        behaviour.setWeight(5, forGoal: cohesion)
        
        for agent in agents
        {
            agent.behavior = behaviour
            
            agentSystem.addComponent(agent)
        }
        
        seekTarget.position.y = -300
        obstacle.position.y = -150
        
        drawObstacles()
        
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    func drawObstacles()
    {
        obstaclesLayer.strokeColor = UIColor.redColor().CGColor
        obstaclesLayer.fillColor = nil
        obstaclesLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        let position = CGPoint(x: view.frame.width / 2 + CGFloat(obstacle.position.x),
            y: view.frame.height / 2 + CGFloat(obstacle.position.y))
        
        let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: obstacle.radius, dy: obstacle.radius),
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
            let position = CGPoint(x: view.frame.width / 2 + CGFloat(agent.position.x),
                y: view.frame.height / 2 + CGFloat(agent.position.y))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: agent.radius, dy: agent.radius),
                size: CGSize(width: CGFloat(agent.radius), height: CGFloat(agent.radius))))
            
            bezierPath.appendPath(circle)
        }
        
        agentsLayer.path = bezierPath.CGPath
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

