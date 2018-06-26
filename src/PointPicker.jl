__precompile__()

module PointPicker

using Makie, GeometryTypes#, Colors

export pickpoints

function pickpoints(img)
    h, w = size(img)
    markersize = round(Int, min(h, w)*0.03)
    withinbounds(p) = 0 ≤ p[1] ≤ w && 0 ≤ p[2] ≤ h
    scene = Scene()
    image(img)
    center!(scene, 0.2)
    cam = scene[:screen].cameras[:orthographic_pixel]
    Makie.add_mousebuttons(scene)
    clicks = to_node(Point2f0[])
    pos = lift_node(scene, :mousebuttons) do buttons
        if length(buttons) == 1 
            positions = to_value(clicks)
            if first(buttons) == Mouse.left
                pos = to_world(Point2f0(to_value(scene, :mouseposition)), cam)
                withinbounds(pos) || return
                push!(positions, pos)
            elseif first(buttons) == Mouse.right
                isempty(positions) && return
                pos = to_world(Point2f0(to_value(scene, :mouseposition)), cam)
                _, i = findmin(norm(pos - p) for p in positions)
                deleteat!(positions, i)
            else
                return
            end
            push!(clicks, positions)
        end
        return 
    end
    scatter(clicks, markersize = markersize)
    close = Condition()
    lift_node(scene[:window_open]) do open
        open || notify(close)
    end
    wait(close)
    return to_value(clicks)
end

end # module
