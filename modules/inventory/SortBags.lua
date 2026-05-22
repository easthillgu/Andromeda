local F, C, L = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

local _G = getfenv(0)

local GetBagName = C_Container and C_Container.GetBagName or GetBagName
local PickupContainerItem = C_Container and C_Container.PickupContainerItem or PickupContainerItem
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink

CreateFrame('GameTooltip', 'AndromedaSortBagsTooltip', nil, 'GameTooltipTemplate')

BAG_CONTAINERS = {0, 1, 2, 3, 4}
BANK_BAG_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

function _G.SortBags()
    CONTAINERS = {unpack(BAG_CONTAINERS)}
    Start()
end

function _G.SortBankBags()
    CONTAINERS = {unpack(BANK_BAG_CONTAINERS)}
    Start()
end

function _G.GetSortBagsRightToLeft(enabled)
    return SortBagsRightToLeft
end

function _G.SetSortBagsRightToLeft(enabled)
    _G.SortBagsRightToLeft = enabled and 1 or nil
end

local function set(...)
    local t = {}
    local n = select('#', ...)
    for i = 1, n do
        t[select(i, ...)] = true
    end
    return t
end

local SPECIAL = set(5462, 9173, 11511, 13347, 32542, 33219, 38233, 40110, 43499, 43824, 198647)
local KEYS = set(9240, 11511, 12324, 12384, 13544, 16309, 17191, 20402)
local TOOLS = set(6218, 6339, 11130, 11145, 16207, 22461, 22462, 22463, 5060, 7005, 12709, 19727, 5956, 2901, 6219, 10498, 9149, 15846, 6256, 6365, 6366, 6367, 12225, 19022, 25978, 19970, 20815, 20824, 44452, 36898, 44451, 45991, 45992, 44050, 39505)

local function mergeSets(...)
    local result = {}
    for i = 1, select('#', ...) do
        local set = select(i, ...)
        for k, v in pairs(set) do
            result[k] = v
        end
    end
    return result
end

