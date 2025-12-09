local CloudGen = {}
local Noise = require(script.Parent.Noise)

local Workspace = game:GetService("Workspace")

CloudGen.Config = {
    Seed = tick(),
    CloudCountPerLevel = 30, 
    AreaSize = 600,
    DriftSpeed = 5,
    PuffCountMin = 14,
    PuffCountMax = 17,
    PuffSizeVariants = {
        Vector3.new(100, 12.52, 80),
        Vector3.new(59, 22.79, 74.9),
        Vector3.new(55.23, 31.33, 61.16)
    },
    Color = Color3.fromRGB(255,255,255),
    FloatAmplitude = 2,
    FloatSpeed = 0.3,
    MAX_POOL = 500, 
    Levels = {140, 160, 180, 200, 220} 
}

local rng = Random.new(CloudGen.Config.Seed)
local Clouds = {}
local PuffPool = {}

local function CloudNoise(x, z)
    return Noise.fBm3D(x,0,z,CloudGen.Config.Seed, 4, 0.5, 2.0)
end

local function getPuff()
    for i, puff in ipairs(PuffPool) do
        if not puff.Parent then
            return puff
        end
    end
    if #PuffPool < CloudGen.Config.MAX_POOL then
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CastShadow = false
        part.Material = Enum.Material.SmoothPlastic
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        table.insert(PuffPool, part)
        return part
    end
    return nil
end

local function createPuff(parent, size, position)
    local part = getPuff()
    if not part then return nil end
    part.Size = size
    part.Position = position
    part.Color = CloudGen.Config.Color
    part.Parent = parent
    return part
end

local function generateCloud(origin, parentFolder)
    local cloud = { puffs = {}, direction = Vector3.new(0,0,-1), floatOffset = rng:NextNumber(0, 2*math.pi) }
    local folder = Instance.new("Folder")
    folder.Name = "Cloud_"..math.random(1,10000)
    folder.Parent = parentFolder

    local puffCount = rng:NextInteger(CloudGen.Config.PuffCountMin, CloudGen.Config.PuffCountMax)
    for i = 1, puffCount do
        local noiseVal = CloudNoise(origin.X + i*20, origin.Z + i*20)

        local sizeTemplate = CloudGen.Config.PuffSizeVariants[rng:NextInteger(1,#CloudGen.Config.PuffSizeVariants)]

        local size = Vector3.new(
            rng:NextNumber(sizeTemplate.X*0.8, sizeTemplate.X*1.2)*(0.8+noiseVal*0.4),
            rng:NextNumber(sizeTemplate.Y*0.8, sizeTemplate.Y*1.2)*(0.7+noiseVal*0.6),
            rng:NextNumber(sizeTemplate.Z*0.8, sizeTemplate.Z*1.2)*(0.8+noiseVal*0.4)
        )

        local offset = Vector3.new(
            rng:NextNumber(-60,60) + noiseVal*40,
            rng:NextNumber(-3,3), -- small vertical variation within level
            rng:NextNumber(-60,60) + noiseVal*40
        )

        local puff = createPuff(folder, size, origin + offset)
        if puff then table.insert(cloud.puffs, puff) end
    end
    return cloud
end

function CloudGen.Generate()
    local cloudsFolder = workspace:FindFirstChild("CloudsFolder")
    if not cloudsFolder then
        cloudsFolder = Instance.new("Folder")
        cloudsFolder.Name = "CloudsFolder"
        cloudsFolder.Parent = workspace
    end

    for _, puff in ipairs(PuffPool) do
        puff.Parent = nil
    end

    Clouds = {}

    for _, levelY in ipairs(CloudGen.Config.Levels) do
        for i = 1, CloudGen.Config.CloudCountPerLevel do
            local origin = Vector3.new(
                rng:NextNumber(-CloudGen.Config.AreaSize, CloudGen.Config.AreaSize),
                levelY + rng:NextNumber(-5,5), -- small variation inside each level
                rng:NextNumber(-CloudGen.Config.AreaSize, CloudGen.Config.AreaSize)
            )
            local cloud = generateCloud(origin, cloudsFolder)
            table.insert(Clouds, cloud)
        end
    end
end

function CloudGen.Update(dt)
    for _, cloud in ipairs(Clouds) do
        local drift = cloud.direction * CloudGen.Config.DriftSpeed * dt
        for _, puff in ipairs(cloud.puffs) do
            local floatY = math.sin(tick()*CloudGen.Config.FloatSpeed + cloud.floatOffset) * CloudGen.Config.FloatAmplitude
            puff.Position = puff.Position + drift + Vector3.new(0,floatY*dt,0)

            if puff.Position.Z < -CloudGen.Config.AreaSize then
                puff.Position = puff.Position + Vector3.new(0,0,CloudGen.Config.AreaSize*2)
            elseif puff.Position.Z > CloudGen.Config.AreaSize then
                puff.Position = puff.Position - Vector3.new(0,0,CloudGen.Config.AreaSize*2)
            end
        end
    end
end

return CloudGen
