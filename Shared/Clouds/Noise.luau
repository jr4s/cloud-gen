local Noise = {}

function Noise.fBm3D(x, y, z, seed, octaves, persistence, lacunarity, scale)
    scale = scale or 0.01

    local total =     0
    local frequency = 1
    local amplitude = 1
    local maxVal =    0
    
    for i = 1, octaves do
        local n = math.noise(
            (x + seed) * scale * frequency,
            (y + seed) * scale * frequency,
            (z + scale) * scale * frequency
        )
        
        total = total + n * amplitude
        maxVal = maxVal + amplitude
        
        amplitude = amplitude * persistence
        frequency = frequency * lacunarity
    end
    
    local val = total / maxVal
    return (val + 1) / 2

end

return Noise
