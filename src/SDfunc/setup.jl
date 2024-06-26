#--------------------------------------------------------------------------------
#This file contains grid_dicts/mutable structs organization
#--------------------------------------------------------------------------------

export Superdroplet, create_NaCl_superdroplets, create_gridbox, droplet_gridbox, set_to_gridReq!

#Superdroplet type: mutable struct with radius, location, multiplicity, volume, solute mass, and molar mass of solute

#functions:
#create_NaCl_superdroplets(Ns,Ny,Nx,Δx,Δy,ξstart,Mstart),  returns Ns superdroplets based on init vectors
#create_gridbox(Nx,Ny,Δx,Δy),                              returns grid box and midpoints
#droplet_gridbox(droplets,grid_dict),                      returns grid_dict with list of droplets in each grid box
#set_to_gridReq!(superdroplets, grid_dict, gridR)          sets the radius of each droplet to the equilibrium radius of the grid box


################################################################################

mutable struct Superdroplet
    R::Float64 #radius (m)
    loc::Vector{Float64} #location (m)
    ξ::Int64 #multiplicity
    X::Float64
    M::Float64
    m::Float64
end

# Create superdroplets with random locations and initial ξ and M values
function create_NaCl_superdroplets(Ns,Nx,Ny,Δx,Δy,Rstart,Xstart,ξstart,Mstart)
    superdroplets = []
    for i in 1:Ns
        R = Rstart[i]
        X = Xstart[i]
        loc = [rand(0.003:Nx*Δx), rand(0.003:Ny*Δy)]
        ξ = ξstart[i]
        M = Mstart[i]
        m = 58.44 #NaCl
        droplet = Superdroplet(R,loc, ξ,X,M,m)
        push!(superdroplets, droplet)
    end
    return superdroplets
end

# Create grid box
function create_gridbox(Nx,Ny,Δx,Δy)
    grid_box = Array{Tuple{Float64, Float64,Float64,Float64}}(undef, Nx, Ny)
    grid_box_mids_x = zeros(Nx, Ny)
    grid_box_mids_y = zeros(Nx, Ny)
    for i in 1:Nx
        for j in 1:Ny
            dx_lower = (i-1) * Δx
            dx_upper = i * Δx
            dy_lower = (j-1) * Δy
            dy_upper = j * Δy
            mid_x = (dx_lower + dx_upper)/2
            mid_y = (dy_lower + dy_upper)/2
            grid_box[i, j] = (dx_lower, dx_upper, dy_lower, dy_upper)
            grid_box_mids_x[i, j] = mid_x
            grid_box_mids_y[i, j] = mid_y
        end
    end
    return grid_box, grid_box_mids_x, grid_box_mids_y
end

# Determine which grid box the droplet is in by ordering by location and then finding the grid box
function droplet_gridbox(droplets,Nx,Ny,Δx,Δy,grid_dict)

    for i in 1:Nx
        for j in 1:Ny
            grid_dict[(i, j)] = Superdroplet[]
        end
    end

    grid_dict[0,0] = Superdroplet[]


    for droplet in droplets
        i = ceil(droplet.loc[1]/Δx)
        j = ceil(droplet.loc[2]/Δy)
        grid = (i,j)
        if haskey(grid_dict, grid)
            push!(grid_dict[grid], droplet)
        else
            grid_dict[grid] = [droplet]
        end
    end
end

#gridR is the equilibrium radius for each grid box: this makes some generalizations
#about the starting size based on environmental conditions, should be edited
function set_to_gridReq!(superdroplets, grid_dict, gridR)
    for i in 1:Nx
        for j in 1:Ny
            for droplet in grid_dict[(i,j)]
                droplet.R = gridR[i,j]
                droplet.X = 4/3 * π * droplet.R^3
            end
        end
    end
end




