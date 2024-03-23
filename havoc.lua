local bxhnz7tp5bge7wvu = bxhnz7tp5bge7wvu_interface
local SB = d3jzezbu6wmhm3y7

local function is_available(spell)
  return IsSpellKnown(spell, false) or IsPlayerSpell(spell)
end

local function has_buff_to_steal_or_purge(unit)
  local has_buffs = false
  for i=1,40 do 
    local name,_,_,_,_,_,_,can_steal_or_purge = UnitAura(unit.unitID, i)
    if name and can_steal_or_purge then
      has_buffs = true
      break
    end
  end
  return has_buffs
end

local function gcd()
  if not player.alive then return end
  if player.casting() or player.channeling() then return end
  if SpellIsTargeting() then return end
    
  if GetCVar("nameplateShowEnemies") == '0' then
    SetCVar("nameplateShowEnemies", 1)
  end
  
  cancel_queued_spell()
  
  local healing_potion = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_healing_potion', false)
  local trinket_13 = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_trinket_13', false)
  local trinket_14 = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_trinket_14', false)
  
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if healing_potion and GetItemCooldown(191380) == 0 and player.health.effective < 10 then
    macro('/use Refreshing Healing Potion')
  end
    
  if target.enemy and target.alive then
    local in_5_range = target.distance <= 5
            
    --actions+=/disrupt,if=target.debuff.casting.react
    if toggle('interrupts', false) and target.interrupt(70) and castable(SB.Disrupt) and target.distance <= 10 then
      return cast(SB.Disrupt, target)
    end
        
    --actions+=/use_item,slot=trinket1
    --actions+=/use_item,slot=trinket2
    local start, duration, enable = GetInventoryItemCooldown("player", 13)
    local trinket13_id = GetInventoryItemID("player", 13)
    if in_5_range and trinket_13 and enable == 1 and start == 0 then
      return macro('/use 13')
    end
    
    start, duration, enable = GetInventoryItemCooldown("player", 14)
    local trinket14_id = GetInventoryItemID("player", 14)
    if in_5_range and trinket_14 and enable == 1 and start == 0 then
      return macro('/use 14')
    end
  end
end

local function combat()
  if not player.alive then return end
  if player.casting() or player.channeling() then return end
  if SpellIsTargeting() then return end
    
  if GetCVar("nameplateShowEnemies") == '0' then
    SetCVar("nameplateShowEnemies", 1)
  end
  
  cancel_queued_spell()
  
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if healing_potion and GetItemCooldown(191380) == 0 and player.health.effective < 10 then
    macro('/use Refreshing Healing Potion')
  end
  
  local healing_potion = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_healing_potion', false)
  local trinket_13 = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_trinket_13', false)
  local trinket_14 = bxhnz7tp5bge7wvu.settings.fetch('hav_nikopol_trinket_14', false)
  
  local enemies_in_8y = enemies.count(function (unit)
    return unit.alive and unit.distance <= 8
  end)

  local ability_to_cast = Hekili_GetRecommendedAbility( "Primary", 1 )
  
  if modifier.lshift then
    if is_available(SB.ChaosNova) and castable(SB.ChaosNova) then
      return cast(SB.ChaosNova, 'ground')
    end
    
    if target.enemy and target.alive and is_available(SB.Imprison) and castable(SB.Imprison) then
      return cast(SB.Imprison, target)
    end
  end
  
  if modifier.lcontrol and is_available(SB.SigilofMisery) and castable(SB.SigilofMisery) then
    return cast(SB.SigilofMisery, player)
  end
   
  if target.enemy and target.alive then
    local in_5_range = target.distance <= 5
    
    --actions=auto_attack
    auto_attack()
       
    --actions+=/disrupt,if=target.debuff.casting.react
    if toggle('interrupts', false) and target.interrupt(70) and castable(SB.Disrupt) and target.distance <= 10 then
      return cast(SB.Disrupt, target)
    end
    
    if in_5_range and toggle('all_interrupts', false) and spell(SB.Disrupt).cooldown > 0 and target.interrupt(70) then     
      if is_available(SB.ChaosNova) and castable(SB.ChaosNova) then
        return cast(SB.ChaosNova, player)
      end
    end
    
    if toggle('dispell', false) and is_available(SB.ConsumeMagic) and castable(SB.ConsumeMagic) and target.distance <= 30 and has_buff_to_steal_or_purge(target) then
      return cast(SB.ConsumeMagic)
    end
    
    --actions+=/use_item,slot=trinket1
    --actions+=/use_item,slot=trinket2
    local start, duration, enable = GetInventoryItemCooldown("player", 13)
    local trinket13_id = GetInventoryItemID("player", 13)
    if in_5_range and trinket_13 and enable == 1 and start == 0 then
      return macro('/use 13')
    end
    
    start, duration, enable = GetInventoryItemCooldown("player", 14)
    local trinket14_id = GetInventoryItemID("player", 14)
    if in_5_range and trinket_14 and enable == 1 and start == 0 then
      return macro('/use 14')
    end
    
    if in_5_range and ability_to_cast and ability_to_cast > 0 and ability_to_cast ~= SB.FelRush and ability_to_cast ~= SB.VengefulRetreat then
      return cast(ability_to_cast, player)
    end
  end
end

local function resting()
end

local function interface()
    local havoc_gui = {
    key = 'hav_nikopol',
    title = 'havoc',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Havoc Settings' },
      { type = 'rule' },   
      { type = 'text', text = 'Healing Settings' },
      { key = 'healing_potion', type = 'checkbox', text = 'Refreshing Healing Potion', desc = 'Use Refreshing Healing Potion when below 10% health', default = false },
      { type = 'rule' },  
      { type = 'text', text = 'Items' },
      { key = 'trinket_13', type = 'checkbox', text = '13', desc = 'use first trinket', default = false },
      { key = 'trinket_14', type = 'checkbox', text = '14', desc = 'use second trinket', default = false },
      { key = 'main_hand', type = 'checkbox', text = '16', desc = 'use main_hand', default = false },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(havoc_gui)
  
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'dispell',
    label = 'Auto Dispell',
    on = {
      label = 'DSP',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'dsp',
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    }
  })
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'all_interrupts',
    label = 'Use all interrupts',
    on = {
      label = 'AINT',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'aint',
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    }
  })
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'bxhnz7tp5bge7wvu_icon',
    on = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.cyan,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_cyan
    },
    off = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        configWindow.parent:Show()
      end
    end
  })
end

bxhnz7tp5bge7wvu.rotation.register({
  spec = bxhnz7tp5bge7wvu.rotation.classes.demonhunter.havoc,
  name = 'hav_nikopol',
  label = 'Havoc by Nikopol',
  gcd = gcd,
  combat = combat,
  resting = resting,
  interface = interface
})
