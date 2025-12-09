local GreedyMesh = {}

function GreedyMesh.GenerateMesh(grid, origin, blockSize, parent, color)
    local parts = {}
    for x, col in pairs(grid) do
        for y, row in pairs(col) do
            for z, filled in pairs(row) do
                if filled then
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(blockSize, blockSize, blockSize)
                    part.Position = origin + Vector3.new(x*blockSize, y*blockSize, z*blockSize)
                    part.Anchored = true
                    part.CanCollide = false
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                    part.Color = color
                    part.Parent = parent
                    table.insert(parts, part)
                end
            end
        end
    end
    return parts
end

return GreedyMesh
