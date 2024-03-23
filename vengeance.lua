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
  
  local reserve_infernal_strike_charges = bxhnz7tp5bge7wvu.settings.fetch('ven_nikopol_reserve_infernal_strike_charges', 1)
  
  if target.enemy and target.alive then
    local in_5_range = target.distance <= 5
    
    --actions+=/disrupt,if=target.debuff.casting.react
    if toggle('interrupts', false) and target.interrupt(50) and castable(SB.Disrupt) and target.distance <= 10 then
      return cast(SB.Disrupt, target)
    end
        
    --actions+=/infernal_strike,use_off_gcd=1
    if in_5_range and castable(SB.InfernalStrike) and spell(SB.InfernalStrike).charges > reserve_infernal_strike_charges then
      return cast(SB.InfernalStrike, player)
    end
    
    --actions+=/demon_spikes,use_off_gcd=1,if=!buff.demon_spikes.up&!cooldown.pause_action.remains
    if in_5_range and castable(SB.DemonSpikes) and player.buff(SB.DemonSpikes).down then
      return cast(SB.DemonSpikes)
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
  
  local reserve_infernal_strike_charges = bxhnz7tp5bge7wvu.settings.fetch('ven_nikopol_reserve_infernal_strike_charges', 1)
  local healing_potion = bxhnz7tp5bge7wvu.settings.fetch('ven_nikopol_healing_potion', false)
  local trinket_13 = bxhnz7tp5bge7wvu.settings.fetch('ven_nikopol_trinket_13', false)
  local trinket_14 = bxhnz7tp5bge7wvu.settings.fetch('ven_nikopol_trinket_14', false)
  
  local soul_fragments = player.buff(SB.SoulFragments).count
  --actions.precombat+=/variable,name=spirit_bomb_soul_fragments_not_in_meta,op=setif,value=4,value_else=5,condition=talent.fracture
  local spirit_bomb_soul_fragments_not_in_meta = is_available(SB.Fracture) and 4 or 5
  --actions.precombat+=/variable,name=spirit_bomb_soul_fragments_in_meta,op=setif,value=3,value_else=4,condition=talent.fracture
  local spirit_bomb_soul_fragments_in_meta = is_available(SB.Fracture) and 3 or 4
  --actions.precombat+=/variable,name=vulnerability_frailty_stack,op=setif,value=1,value_else=0,condition=talent.vulnerability
  local vulnerability_frailty_stack = is_available(SB.Vulnerability) and 1 or 0
  --actions.precombat+=/variable,name=cooldown_frailty_requirement_st,op=setif,value=6*variable.vulnerability_frailty_stack,value_else=variable.vulnerability_frailty_stack,condition=talent.soulcrush
  local cooldown_frailty_requirement_st = is_available(SB.SoulCrush) and 6 * vulnerability_frailty_stack or vulnerability_frailty_stack
  --actions.precombat+=/variable,name=cooldown_frailty_requirement_aoe,op=setif,value=5*variable.vulnerability_frailty_stack,value_else=variable.vulnerability_frailty_stack,condition=talent.soulcrush
  local cooldown_frailty_requirement_aoe = is_available(SB.SoulCrush) and 5 * vulnerability_frailty_stack or vulnerability_frailty_stack
  
  local enemies_in_8y = enemies.count(function (unit)
    return unit.alive and unit.distance <= 8
  end)

  if modifier.lshift and is_available(SB.ChaosNova) and castable(SB.ChaosNova) then
    return cast(SB.ChaosNova, 'ground')
  end
  
  if modifier.lcontrol and is_available(SB.SigilofSilence) and castable(SB.SigilofSilence) then
    return cast(SB.SigilofSilence, 'ground')
  end

  if target.enemy and target.alive then
    local in_5_range = target.distance <= 5
    
    --actions=auto_attack
    auto_attack()
    
    --actions+=/disrupt,if=target.debuff.casting.react
    if toggle('interrupts', false) and target.interrupt(50) and castable(SB.Disrupt) and target.distance <= 10 then
      return cast(SB.Disrupt, target)
    end
    
    if in_5_range and toggle('all_interrupts', false) and spell(SB.Disrupt).cooldown > 0 and target.interrupt(50) then
      if is_available(SB.SigilofSilence) and castable(SB.SigilofSilence) then
        return cast(SB.SigilofSilence, player)
      end
      
      if is_available(SB.ChaosNova) and castable(SB.ChaosNova) then
        return cast(SB.ChaosNova, player)
      end
    end
    
    if toggle('dispell', false) and is_available(SB.ConsumeMagic) and castable(SB.ConsumeMagic) and target.distance <= 30 and has_buff_to_steal_or_purge(target) then
      return cast(SB.ConsumeMagic)
    end
    
    --actions+=/infernal_strike,use_off_gcd=1
    if in_5_range and castable(SB.InfernalStrike) and spell(SB.InfernalStrike).charges > reserve_infernal_strike_charges then
      return cast(SB.InfernalStrike, player)
    end
    
    --actions+=/demon_spikes,use_off_gcd=1,if=!buff.demon_spikes.up&!cooldown.pause_action.remains
    if in_5_range and castable(SB.DemonSpikes) and player.buff(SB.DemonSpikes).down then
      return cast(SB.DemonSpikes)
    end
    
    --actions+=/metamorphosis
    if toggle('cooldowns', false) and in_5_range and castable(SB.Metamorphosis) then
      return cast(SB.Metamorphosis)
    end
    
    --actions+=/fel_devastation,if=!talent.fiery_demise.enabled
    if in_5_range and castable(SB.FelDevastation) and not is_available(SB.FieryDemise) then
      return cast(SB.FelDevastation, target)
    end
    
    --actions+=/fiery_brand,if=!talent.fiery_demise.enabled&!dot.fiery_brand.ticking
    if in_5_range and is_available(SB.FieryBrand) and castable(SB.FieryBrand) and not is_available(SB.FieryDemise) and target.debuff(SB.FieryBrandDebuff).down then
      return cast(SB.FieryBrand, target)
    end
    
    --actions+=/bulk_extraction
    if in_5_range and is_available(SB.BulkExtraction) and castable(SB.BulkExtraction) then
      return cast(SB.BulkExtraction)
    end
    
    --actions+=/potion
    --actions+=/use_item,slot=trinket1
    --actions+=/use_item,slot=trinket2
    local start, duration, enable = GetInventoryItemCooldown("player", 13)
    local trinket13_id = GetInventoryItemID("player", 13)
    if in_5_range and trinket_13 and enable == 1 and start == 0
      and (trinket13_id ~= SB.BurgeoningSeed or trinket13_id == SB.BurgeoningSeed and player.buff(SB.BrimmingLifePodBuff).up) then
      return macro('/use 13')
    end
    
    start, duration, enable = GetInventoryItemCooldown("player", 14)
    local trinket14_id = GetInventoryItemID("player", 14)
    if in_5_range and trinket_14 and enable == 1 and start == 0 
      and (trinket14_id ~= SB.BurgeoningSeed or trinket14_id == SB.BurgeoningSeed and player.buff(SB.BrimmingLifePodBuff).up) then
      return macro('/use 14')
    end
    
    --actions+=/variable,name=the_hunt_on_cooldown,value=talent.the_hunt&cooldown.the_hunt.remains|!talent.the_hunt
    local the_hunt_on_cooldown = is_available(SB.TheHunt) and spell(SB.TheHunt).cooldown > 0 or not is_available(SB.TheHunt)
    
    --actions+=/variable,name=elysian_decree_on_cooldown,value=talent.elysian_decree&cooldown.elysian_decree.remains|!talent.elysian_decree
    local elysian_decree_on_cooldown = is_available(SB.ElysianDecree) and spell(SB.ElysianDecree).cooldown > 0 or not is_available(SB.ElysianDecree)

    --actions+=/variable,name=soul_carver_on_cooldown,value=talent.soul_carver&cooldown.soul_carver.remains|!talent.soul_carver
    local soul_carver_on_cooldown = is_available(SB.SoulCarver) and spell(SB.SoulCarver).cooldown > 0 or not is_available(SB.SoulCarver)
    
    --actions+=/variable,name=fel_devastation_on_cooldown,value=talent.fel_devastation&cooldown.fel_devastation.remains|!talent.fel_devastation
    local fel_devastation_on_cooldown = is_available(SB.FelDevastation) and spell(SB.FelDevastation).cooldown > 0 or not is_available(SB.FelDevastation)
    
    --actions+=/variable,name=fiery_demise_fiery_brand_is_ticking_on_current_target,value=talent.fiery_brand&talent.fiery_demise&dot.fiery_brand.ticking
    local fiery_demise_fiery_brand_is_ticking_on_current_target = is_available(SB.FieryBrand) and is_available(SB.FieryDemise) and target.debuff(SB.FieryBrandDebuff).up
    
    --actions+=/variable,name=fiery_demise_fiery_brand_is_not_ticking_on_current_target,value=talent.fiery_brand&((talent.fiery_demise&!dot.fiery_brand.ticking)|!talent.fiery_demise)
    local fiery_demise_fiery_brand_is_not_ticking_on_current_target = is_available(SB.FieryBrand) and (is_available(SB.FieryDemise) and target.debuff(SB.FieryBrandDebuff).down or not is_available(SB.FieryDemise))
    
    local brand_is_ticking_on_any_target = enemies.match(function (unit)
      return unit.alive and unit.combat and unit.debuff(SB.FieryBrandDebuff).up
    end)
    --actions+=/variable,name=fiery_demise_fiery_brand_is_ticking_on_any_target,value=talent.fiery_brand&talent.fiery_demise&active_dot.fiery_brand_dot
    local fiery_demise_fiery_brand_is_ticking_on_any_target = is_available(SB.FieryBrand) and is_available(SB.FieryDemise) and brand_is_ticking_on_any_target
    
    --actions+=/variable,name=fiery_demise_fiery_brand_is_not_ticking_on_any_target,value=talent.fiery_brand&((talent.fiery_demise&!active_dot.fiery_brand_dot)|!talent.fiery_demise)
    local fiery_demise_fiery_brand_is_not_ticking_on_any_target = is_available(SB.FieryBrand) and (is_available(SB.FieryDemise) and not brand_is_ticking_on_any_target or not is_available(SB.FieryDemise))
    --actions+=/variable,name=spirit_bomb_soul_fragments,op=setif,value=variable.spirit_bomb_soul_fragments_in_meta,value_else=variable.spirit_bomb_soul_fragments_not_in_meta,condition=buff.metamorphosis.up
    local spirit_bomb_soul_fragments = player.buff(SB.Metamorphosis).up and spirit_bomb_soul_fragments_in_meta or spirit_bomb_soul_fragments_not_in_meta
    --actions+=/variable,name=cooldown_frailty_requirement,op=setif,value=variable.cooldown_frailty_requirement_aoe,value_else=variable.cooldown_frailty_requirement_st,condition=talent.spirit_bomb&(spell_targets.spirit_bomb>1|variable.fiery_demise_fiery_brand_is_ticking_on_any_target)
    local cooldown_frailty_requirement = (is_available(SB.SpiritBomb) and (enemies_in_8y > 1 or fiery_demise_fiery_brand_is_ticking_on_any_target)) and cooldown_frailty_requirement_aoe or cooldown_frailty_requirement_st
    
    --actions+=/the_hunt,if=variable.fiery_demise_fiery_brand_is_not_ticking_on_current_target&debuff.frailty.stack>=variable.cooldown_frailty_requirement
    if in_5_range and is_available(SB.TheHunt) and castable(SB.TheHunt) and fiery_demise_fiery_brand_is_not_ticking_on_current_target and target.debuff(SB.FrailtyDebuff).count >= cooldown_frailty_requirement then
      return cast(SB.TheHunt, target)
    end
    
    --actions+=/elysian_decree,if=variable.fiery_demise_fiery_brand_is_not_ticking_on_current_target&debuff.frailty.stack>=variable.cooldown_frailty_requirement
    if in_5_range and is_available(SB.ElysianDecree) and castable(SB.ElysianDecree) and fiery_demise_fiery_brand_is_not_ticking_on_current_target and target.debuff(SB.FrailtyDebuff).count >= cooldown_frailty_requirement then
      return cast(SB.ElysianDecree, player)
    end
    
    --actions+=/soul_carver,if=!talent.fiery_demise&soul_fragments<=3&debuff.frailty.stack>=variable.cooldown_frailty_requirement
    if in_5_range and is_available(SB.SoulCarver) and castable(SB.SoulCarver) and not is_available(SB.FieryDemise) and soul_fragments <= 3 and target.debuff(SB.FrailtyDebuff).count >= cooldown_frailty_requirement then
      return cast(SB.SoulCarver, target)
    end
    
    --actions+=/soul_carver,if=variable.fiery_demise_fiery_brand_is_ticking_on_current_target&soul_fragments<=3&debuff.frailty.stack>=variable.cooldown_frailty_requirement
    if in_5_range and is_available(SB.SoulCarver) and castable(SB.SoulCarver) and fiery_demise_fiery_brand_is_ticking_on_current_target and soul_fragments <= 3 and target.debuff(SB.FrailtyDebuff).count >= cooldown_frailty_requirement then
      return cast(SB.SoulCarver, target)
    end
    
    --actions+=/fel_devastation,if=variable.fiery_demise_fiery_brand_is_ticking_on_current_target&dot.fiery_brand.remains<3
    if in_5_range and castable(SB.FelDevastation) and fiery_demise_fiery_brand_is_ticking_on_current_target and target.debuff(SB.FieryBrandDebuff).remains < 3 then
      return cast(SB.FelDevastation, target)
    end
    --actions+=/fiery_brand,if=variable.fiery_demise_fiery_brand_is_not_ticking_on_any_target&variable.the_hunt_on_cooldown&variable.elysian_decree_on_cooldown&((talent.soul_carver&(cooldown.soul_carver.up|cooldown.soul_carver.remains<10))|(talent.fel_devastation&(cooldown.fel_devastation.up|cooldown.fel_devastation.remains<10)))
    if in_5_range and is_available(SB.FieryBrand) and castable(SB.FieryBrand) and fiery_demise_fiery_brand_is_not_ticking_on_any_target and the_hunt_on_cooldown and elysian_decree_on_cooldown
      and (is_available(SB.SoulCarver) and spell(SB.SoulCarver).cooldown < 10 
        or is_available(SB.FelDevastation) and spell(SB.FelDevastation).cooldown < 10) then
      return cast(SB.FieryBrand, target)
    end
    
    --actions+=/immolation_aura,if=talent.fiery_demise&variable.fiery_demise_fiery_brand_is_ticking_on_any_target
    if in_5_range and castable(SB.ImmolationAura) and is_available(SB.FieryDemise) and fiery_demise_fiery_brand_is_ticking_on_any_target then
      return cast(SB.ImmolationAura)
    end
    
    --actions+=/sigil_of_flame,if=talent.fiery_demise&variable.fiery_demise_fiery_brand_is_ticking_on_any_target
    if in_5_range and is_available(SB.SigilofFlame) and castable(SB.SigilofFlame) and is_available(SB.FieryDemise) and fiery_demise_fiery_brand_is_ticking_on_any_target then
      return cast(SB.SigilofFlame, player)
    end
    
    --actions+=/spirit_bomb,if=soul_fragments>=variable.spirit_bomb_soul_fragments&(spell_targets>1|variable.fiery_demise_fiery_brand_is_ticking_on_any_target)
    if in_5_range and is_available(SB.SpiritBomb) and castable(SB.SpiritBomb) and soul_fragments >= spirit_bomb_soul_fragments and (enemies_in_8y > 1 or fiery_demise_fiery_brand_is_ticking_on_any_target) then
      return cast(SB.SpiritBomb)
    end
    
    --actions+=/soul_cleave,if=(soul_fragments<=1&spell_targets>1)|spell_targets=1
    if in_5_range and castable(SB.SoulCleave) and (soul_fragments <= 1 and enemies_in_8y > 1 or enemies_in_8y == 1) then
      return cast(SB.SoulCleave, target)
    end
    
    --actions+=/sigil_of_flame
    if in_5_range and is_available(SB.SigilofFlame) and castable(SB.SigilofFlame) then
      return cast(SB.SigilofFlame, player)
    end
    
    --actions+=/immolation_aura
    if in_5_range and castable(SB.ImmolationAura) then
      return cast(SB.ImmolationAura)
    end
    
    --actions+=/fracture
    if in_5_range and is_available(SB.Fracture) and castable(SB.Fracture) then
      return cast(SB.Fracture, target)
    end
    
    --actions+=/shear
    if in_5_range and castable(SB.Shear) then
      return cast(SB.Shear, target)
    end
    
    --actions+=/throw_glaive
    if in_5_range and castable(SB.ThrowGlaive) then
      return cast(SB.ThrowGlaive, target)
    end
    
    --actions+=/felblade
    if in_5_range and is_available(SB.Felblade) and castable(SB.Felblade) then
      return cast(SB.Felblade, target)
    end
  end
