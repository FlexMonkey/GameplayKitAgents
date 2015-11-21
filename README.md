# GameplayKitAgents
#### GameplayKitAgents Experiments

#### _Companion project to this post: http://flexmonkey.blogspot.co.uk/2015/11/a-look-at-agents-goals-behaviours-in.html_

![screenshot](/GameplayKitAgents/gameplaykit.gif)

GameplayKit is one of the new frameworks introduced at WWDC 2015. It includes some interesting functionality that isn't just for games such as random number generation, state machines and pathfinding. 

In this post, I'm going to look at agents, goals and behaviours which allows the creation of agents  that follow simple dynamic rules such as cohesion and separation. To demonstrate the effects of rules and goals on agents, I've built a little demo app, GameplayKitAgents, which creates a system of 250 agents with a user interface to move obstacles and seek targets and vary the weight of different goals.

## Agents

A GameplayKit component system starts with an instance of `GKComponentSystem` which is instantiated with the component class we want to use as its members. `GKComponentSystem` is homogenous and this component class is immutable. In the case of my app, I'll be using `GKAgent2D` so my opening line looks like this:

```swift
    let agentSystem =  GKComponentSystem(componentClass: GKAgent2D.self)
```

I'm going to create an array of 250 agents, since `GKAgent2D` is a class and passed by reference, if I do this:

```swift
    let agents = [GKAgent2D](count: 250, repeatedValue: GKAgent2D())
```

I actually only get one agent, referenced 250 times in the array, so I populate the agent system's components in a loop:

```swift
    for _ in 0 ... 250
    {
        agentSystem.addComponent(GKAgent2D())
    }
```

## Goals

Next, I create some goals. These are instances of `GKGoal` and define the forces that act upon each agent. Rather than creating a multitude of sub-classes, Apple have chosen to implement different goals with different constructors, for example wandering and cohesion are created with these initialisers:

```swift
    public convenience init(toCohereWithAgents agents: [GKAgent], 
        maxDistance: Float, 
        maxAngle: Float)
    
    public convenience init(toWander speed: Float)
```

Since there's no way to interrogate a goal after creation to see what type it is, I've created my own class, `NamedGoal`, which includes name and weight properties. So my cohesion and wander goals look like this:

```swift
    lazy var cohesionGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Cohesion",
            goal: GKGoal(toCohereWithAgents: self.agentSystem.getGKAgent2D(),
                maxDistance: 20,
                maxAngle: Float(2 * M_PI)),
            weight: 50)

    }()

    let wanderGoal = NamedGoal(name: "Wander",
        goal: GKGoal(toWander: 25),
        weight: 60)
```

I've also added an extension to `GKComponentSystem` so that I can get a typed array of `GKAgent2D` to use when constructing goals that reference the agents, for example, the cohesion goal:

```swift
    extension GKComponentSystem
    {
        func getGKAgent2D() -> [GKAgent2D]
        {
            return components
                .filter({ $0 is GKAgent2D })
                .map({ $0 as! GKAgent2D })
        }
    }
```

My system also includes a seek target (in blue) and obstacles to avoid (in red). These are also defined as goals. For the obstacles, I've created an array of four `GKCircleObstacle`, 

```swift
    let obstacles = [GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100),
        GKCircleObstacle(radius: 100)]
```

...and passed that to an avoid goal:

```swift
    lazy var avoidGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Avoid",
            goal: GKGoal(toAvoidObstacles: self.obstacles,
                maxPredictionTime: 2),
            weight: 100)
    }()
```

The seek goal uses an agent, 

```swift
    let targets = [GKAgent2D()]

    lazy var seekGoal: NamedGoal =
    {
        [unowned self] in
        NamedGoal(name: "Seek",
            goal: GKGoal(toSeekAgent: self.targets.first!),
            weight: 50,
            weightMultiplier: 0.01)
    }()
```

Once I've crafted all of my `NamedGoal` instances, I create an array to hold them:

```swift
    lazy var namedGoals: [NamedGoal] =
    {
        [unowned self] in
        [self.wanderGoal, self.cohesionGoal, self.avoidGoal, self.seekGoal]

    }()
```

## Behaviours

To apply the goals to the system, I use a `GKBehavior`. 

```swift
    let behaviour = GKBehavior()
```

By looping over my `namedGoals` array, I can add each goal to the behaviour by simply invoking `setWeight` which adds or changes the weight of a goal on that behaviour:

```swift
    for namedGoal in namedGoals
    {
         behaviour.setWeight(namedGoal.weight, forGoal: namedGoal.goal)
    }
```

Then a loop over each of the agents in the system allows me to apply my behaviour to each one:

```swift
    for agent in agentSystem.getGKAgent2D()
    {
        agent.behavior = behaviour
    }
```

## Animation & Rendering

To animate the system, I use a `CADisplayLink` which will fire `step` with each screen refresh:

```swift
    lazy var displayLink: CADisplayLink =
    {
        [unowned self] in
        return CADisplayLink(target: self, selector: Selector("step"))
    }()

    // in init()
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(),
        forMode: NSDefaultRunLoopMode)
```

I'm drawing the agents by constructing a single `UIBezierPath` with a small circle for each agent and setting that as the path for my view's layer. So, my step method does two things, first updates the system so each agent has its position changed by the forces of the goals acting upon it, then second it creates the path and applies it: 

```swift
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
```

`appendCircleOfRadius` is an extension to `UIBezierPath` that, unsurprisingly, appends a circle to a path and is happy accepting GameplayKit's `vector_float2` and `Float` rather than CoreGraphics's `CGPoint` and `CGFloat`:

```swift
    extension UIBezierPath
    {
        func appendCircleOfRadius(radius: Float, atPosition position: vector_float2, inFrame frame: CGRect)
        {
            let position = CGPoint(x: frame.width / 2 + CGFloat(position.x),
                y: frame.height / 2 + CGFloat(position.y))
            
            let circle = UIBezierPath(ovalInRect: CGRect(origin: position.offset(dx: radius, dy: radius),
                size: CGSize(width: CGFloat(radius * 2), height: CGFloat(radius * 2))))
            
            appendPath(circle)
        }
    }
```

## User Interface

Finally, the user interface is built from a few components. 

* The main view, `AgentsView`, contains the system, the display link and pretty much everything discussed in this post.
* The editor view, `AgentsEditor`, contains a `UITableView` with a row for each `NamedGoal`, when the sliders in the table view change, the editor invokes `goalWeightDidChange` on its `AgentsEditorDelegate`. In my demo app, the view controller acts as the `AgentsEditorDelegate` and invokes setWeight on the `AgentsView`.

The obstacles and target can be moved around with a touch/drag which is handled inside `AgentsView`.

## In Conclusion

GameplayKit offers some pretty high level dynamic behaviours with a very simple API. I've coded similar systems in the past (see my Swarm Chemistry stuff) and it can be tricky to get right. Performance is pretty impressive, on my iPad Pro, this app breezes along with 500 agent, but I've set the default to 250 agents.

I don't think this framework is limited to games, my first thought for agents, goals and behaviours was for a simple crowd simulation application.

As always, the source code for this demo is available at my GitHub repository here. Enjoy!
