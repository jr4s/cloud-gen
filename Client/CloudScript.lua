local CloudManager = require(game.ReplicatedStorage.Clouds.CloudManager)
CloudManager.Generate()

game:GetService("RunService").RenderStepped:Connect(function (dt)
    CloudManager.Update(dt)
end)