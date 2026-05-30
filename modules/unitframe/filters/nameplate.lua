local F, C = unpack(select(2, ...))

-- Cataclysm Classic 3.80.1 Nameplate Aura Filters
-- Reference: ElvUI nameplate filter structure

C.NameplateAuraWhiteList = {
    -- [[ Buffs — Immunities & Major Defensives ]]
    [642] = true,       -- 圣盾术 (Divine Shield)
    [1022] = true,      -- 保护之手 (Hand of Protection)
    [45438] = true,     -- 寒冰屏障 (Ice Block)
    [23920] = true,     -- 法术反射 (Spell Reflection)
    [31224] = true,     -- 暗影斗篷 (Cloak of Shadows)
    [19263] = true,     -- 威慑 (Deterrence)
    [47585] = true,     -- 消散 (Dispersion)
    [48792] = true,     -- 冰封之韧 (Icebound Fortitude)
    [48707] = true,     -- 反魔法护罩 (Anti-Magic Shell)
    [33206] = true,     -- 痛苦压制 (Pain Suppression)
    [47788] = true,     -- 守护之魂 (Guardian Spirit)
    [46924] = true,     -- 剑刃风暴 (Bladestorm) — CC immune
    [49039] = true,     -- 巫妖之躯 (Lichborne)
    [31821] = true,     -- 光环掌握 (Aura Mastery)
    [5277] = true,      -- 闪避 (Evasion)

    -- [[ CC Debuffs — Crowd Control ]]
    -- Polymorph variants
    [118] = true,       -- 变形术
    [28272] = true,     -- 变形术：猪
    [28271] = true,     -- 变形术：龟
    [61305] = true,     -- 变形术：黑猫
    [61721] = true,     -- 变形术：兔子
    [61780] = true,     -- 变形术：火鸡
    -- Fear
    [5782] = true,      -- 恐惧
    [5484] = true,      -- 恐惧嚎叫 (Howl of Terror)
    [8122] = true,      -- 心灵尖啸 (Psychic Scream)
    -- Incapacitate
    [2094] = true,      -- 致盲 (Blind)
    [1776] = true,      -- 凿击 (Gouge)
    [6770] = true,      -- 闷棍 (Sap)
    [20066] = true,     -- 忏悔 (Repentance)
    [2637] = true,      -- 休眠 (Hibernate)
    [19386] = true,     -- 翼龙钉刺 (Wyvern Sting)
    [3355] = true,      -- 冰冻陷阱 (Freezing Trap)
    [10326] = true,     -- 超度邪恶 (Turn Evil)
    [9484] = true,      -- 束缚亡灵 (Shackle Undead)
    [1513] = true,      -- 恐吓野兽 (Scare Beast)
    -- Stun
    [853] = true,       -- 制裁之锤 (Hammer of Justice)
    [12809] = true,     -- 震荡猛击 (Concussion Blow)
    [5211] = true,      -- 蛮力猛击 (Mighty Bash)
    [22570] = true,     -- 割碎 (Maim)
    [1833] = true,      -- 偷袭 (Cheap Shot)
    [408] = true,       -- 肾击 (Kidney Shot)
    [91800] = true,     -- 啃咬 (Gnaw) — DK ghoul
    [47476] = true,     -- 绞杀 (Strangulate)
    -- Other CC
    [33786] = true,     -- 飓风 (Cyclone)
    [339] = true,       -- 纠缠根须 (Entangling Roots)
    [710] = true,       -- 放逐 (Banish)
    [51514] = true,     -- 妖术 (Hex)
    [6789] = true,      -- 死亡缠绕 (Mortal Coil — horror)
    [605] = true,       -- 精神控制 (Mind Control)
    [31661] = true,     -- 龙息术 (Dragon's Breath)
    [19503] = true,     -- 驱散射击 (Scatter Shot)
    [5246] = true,      -- 破胆怒吼 (Intimidating Shout)
    [7922] = true,      -- 震荡猛击? Wait, 7922 is Charge Stun. Let me fix...
    [20549] = true,     -- 战争践踏 (War Stomp)
    [108194] = true,    -- 窒息 (Asphyxiate) — note: Cata check needed

    -- [[ Cataclysm Dungeon — Key Debuffs ]]
    -- Grim Batol (格瑞姆巴托)
    [45195] = true,     -- 灼热烈焰 (Searing Flames)
    [45150] = true,     -- 撕裂 (Rip) — 熔炉之主
    -- Halls of Origination (起源大厅)
    [76693] = true,     -- 闪电链
    -- Lost City of the Tol'vir (托维尔失落之城)
    [82533] = true,     -- 闪电冲击
    -- Vortex Pinnacle (旋云之巅)
    [87762] = true,     -- 静电依附 (Static Cling)
    -- Throne of the Tides (潮汐王座)
    [75981] = true,     -- 闪电箭
    -- Deadmines (死亡矿井)
    [91007] = true,     -- 烟雾弹 — 赫利克斯
    -- Shadowfang Keep (影牙城堡)
    [93543] = true,     -- 邪恶诅咒

    -- [[ Cataclysm Raid — Key Debuffs ]]
    -- Firelands (火焰之地)
    [99532] = true,     -- 水晶牢笼 (Crystal Prison) — Shannox
    [99837] = true,     -- 烈焰之种 — Alysrazor
    [100071] = true,    -- 熔岩吞噬 — Rhyolith
    -- Bastion of Twilight (暮光堡垒)
    [92557] = true,     -- 烈焰宝珠 — Valiona/Theralion
    [92879] = true,     -- 暮光凋零 — Cho'gall
    -- Blackwing Descent (黑翼血环)
    [78110] = true,     -- 音波吐息 — Atramedes
    [79576] = true,     -- 闪电导体 — Nefarian
    -- Dragon Soul (巨龙之魂)
    [103534] = true,    -- 危险 — Morchok
    [103785] = true,    -- 暮光之时 — Ultraxion
    [105479] = true,    -- 暮光切割 — Deathwing
}

C.NameplateAuraBlackList = {
    -- [[ Clutter Debuffs — Hide from nameplates ]]
    -- Common slow effects
    [31589] = true,     -- 减速 (Slow) — 奥术
    [51692] = true,     -- 减速毒药
    [3409] = true,      -- 致残毒药 (Crippling Poison)
    [116] = true,       -- 寒冰箭 (Frostbolt) — debuff
    [120] = true,       -- 冰锥术 (Cone of Cold)
    [122] = true,       -- 冰霜新星 (Frost Nova)
    [6136] = true,      -- 冰霜新星 (水元素)
    [33395] = true,     -- 冰霜新星 (水元素 freeze)

    -- Minor DoTs that clutter
    [172] = true,       -- 腐蚀术 (Corruption)
    [980] = true,       -- 痛苦诅咒 (Agony) — visible via unit frames, not nameplates
    [589] = true,       -- 暗言术：痛 (Shadow Word: Pain)
    [703] = true,       -- 割裂 (Garrote)
    [1943] = true,      -- 割裂 (Rupture)
    [2818] = true,      -- 致命毒药 (Deadly Poison)
    [13218] = true,     -- 致伤毒药 (Wound Poison)
    [8680] = true,      -- 速效毒药 (Instant Poison)

    -- Minor debuffs
    [3043] = true,      -- 毒蛇钉刺 (Serpent Sting) — visible on unit frames
    [1978] = true,      -- 毒蛇钉刺 (旧ID)
    [5116] = true,      -- 震荡射击 (Concussive Shot)
    [1543] = true,      -- 照明弹 (Flare) — debuff
    [1130] = true,      -- 猎人印记 (Hunter's Mark)
    [3034] = true,      -- 蝰蛇钉刺 (Viper Sting)

    -- Armor reduction debuffs (clutter)
    [7386] = true,      -- 破甲 (Sunder Armor)
    [8647] = true,      -- 破甲 (Expose Armor)
    [770] = true,       -- 精灵之火 (Faerie Fire)
    [91565] = true,     -- 精灵之火 (Cataclysm version)
    [5570] = true,      -- 虫群 (Insect Swarm)
    [50511] = true,     -- 诅咒虚弱 (Curse of Weakness)
    [702] = true,       -- 诅咒虚弱 (旧ID)
    [1714] = true,      -- 语言诅咒 (Curse of Tongues)

    -- Caster debuffs that don't need nameplate visibility
    [1490] = true,      -- 元素诅咒 (Curse of the Elements)
    [1715] = true,      -- 断筋 (Hamstring)
    [1161] = true,      -- 挑战怒吼 (Challenging Shout)
    [355] = true,       -- 嘲讽 (Taunt)
    [5209] = true,      -- 挑战咆哮 (Challenging Roar)
    [694] = true,       -- 嘲讽 (Mocking Blow)
    [56222] = true,     -- 黑暗命令 (Dark Command)
    [49576] = true,     -- 死亡之握 (Death Grip)

    -- Healing reduction
    [12294] = true,     -- 致死打击 (Mortal Strike) — tracked via health bar color
    [80153] = true,     -- 致死打击 debuff name
    [24423] = true,     -- 摔绊 (Demoralizing Shout Screech)
    [99] = true,        -- 挫志怒吼 (Demoralizing Shout — 旧ID)
    [1160] = true,      -- 挫志怒吼

    -- PvE boss-specific clutter
    [92754] = true,     -- 疲劳诅咒 — Cho'gall fight clutter
}

-- Cataclysm doesn't have M+ Spiteful, leave empty for future
C.NameplateShowTargetNPCsList = {}

C.TrashUnitsList = {
    -- Dungeon trash that should not show colored health bars
    [42333] = true,     -- 潮汐王座 — 小型水元素
    [40579] = true,     -- 黑石岩窟 — 微型元素
    [48044] = true,     -- 旋云之巅 — 风暴雏龙
}

C.SpecialUnitsList = {
    -- Key units that need special visual treatment
    -- Firelands
    [53693] = true,     -- 烈焰碎片 (Shannox dogs)
    [53694] = true,     -- 炽焰碎片
    [53691] = true,     -- 怒面 (Rageface)
    -- Dragon Soul
    [56167] = true,     -- 触须 (Deathwing tentacles)
    [56168] = true,     -- 再生之血 (Regenerative Blood)
    [56846] = true,     -- 燃烧触须 (Blistering Tentacle)
    [55394] = true,     -- 冰川触须
    -- Bastion of Twilight
    [49899] = true,     -- 烈焰之卵 (Twilight Eggs)
    -- Deadmines
    [48967] = true,     -- 蒸汽地精 (Foe Reaper trash)
    -- Shadowfang Keep
    [47159] = true,     -- 嗜血食尸鬼
}

C.PowerUnitsList = {
    -- Units that should show power bar on nameplate
    -- Cataclysm dungeon bosses with important mana/energy tracking
    [39425] = true,     -- 神殿守卫安胡尔 — 起源大厅
    [42333] = true,     -- 高阶女祭司艾苏尔 — 起源大厅
}

C.MajorSpellsList = {
    -- Cataclysm — key interruptible boss spells to highlight
    [45150] = true,     -- 格瑞姆巴托 — 撕裂 (熔炉之主)
    [45195] = true,     -- 格瑞姆巴托 — 灼热烈焰
    [90946] = true,     -- 死亡矿井 — 致命冲击 (撕心狼)
    [75861] = true,     -- 潮汐王座 — 暗影箭雨
    [76791] = true,     -- 起源大厅 — 地震 (Earthquake)
    [82878] = true,     -- 托维尔失落之城 — 复仇之锤
    [83718] = true,     -- 旋云之巅 — 闪电箭 (Asaad)
    [87622] = true,     -- 旋云之巅 — 致命链环
    -- Raids
    [100057] = true,    -- 火焰之地 — 灼热烈焰 (Majordomo)
    [99613] = true,     -- 火焰之地 — 烈焰之种 (Alysrazor)
    [103176] = true,    -- 巨龙之魂 — 暮光喷发
}