local CLASSES = {
    {
        containers = {21193, 21194, 21195, 21313, 22243, 22244, 21340, 21341, 21342, 21872, 41597},
        items = set(6265),
    },
    {
        containers = {2101, 5439, 7278, 11362, 3573, 3605, 7371, 8217, 2662, 19319, 18714, 29143, 29144, 34105, 34100, 44448},
        items = set(2512, 2514, 2515, 3029, 3030, 3031, 3464, 9399, 10579, 11285, 12654, 18042, 19316, 24412, 24417, 28053, 28056, 30319, 30611, 31737, 31949, 32760, 33803, 34581, 41586, 41165, 52021),
    },
    {
        containers = {2102, 5441, 7279, 11363, 3574, 3604, 7372, 8218, 2663, 19320, 29118, 34106, 34099, 44447},
        items = set(2516, 2519, 3033, 3465, 4960, 5568, 8067, 8068, 8069, 10512, 10513, 11284, 11630, 13377, 15997, 19317, 23772, 23773, 28060, 28061, 30612, 31735, 32761, 32882, 32883, 34582, 41584, 41164, 52020),
    },
    {
        containers = {22246, 22248, 22249, 30748, 21858, 41598},
        items = mergeSets(
            set(6217, 6218, 6222, 6338, 6339, 6342, 6343, 6344, 6345, 6346, 6347, 6348, 6349, 6375, 6376, 6377, 10938, 10939, 10940, 10978, 10998, 11038, 11039, 11081, 11082, 11083, 11084, 11098, 11101, 11128, 11130, 11134, 11135, 11137, 11138, 11139, 11144, 11145, 11150, 11151, 11152, 11163, 11164, 11165, 11166, 11167, 11168, 11174, 11175, 11176, 11177, 11178),
            set(11202, 11203, 11204, 11205, 11206, 11207, 11208, 11223, 11224, 11225, 11226, 11813, 14343, 14344, 16202, 16203, 16204, 16206, 16207, 16214, 16215, 16216, 16217, 16218, 16219, 16220, 16221, 16222, 16223, 16224, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252, 16253, 16254, 16255, 17725, 18259, 18260, 19444, 19445, 19446),
            set(19447, 19448, 19449, 20725, 20726, 20727, 20728, 20729, 20730, 20731, 20732, 20733, 20734, 20735, 20736, 20752, 20753, 20754, 20755, 20756, 20757, 20758, 22392, 22445, 22446, 22447, 22448, 22449, 22450, 22461, 22462, 22463, 22530, 22531, 22532, 22533, 22534, 22535, 22536, 22537, 22538, 22539, 22540, 22541, 22542, 22543, 22544, 22545, 22547, 22548),
            set(22551, 22552, 22553, 22554, 22555, 22556, 22557, 22558, 22559, 22560, 22561, 22562, 22563, 22564, 22565, 24000, 24003, 25843, 25844, 25845, 25848, 25849, 28270, 28271, 28272, 28273, 28274, 28276, 28277, 28279, 28280, 28281, 28282, 33148, 33149, 33150, 33151, 33152, 33153, 33165, 33307, 34052, 34053, 34054, 34055, 34056, 34057, 34872),
            set(35297, 35298, 35299, 35498, 35500, 35756, 36837, 36838, 36839, 36840, 36898, 37326, 37328, 37329, 37330, 37331, 37332, 37333, 37334, 37335, 37336, 37337, 37338, 37339, 37340, 37341, 37342, 37343, 37344, 37345, 37346, 37347, 37348, 37349, 41741, 41745, 44451, 44452, 44471, 44472, 44473, 44483, 44484, 44485, 44486, 44487, 44488, 44489),
            set(44490, 44491, 44492, 44494, 44495, 44496, 44498, 44944, 44945, 45050, 45059, 46027, 46348, 50406, 186683)
        ),
    },
    {
        containers = {22250, 22251, 22252, 38225, 45773},
        items = set(765, 785, 1401, 2263, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 5013, 5056, 5168, 8831, 8836, 8838, 8839, 8845, 8846, 11018, 11020, 11022, 11024, 11040, 11514, 11951, 11952, 13463, 13464, 13465, 13466, 13467, 13468, 16205, 16208, 17034, 17035, 17036, 17037, 17038, 17760, 18297, 19727, 22094, 22147, 22710, 22785, 22786, 22787, 22788, 22789, 22790, 22791, 22792, 22793, 22794, 22795, 22797, 23329, 23501, 23788, 24245, 24246, 24401, 31300, 32468, 36901, 36902, 36903, 36904, 36905, 36906, 36907, 36908, 37600, 37921, 39969, 39970, 44614),
    },
    {
        containers = {29540, 30746, 38347},
        items = set(756, 778, 1819, 1893, 1959, 2770, 2771, 2772, 2775, 2776, 2798, 2835, 2836, 2838, 2840, 2841, 2842, 2901, 3340, 3575, 3576, 3577, 3858, 3859, 3860, 3861, 4278, 5833, 6037, 7911, 7912, 10620, 11370, 11371, 12359, 12360, 12365, 12655, 17771, 18562, 20723, 22202, 22203, 23424, 23425, 23426, 23427, 23445, 23446, 23447, 23448, 23449, 23573, 32464, 35128, 36909, 36910, 36911, 36912, 36913, 36914, 36915, 36916, 37663, 37706, 41163, 45201, 5956, 40772, 40892, 40893),
    },
    {
        containers = {34482, 34490, 38399},
        items = mergeSets(
            set(783, 2304, 2313, 2318, 2319, 2320, 2321, 2324, 2325, 2406, 2407, 2408, 2409, 2604, 2605, 2934, 3182, 3824, 4096, 4231, 4232, 4233, 4234, 4235, 4236, 4265, 4289, 4291, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4304, 4337, 4340, 4341, 4342, 4461, 5082, 5083, 5373, 5637, 5784, 5785, 5786, 5787, 5788, 5789, 5972, 5973, 5974, 6260, 6261, 6470, 6471, 6474, 6475, 6476, 6710, 7005, 7070, 7071, 7286, 7287, 7288, 7289, 7290, 7360, 7361, 7362, 7363, 7364, 7392, 7449, 7450, 7451, 7452, 7453, 7613, 8150, 8152, 8154, 8165, 8167, 8169, 8170, 8171, 8172, 8173, 8343, 8384, 8385, 8386, 8387, 8388, 8389, 8390, 8395, 8397, 8398, 8399, 8400, 8401, 8402, 8403, 8404, 8405, 8406, 8407, 8408, 8409),
            set(10290, 11512, 12607, 12709, 12731, 13287, 13288, 14341, 14635, 15407, 15408, 15409, 15410, 15412, 15414, 15415, 15416, 15417, 15419, 15564, 15725, 15726, 15727, 15728, 15729, 15730, 15731, 15732, 15733, 15734, 15735, 15737, 15738, 15739, 15740, 15741, 15742, 15743, 15744, 15745, 15746, 15747, 15748, 15749, 15751, 15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15779, 15781, 17012, 17022, 17023, 17025, 17056, 17722, 17967, 17968, 18239, 18240, 18512, 18514, 18515, 18516, 18517, 18518, 18662, 18731, 18949, 19326, 19327, 19328, 19329, 19330, 19331, 19332, 19333, 19767, 19768, 19769, 19770, 19771, 19772, 19773, 19901, 20253, 20254, 20381, 20382, 20498, 20499, 20500, 20501, 20506, 20507, 20508, 20509, 20510, 20511, 20576, 21548, 21887, 22692, 22694, 22695, 22696, 22697, 22698, 22769, 22770, 22771, 23793, 25649, 25650, 25651, 25652, 25699, 25700, 25707, 25708, 25720, 25721, 25722, 25725, 25726, 25728, 25729, 25730, 25731, 25732, 25733, 25734, 25735, 25736, 25737, 25738, 25739, 25740, 25741, 25742, 25743, 29213, 29214, 29215, 29217, 29218, 29219, 29483, 29485, 29486, 29487, 29488, 29528, 29529, 29530, 29531, 29532, 29533)
        ),
    },
    {
        containers = {24270, 30747},
        items = set(774, 818, 1206, 1210, 1529, 1705, 3864, 5498, 5500, 7909, 7910, 7971, 11382, 11754, 12361, 12363, 12364, 12799, 12800, 13926, 18335, 19774, 20815, 20824, 21929, 22459, 22460, 23077, 23079, 23094, 23095, 23096, 23097, 23098, 23099, 23100, 23101, 23103, 23104, 23105, 23106, 23107, 23108, 23109, 23110, 23111, 23112, 23113, 23114, 23115, 23116, 23117, 23118, 23119, 23120, 23121, 23158, 23234, 23436, 23437, 23438, 23439, 23440, 23441, 24027, 24028, 24029, 24030, 24031, 24032, 24033, 24035, 24036, 24037, 24039, 24047, 24048, 24050, 24051, 24052, 24053, 24054, 24055, 24056, 24057, 24058, 24059, 24060, 24061, 24062, 24065, 24066, 24067, 24478, 24479, 25867, 25868, 25890, 25893, 25894, 25895, 25896, 25897, 25898, 25899, 25901, 27679, 27777, 27785, 27786, 27809, 27812, 27820, 28118, 28119, 28120, 28123, 28290, 28360, 28361, 28362, 28363, 28458, 28459, 28460, 28461, 28462, 28463, 28464, 28465, 28466, 28467, 28468, 28469, 28470, 28556, 28557, 28595),
    },
}

