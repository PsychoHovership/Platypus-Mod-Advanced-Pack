AnimationType = {
    Default = 0,
    Looping = 1,
    PingPong = 2,
    PlayOnce = 3,
    PlayOnceAndHide = 4,
}

GameDifficulty = {
    Easy = 0,
    Medium = 1,
    Hard = 2,
    Nasty = 3,
    VeryEasy = -1,
}

ScoreSource = {
    Unknown = 0,
    AreaBonus = 1,
    EndBonus = 2,
    Kill = 3,
    KillGroupBonus = 4,
    Pickup = 5,
    SpeedBonus = 6,
}

---Generate a random floating point number between min (inclusive) and max (exclusive)
---@param min number
---@param max number
---@return number
function RandRangeF(min, max)
    return (max - min) * math.random() + min
end

---Generate a random number between min (inclusive) and max (exclusive)
---@param min number
---@param max number
---@return number
function RandRange(min, max)
    return math.random(min, max)
end

---Round "value" to the nearest integer value
---@param value number
---@return integer
function Round(value)
    if value >= 0 then
        return math.floor(value + 0.5)
    end
    return math.ceil(value - 0.5)
end

---@deprecated Use "Round" (uppercase) instead
function round(value)
    return Round(value)
end

---Clamp "value" between "min" and "max"
---@param value number
---@param min number
---@param max number
---@return number
function Clamp(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

---@deprecated Use "Clamp" (uppercase) instead
function clamp(value, min, max)
    return Clamp(value, min, max)
end

---Lerps between "min" and "max" using "t"
---@param min number
---@param max number
---@param t number
---@return number
function Lerp(min, max, t)
    return (max - min) * t + min
end

---Helper function for creating a child turret entity
---@param entity string
---@param xOff number
---@param yOff number
---@param parent BaseEntity
---@param waiter integer
---@return integer
function CreateTurret(entity, xOff, yOff, parent, waiter)
    local args = NewJSONObject()
    args.AddFieldInt("firewait", waiter)

    return SpawnEntityChild(entity, parent, {x=xOff, y=yOff}, args)
end