end

local function resting()
end

local function interface()
    local vengeance_gui = {
    key = 'ven_nikopol',
    title = 'vengeance',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Vengeance Settings' },
      { type = 'rule' },   
      { type = 'text', text = 'Healing Settings' },
      { key = 'healing_potion', type = 'checkbox', text = 'Refreshing Healing Potion', desc = 'Use Refreshing Healing Potion when below 10% health', default = false },
      { type = 'rule' },  
      { type = 'text', text = 'Items' },
      { key = 'trinket_13', type = 'checkbox', text = '13', desc = 'use first trinket', default = false },
      { key = 'trinket_14', type = 'checkbox', text = '14', desc = 'use second trinket', default = false },
      { key = 'main_hand', type = 'checkbox', text = '16', desc = 'use main_hand', default = false },
      { type = 'rule' },  
      { type = 'text', text = 'Spells' },
      { key = 'reserve_infernal_strike_charges', type = 'spinner', text = 'Infernal Strike', desc = 'reserve charges', min = 0, max = 2, step = 1, default = 1 },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(vengeance_gui)
  
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
  spec = bxhnz7tp5bge7wvu.rotation.classes.demonhunter.vengeance,
  name = 'ven_nikopol',
  label = 'Vengeance by Nikopol',
  gcd = gcd,
  combat = combat,
  resting = resting,
  interface = interface
})