local function GetItemInfo(bagID, slotID)
    local itemInfo = GetContainerItemInfo(bagID, slotID)
    if not itemInfo then return end
    local itemLink = GetContainerItemLink(bagID, slotID)
    local itemName, itemLink, quality, itemLevel, reqLevel, itemType, itemSubType, stackCount, equipLoc, iconFileDataID, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
    return {
        bagID = bagID,
        slotID = slotID,
        itemID = itemInfo.itemID,
        itemLink = itemLink,
        quality = quality,
        itemLevel = itemLevel,
        itemType = itemType,
        itemSubType = itemSubType,
        stackCount = itemInfo.stackCount,
        maxStack = itemInfo.maxStack,
        equipLoc = equipLoc,
        classID = classID,
        subclassID = subclassID,
        bindType = bindType,
    }
end

local function IsItemInClass(itemID, classData)
    if classData.items[itemID] then return true end
    for _, containerID in pairs(classData.containers) do
        if containerID == itemID then return true end
    end
    return false
end

local function GetItemClassIndex(itemID)
    for i, classData in ipairs(CLASSES) do
        if IsItemInClass(itemID, classData) then return i end
    end
    return #CLASSES + 1
end

local function GetItemCategory(item)
    if not item then return 99 end

    local itemID = item.itemID
    if SPECIAL[itemID] then return 0 end
    if KEYS[itemID] then return 1 end
    if TOOLS[itemID] then return 2 end

    local classIndex = GetItemClassIndex(itemID)
    if classIndex <= #CLASSES then return classIndex + 2 end

    if item.classID == LE_ITEM_CLASS_WEAPON then return 12 end
    if item.classID == LE_ITEM_CLASS_ARMOR then return 13 end

    return 99
end

local function CompareItems(a, b)
    local categoryA = GetItemCategory(a)
    local categoryB = GetItemCategory(b)

    if categoryA ~= categoryB then
        return categoryA < categoryB
    end

    if a.quality ~= b.quality then
        return a.quality > b.quality
    end

    if a.itemLevel ~= b.itemLevel then
        return a.itemLevel > b.itemLevel
    end

    if a.classID ~= b.classID then
        return a.classID < b.classID
    end

    if a.subclassID ~= b.subclassID then
        return a.subclassID < b.subclassID
    end

    if a.equipLoc ~= b.equipLoc then
        return a.equipLoc < b.equipLoc
    end

    return a.itemID < b.itemID
end

local function GetBagItems()
    local items = {}
    for _, bagID in ipairs(CONTAINERS) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            local item = GetItemInfo(bagID, slotID)
            if item then
                tinsert(items, item)
            end
        end
    end
    return items
end

local function Start()
    local items = GetBagItems()
    table.sort(items, CompareItems)

    local slotIndex = 1
    for _, bagID in ipairs(CONTAINERS) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if slotIndex <= #items then
                local item = items[slotIndex]
                if item.bagID ~= bagID or item.slotID ~= slotID then
                    PickupContainerItem(item.bagID, item.slotID)
                    PickupContainerItem(bagID, slotID)
                end
                slotIndex = slotIndex + 1
            end
        end
    end
end


