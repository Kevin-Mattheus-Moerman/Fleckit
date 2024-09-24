using Fleckit
using XML
using Random
Random.seed!(1) # Ensured random numbers are repeatable

###

# Define page canvas parameters 
wx = 210 # Width of 
wy = 297 # Height
fill = "white"

# Define speckle parameters 
rMin = 0.75 # Minimum radius
rMax = 1.0 # Maximum radius
s = 0.0 # Spacing in mm between speckles (prior to random shifts)
maxShift = rMax+s/2 # 0.5*(s/2) # random shift magnitude
pointSpacing = s+2*rMax # Initial speckle spacing

# Setting up grid
minX = pointSpacing
maxX = wx-pointSpacing
minY = pointSpacing
maxY = wy-pointSpacing
xRange = minX:pointSpacing:maxX 
pointSpacing_Y = pointSpacing.*0.5*sqrt(3)
yRange = minY:pointSpacing_Y:maxY
sx = pointSpacing/4

# 
numSteps = 10
λ_max = 1.5
λ_range = range(1,λ_max,numSteps) # collect(λ_range)
for (q,λ₁) in enumerate(λ_range)
    Random.seed!(1) # Ensured random numbers are repeatable

    # Initialise XML
    doc,svg_node = svg_initialize(wx,wy; fill=fill)
    
    λ₂ = 1.0 / λ₁
    nSet = [4,25]
    
    for (j,y) in enumerate(yRange) # Y steps in grid
        for (i,x) in enumerate(xRange) # X steps in grid
            
            n = rand(nSet,1)[1]
            
            if n == 4
                T = 0.25*pi .+ range(0,2*pi,n+1) 
            else
                T = range(0,2*pi,n+1) 
            end
            if iseven(j) # Shift over every second row of points
                x = x+sx
            else
                x = x-sx
            end  

            # Create polyline points
            cx = λ₂ * (x + (maxShift*rand()-maxShift/2))
            cy = λ₁ * (y + (maxShift*rand()-maxShift/2))            
            rx = rMin +(rMax-rMin)*rand()
            ry = rMin +(rMax-rMin)*rand()
            a = 2*pi*rand()            
            R = [cos(a) -sin(a); sin(a) cos(a)]        
            P = [ R*[rx*cos(t),ry*sin(t)] for t in T]
            P = [ [cx + λ₂*p[1],cy + λ₁*p[2]] for p in P]
            
            # Add polyline to svg
            addpolyline(svg_node,P)
        end
    end

    # Write svg
    fileName = fleckitdir()*"/assets/temp"*string(q)*".svg"
    svg_write(fileName,doc)
end

