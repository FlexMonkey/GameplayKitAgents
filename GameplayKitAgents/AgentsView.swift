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
    lazy var displayLink: CADisplayLink =
    {
        [unowned self] in
        return CADisplayLink(target: self, selector: Selector("step"))
    }()
    
    let wanderGoal = NamedGoal(name: "Wander",
        goal: GKGoal(toWander: 25),
        weight: 60)
    
    lazy var separateGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Separate",
            goal: GKGoal(toSeparateFromAgents: self.agentSystem.getGKAgent2D(),
                maxDistance: 10,
                maxAngle: Float(2 * M_PI)),
            weight: 10)
        
    }()
    
    lazy var alignGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Align",
            goal: GKGoal(toAlignWithAgents: self.agentSystem.getGKAgent2D(),
                maxDistance: 20,
                maxAngle: Float(2 * M_PI)),
            weight: 25)
    }()
    
    lazy var cohesionGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Cohesion",
            goal: GKGoal(toCohereWithAgents: self.agentSystem.getGKAgent2D(),
                maxDistance: 20,
                maxAngle: Float(2 * M_PI)),
            weight: 50)
    }()
    
    lazy var avoidGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Avoid",
            goal: GKGoal(toAvoidObstacles: self.obstacles,
                maxPredictionTime: 2),
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
    
    let obstacles = [GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100)]
    
    let agentSystem =  GKComponentSystem(componentClass: GKAgent2D.self)
    let targets = [GKAgent2D()]
    let behaviour = GKBehavior()
    
    let agentsLayer = CAShapeLayer()
    let obstaclesLayer = CAShapeLayer()
    let seekGoalsLayer = CAShapeLayer()
    
    var selectionMode = SelectionMode.None
    
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
        
        for _ in 0 ... 250
        {
            agentSystem.addComponent(GKAgent2D())
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
        
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(),
            forMode: NSDefaultRunLoopMode)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setWeight(namedGoal: NamedGoal)
    {
        behaviour.setWeight(namedGoal.weight * namedGoal.weightMultiplier, forGoal: namedGoal.goal)
        
        obstaclesLayer.opacity = behaviour.weightForGoal(avoidGoal.goal) / 100
        
        seekGoalsLayer.opacity = behaviour.weightForGoal(seekGoal.goal) / 100 / seekGoal.weightMultiplier
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touchPosition = touches.first?.locationInView(self), target = targets.first else
        {
            return
        }

        let adjustedTouchLocation = vector_float2(Float(touchPosition.x - frame.width / 2),
            Float(touchPosition.y - frame.height / 2))
        
        let distToTarget = hypot(adjustedTouchLocation.x - target.position.x,
            adjustedTouchLocation.y - target.position.y)
        
        if distToTarget < target.radius
        {
            selectionMode = .Target
            return
        }
        
        for (index, obstacle) in obstacles.enumerate()
        {
            let distToObstacle = hypot(adjustedTouchLocation.x - obstacle.position.x,
                adjustedTouchLocation.y - obstacle.position.y)
            
            if distToObstacle < obstacle.radius
            {
                selectionMode = .Obstacle(index: index)
                return
            }
        }
        
        selectionMode = .None
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touchPosition = touches.first?.locationInView(self) else
        {
            return
        }
        
        let adjustedTouchLocation = vector_float2(Float(touchPosition.x - frame.width / 2),
            Float(touchPosition.y - frame.height / 2))
        
        switch selectionMode
        {
        case .None:
            return
        case .Target:
            targets.first?.position = adjustedTouchLocation
            drawSeekGoals()
        case .Obstacle(let idx):
            obstacles[idx].position = adjustedTouchLocation
            drawObstacles()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        selectionMode = .None
    }
    
    func drawSeekGoals()
    {
        seekGoalsLayer.strokeColor = UIColor.blueColor().CGColor
        seekGoalsLayer.fillColor = nil
        seekGoalsLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        for seekTarget in targets
        {
            bezierPath.appendCircleOfRadius(seekTarget.radius,
                atPosition: seekTarget.position,
                inFrame: frame)
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
            bezierPath.appendCircleOfRadius(obstacle.radius,
                atPosition: obstacle.position,
                inFrame: frame)
        }
        
        obstaclesLayer.path = bezierPath.CGPath
        
    }
    
    func step()
    {
        agentSystem.updateWithDeltaTime(0.05)
        
        let bezierPath = UIBezierPath()
        
        for agent in agentSystem.getGKAgent2D()
        {
            bezierPath.appendCircleOfRadius(agent.radius,
                atPosition: agent.position,
                inFrame: frame)
        }
        
        agentsLayer.path = bezierPath.CGPath
    }
    
    
    override func layoutSubviews()
    {
        drawObstacles()
        drawSeekGoals()
    }
    
}

enum SelectionMode
{
    case None
    case Target
    case Obstacle(index: Int)
}

