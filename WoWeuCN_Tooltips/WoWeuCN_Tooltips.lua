﻿-- Addon: WoWeuCN-Tooltips
-- Author:	Gliang
-- 	本汉化插件由dodo群105196为爱发电组负责翻译，saotizi负责后续更新
--	汉化错误反馈请到飞升计划dodo超级群105196，#汉化内容错漏反馈  频道

-- Local variables
local WoWeuCN_Tooltips_version = GetAddOnMetadata("WoWeuCN_Tooltips", "Version");
local WoWeuCN_Tooltips_onDebug = false;   
local WoWeuCN_AddonPrefix = "WoWeuCN";   

local last_time = GetTime();
local last_text = 0;

-- Global variables initialtion
function WoWeuCN_Tooltips_CheckVars()
  if (not WoWeuCN_Tooltips_LastAnnounceDate) then
    WoWeuCN_Tooltips_LastAnnounceDate = 0;
  end
  if (not WoWeuCN_Tooltips_PS) then
     WoWeuCN_Tooltips_PS = {};
  end
  if (not WoWeuCN_Tooltips_SAVED) then
     WoWeuCN_Tooltips_SAVED = {};
  end
  if (not WoWeuCN_Tooltips_MISSING) then
     WoWeuCN_Tooltips_MISSING = {};
  end
  -- Initiation - active
  if (not WoWeuCN_Tooltips_PS["active"]) then
     WoWeuCN_Tooltips_PS["active"] = "1";
  end
  -- Initiation - spell translation
  if (not WoWeuCN_Tooltips_PS["transspell"] ) then
     WoWeuCN_Tooltips_PS["transspell"] = "1";   
  end
  -- Initiation - item translation
  if (not WoWeuCN_Tooltips_PS["transitem"] ) then
     WoWeuCN_Tooltips_PS["transitem"] = "1";   
  end
    -- Initiation - unit translation
  if (not WoWeuCN_Tooltips_PS["transunit"] ) then
     WoWeuCN_Tooltips_PS["transunit"] = "1";   
  end
   -- Path version info
  if (not WoWeuCN_Tooltips_PS["patch"]) then
     WoWeuCN_Tooltips_PS["patch"] = GetBuildInfo();
  end
  -- Saved variables per character
  if (not WoWeuCN_Tooltips_PC) then
     WoWeuCN_Tooltips_PC = {};
  end
end

-- wait functions from QTR
local WoWeuCN_Tooltips_waitFrame = nil;
local WoWeuCN_Tooltips_waitTable = {};

function WoWeuCN_Tooltips_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if (WoWeuCN_Tooltips_waitFrame == nil) then
    WoWeuCN_Tooltips_waitFrame = CreateFrame("Frame","WoWeuCN_Tooltips_waitFrame", UIParent);
    WoWeuCN_Tooltips_waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #WoWeuCN_Tooltips_waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(WoWeuCN_Tooltips_waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(WoWeuCN_Tooltips_waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(WoWeuCN_Tooltips_waitTable,{delay,func,{...}});
  return true;
end

local function scanAuto(startIndex, attempt, counter)
  if (startIndex > 400000) then
    return;
  end
  for i = startIndex, startIndex + 150 do
    qcSpellInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    qcSpellInformationTooltip:ClearLines()
    qcSpellInformationTooltip:SetHyperlink('spell:' .. i)
    qcSpellInformationTooltip:Show()
    local text =  EnumerateTooltipStyledLines(qcSpellInformationTooltip)
    if (text ~= '' and text ~= nil) then
      if (i >=0 and i < 100000) then
        if (WoWeuCN_Tooltips_SpellToolTips0[i .. ''] == nil or string.len(WoWeuCN_Tooltips_SpellToolTips0[i .. '']) < string.len(text)) then
          WoWeuCN_Tooltips_SpellToolTips0[i .. ''] = text
        end
      elseif (i >=100000 and i < 200000) then
        if (WoWeuCN_Tooltips_SpellToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Tooltips_SpellToolTips100000[i .. '']) < string.len(text)) then
          WoWeuCN_Tooltips_SpellToolTips100000[i .. ''] = text
        end
      elseif (i >=200000 and i < 300000) then
        if (WoWeuCN_Tooltips_SpellToolTips200000[i .. ''] == nil or string.len(WoWeuCN_Tooltips_SpellToolTips200000[i .. '']) < string.len(text)) then
          WoWeuCN_Tooltips_SpellToolTips200000[i .. ''] = text
        end
      elseif (i >=300000 and i < 400000) then
        if (WoWeuCN_Tooltips_SpellToolTips300000[i .. ''] == nil or string.len(WoWeuCN_Tooltips_SpellToolTips300000[i .. '']) < string.len(text)) then
          WoWeuCN_Tooltips_SpellToolTips300000[i .. ''] = text
        end
      end
      print(i)
    end
  end
  print(attempt)
  print(counter)
  WoWeuCN_Tooltips_SpellToolIndex = startIndex
  if (counter >= 8) then
    WoWeuCN_Tooltips_wait(0.5, scanAuto, startIndex + 150, attempt + 1, 0)
  else
    WoWeuCN_Tooltips_wait(0.5, scanAuto, startIndex, attempt + 1, counter + 1)
  end
end

local function scanUnitAuto(startIndex, attempt, counter)
  if (startIndex > 200000) then
    return;
  end
  for i = startIndex, startIndex + 250 do
    qcSpellInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    qcSpellInformationTooltip:ClearLines()
    local guid = "Creature-0-0-0-0-"..i.."-0000000000";
    qcSpellInformationTooltip:SetHyperlink('unit:' .. guid)
    qcSpellInformationTooltip:Show()
    local text =  EnumerateTooltipStyledLines(qcSpellInformationTooltip)
    if (text ~= '' and text ~= nil) then
     if (i >=0 and i < 100000) then
      if (WoWeuCN_Tooltips_UnitToolTips0[i .. ''] == nil or string.len(WoWeuCN_Tooltips_UnitToolTips0[i .. '']) < string.len(text)) then
        WoWeuCN_Tooltips_UnitToolTips0[i .. ''] = text
      end
    elseif (i >=100000 and i < 200000) then
      if (WoWeuCN_Tooltips_UnitToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Tooltips_UnitToolTips100000[i .. '']) < string.len(text)) then
        WoWeuCN_Tooltips_UnitToolTips100000[i .. ''] = text
      end
    end
    end
    print(i)
  end
  print(attempt)
  print(counter)
  WoWeuCN_Tooltips_UnitIndex = startIndex
  if (counter >= 3) then
    WoWeuCN_Tooltips_wait(0.5, scanUnitAuto, startIndex + 250, attempt + 1, 0)
  else
    WoWeuCN_Tooltips_wait(0.5, scanUnitAuto, startIndex, attempt + 1, counter + 1)
  end
end

local function scanItemAuto(startIndex, attempt, counter)
  if (startIndex > 200000) then
    return;
  end
  for i = startIndex, startIndex + 150 do
    local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, GetItemInfo(i))
    if (classID~=nil) then
      qcSpellInformationTooltip:SetOwner(UIParent, "ANCHOR_NONE")
      qcSpellInformationTooltip:ClearLines()
      qcSpellInformationTooltip:SetHyperlink('item:' .. i .. ':0:0:0:0:0:0:0')
      qcSpellInformationTooltip:Show()
      local text = EnumerateTooltipStyledLines(qcSpellInformationTooltip)
      text = text .. '{{{' .. classID .. '}}}'
      if (text ~= '' and text ~= nil) then
        if (i >=0 and i < 100000) then
          if (WoWeuCN_Tooltips_ItemToolTips0[i .. ''] == nil or string.len(WoWeuCN_Tooltips_ItemToolTips0[i .. '']) < string.len(text)) then
            WoWeuCN_Tooltips_ItemToolTips0[i .. ''] = text
          end
        elseif (i >=100000 and i < 200000) then
          if (WoWeuCN_Tooltips_ItemToolTips100000[i .. ''] == nil or string.len(WoWeuCN_Tooltips_ItemToolTips100000[i .. '']) < string.len(text)) then
            WoWeuCN_Tooltips_ItemToolTips100000[i .. ''] = text
          end
          print(i)
        end
      end
    else
      if (classId==nil) then
        print(i .. " skip")
      else
        print(i .. " gear")
      end
    end
  end
  print(attempt)
  print(counter)
  WoWeuCN_Tooltips_ItemIndex = startIndex
  if (counter >= 8) then
    WoWeuCN_Tooltips_wait(0.5, scanItemAuto, startIndex + 150, attempt + 1, 0)
  else
    WoWeuCN_Tooltips_wait(0.5, scanItemAuto, startIndex, attempt + 1, counter + 1)
  end
end

function loadAllItemData()
	loadItemData0();
	--loadItemData100000();
end
  
function loadAllUnitData()
	loadUnitData0();
	loadUnitData100000();
end
function loadSpellData()
	loadSpellIndex();
	loadSpellData0();
end

local function EnumerateTooltipStyledLines_helper(...)
  local texts = '';
  local hasObjectivesSet = false
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
      local text = region:GetText() -- string or nil
			if (text ~= nil) then
        if (text ~= " ")
          then
            text = "{{" .. text .. "}}"
            local r, g, b, a = region:GetTextColor()
            text = text .. "[[" .. r .. "]]" .. "[[" .. g .. "]]" .. "[[" .. b .. "]]"
          end
        print(i)
        print(text)
        texts = texts .. text	
			end
        end
	end
	return texts
end

function EnumerateTooltipStyledLines(tooltip) -- good for script handlers that pass the tooltip as the first argument.
  return EnumerateTooltipStyledLines_helper(tooltip:GetRegions())
end

function qcSpellInformationTooltipSetup() -- *
	qcSpellInformationTooltip = CreateFrame("GameTooltip", "qcSpellInformationTooltip", UIParent, "GameTooltipTemplate")
	qcSpellInformationTooltip:SetFrameStrata("TOOLTIP")
end


-- commands
function WoWeuCN_Tooltips_SlashCommand(msg)
   if (msg=="on" or msg=="ON") then
      if (WoWeuCN_Tooltips_PS["active"]=="1") then
         print ("WOWeuCN - Tooltips 翻译模块已启用.");
      else
         print ("|cffffff00WOWeuCN - Tooltips 翻译模块已启用.");
         WoWeuCN_Tooltips_PS["active"] = "1";
         WoWeuCN_Tooltips_ToggleButton0:Enable();
         WoWeuCN_Tooltips_ToggleButton1:Enable();
         WoWeuCN_Tooltips_ToggleButton2:Enable();
      end
   elseif (msg=="off" or msg=="OFF") then
      if (WoWeuCN_Tooltips_PS["active"]=="0") then
         print ("WOWeuCN - Tooltips 翻译模块已关闭.");
      else
         print ("|cffffff00WOWeuCN - Tooltips 翻译模块已关闭.");
         WoWeuCN_Tooltips_PS["active"] = "0";
         WoWeuCN_Tooltips_ToggleButton0:Disable();
         WoWeuCN_Tooltips_ToggleButton1:Disable();
         WoWeuCN_Tooltips_ToggleButton2:Disable();
      end

    --spell scan
    elseif (msg=="back" or msg=="BACK") then
      WoWeuCN_Tooltips_SpellToolIndex = WoWeuCN_Tooltips_SpellToolIndex - 500;
      print(WoWeuCN_Tooltips_SpellToolIndex);
    elseif (msg=="clear" or msg=="CLEAR") then
      WoWeuCN_Tooltips_SpellToolIndex = 1;
      WoWeuCN_Tooltips_SpellToolTips0 = {} 
      WoWeuCN_Tooltips_SpellToolTips100000 = {} 
      WoWeuCN_Tooltips_SpellToolTips200000 = {} 
      WoWeuCN_Tooltips_SpellToolTips300000 = {} 
      print("Clear");
    elseif (msg=="reset" or msg=="RESET") then
      WoWeuCN_Tooltips_SpellToolIndex = 1;
      print("Reset");

    -- spell auto scan
    elseif (msg=="scanauto" or msg=="SCANAUTO") then
      if (WoWeuCN_Tooltips_SpellToolTips0 == nil) then
        WoWeuCN_Tooltips_SpellToolTips0 = {} 
      end
      if (WoWeuCN_Tooltips_SpellToolTips100000 == nil) then
        WoWeuCN_Tooltips_SpellToolTips100000 = {} 
      end
      if (WoWeuCN_Tooltips_SpellToolTips200000 == nil) then
        WoWeuCN_Tooltips_SpellToolTips200000 = {} 
      end
      if (WoWeuCN_Tooltips_SpellToolTips300000 == nil) then
        WoWeuCN_Tooltips_SpellToolTips300000 = {} 
      end
      if (WoWeuCN_Tooltips_SpellToolIndex == nil) then
        WoWeuCN_Tooltips_SpellToolIndex = 1
      end

      WoWeuCN_Tooltips_wait(0.1, scanAuto, WoWeuCN_Tooltips_SpellToolIndex, 1, 0)

    -- item scan
    elseif (msg=="itemreset" or msg=="ITEMRESET") then
      WoWeuCN_Tooltips_ItemIndex = 1;
      print("Reset");
    elseif (msg=="itemclear" or msg=="ITEMCLEAR") then
      WoWeuCN_Tooltips_ItemToolTips0 = {} 
      WoWeuCN_Tooltips_ItemToolTips100000 = {} 
      WoWeuCN_Tooltips_ItemIndex = 1
      print("Clear");
    
    -- unit
    elseif (msg=="unitclear" or msg=="UNITCLEAR") then
      WoWeuCN_Tooltips_UnitToolTips0 = {} 
      WoWeuCN_Tooltips_UnitToolTips100000 = {} 
      WoWeuCN_Tooltips_UnitIndex = 1
      print("Clear");
    elseif (msg=="unitscanauto" or msg=="UNITSCANAUTO") then
      if (WoWeuCN_Tooltips_UnitToolTips0 == nil) then
        WoWeuCN_Tooltips_UnitToolTips0 = {} 
      end
      if (WoWeuCN_Tooltips_UnitToolTips100000 == nil) then
        WoWeuCN_Tooltips_UnitToolTips100000 = {} 
      end
      if (WoWeuCN_Tooltips_UnitIndex == nil) then
        WoWeuCN_Tooltips_UnitIndex = 1
      end

      WoWeuCN_Tooltips_wait(0.1, scanUnitAuto, WoWeuCN_Tooltips_UnitIndex, 1, 0)

    -- item auto scan
    elseif (msg=="itemscanauto" or msg=="ITEMSCANAUTO") then      
      if (WoWeuCN_Tooltips_ItemIndex == nil) then
        WoWeuCN_Tooltips_ItemIndex = 1
      end
      if (WoWeuCN_Tooltips_ItemToolTips0 == nil) then
        WoWeuCN_Tooltips_ItemToolTips0 = {} 
      end
      if (WoWeuCN_Tooltips_ItemToolTips100000 == nil) then
        WoWeuCN_Tooltips_ItemToolTips100000 = {} 
      end
      WoWeuCN_Tooltips_wait(0.1, scanItemAuto, WoWeuCN_Tooltips_ItemIndex, 1, 0)
    elseif (msg=="") then
        InterfaceOptionsFrame_Show();
        InterfaceOptionsFrame_OpenToCategory("WoWeuCN-Tooltips");
    else
      print ("WOWeuCN-Tooltips - 指令说明:");
      print ("      /woweucn-tooltips on  - 启用Tooltips翻译模块");
      print ("      /woweucn-tooltips off - 禁用Tooltips翻译模块");
   end
end



function WoWeuCN_Tooltips_SetCheckButtonState()
  WoWeuCN_TooltipsCheckButton0:SetChecked(WoWeuCN_Tooltips_PS["active"]=="1");
  WoWeuCN_TooltipsCheckButton3:SetChecked(WoWeuCN_Tooltips_PS["transspell"]=="1");
  WoWeuCN_TooltipsCheckButton4:SetChecked(WoWeuCN_Tooltips_PS["transitem"]=="1");
  WoWeuCN_TooltipsCheckButton5:SetChecked(WoWeuCN_Tooltips_PS["transunit"]=="1");
end



function WoWeuCN_Tooltips_BlizzardOptions()
  -- Create main frame for information text
  local WoWeuCN_TooltipsOptions = CreateFrame("FRAME", "WoWeuCN_Tooltips_Options");
  WoWeuCN_TooltipsOptions.name = "WoWeuCN-Tooltips";
  WoWeuCN_TooltipsOptions.refresh = function (self) WoWeuCN_Tooltips_SetCheckButtonState() end;
  InterfaceOptions_AddCategory(WoWeuCN_TooltipsOptions);

  local WoWeuCN_TooltipsOptionsHeader = WoWeuCN_TooltipsOptions:CreateFontString(nil, "ARTWORK");
  WoWeuCN_TooltipsOptionsHeader:SetFontObject(GameFontNormalLarge);
  WoWeuCN_TooltipsOptionsHeader:SetJustifyH("LEFT"); 
  WoWeuCN_TooltipsOptionsHeader:SetJustifyV("TOP");
  WoWeuCN_TooltipsOptionsHeader:ClearAllPoints();
  WoWeuCN_TooltipsOptionsHeader:SetPoint("TOPLEFT", 16, -16);
  WoWeuCN_TooltipsOptionsHeader:SetText("鼠标提示汉化插件（飞升计划DODO超级群105196) ");
  WoWeuCN_TooltipsOptionsHeader:SetFont(WoWeuCN_Tooltips_Font2, 16);

  local WoWeuCN_TooltipsPlayer = WoWeuCN_TooltipsOptions:CreateFontString(nil, "ARTWORK");
  WoWeuCN_TooltipsPlayer:SetFontObject(GameFontNormalLarge);
  WoWeuCN_TooltipsPlayer:SetJustifyH("LEFT"); 
  WoWeuCN_TooltipsPlayer:SetJustifyV("TOP");
  WoWeuCN_TooltipsPlayer:ClearAllPoints();
  WoWeuCN_TooltipsPlayer:SetPoint("TOPRIGHT", WoWeuCN_TooltipsOptionsHeader, "TOPRIGHT", 0, -22);
  WoWeuCN_TooltipsPlayer:SetText("作者 : "..WoWeuCN_Tooltips_Messages.author);
  WoWeuCN_TooltipsPlayer:SetFont(WoWeuCN_Tooltips_Font2, 16);

  local WoWeuCN_TooltipsCheckButton0 = CreateFrame("CheckButton", "WoWeuCN_TooltipsCheckButton0", WoWeuCN_TooltipsOptions, "OptionsCheckButtonTemplate");
  WoWeuCN_TooltipsCheckButton0:SetPoint("TOPLEFT", WoWeuCN_TooltipsOptionsHeader, "BOTTOMLEFT", 0, -44);
  WoWeuCN_TooltipsCheckButton0:SetScript("OnClick", function(self) if (WoWeuCN_Tooltips_PS["active"]=="1") then WoWeuCN_Tooltips_PS["active"]="0" else WoWeuCN_Tooltips_PS["active"]="1" end; end);
  WoWeuCN_TooltipsCheckButton0Text:SetFont(WoWeuCN_Tooltips_Font2, 13);
  WoWeuCN_TooltipsCheckButton0Text:SetText(WoWeuCN_Tooltips_Interface.active);

  local WoWeuCN_TooltipsOptionsMode1 = WoWeuCN_TooltipsOptions:CreateFontString(nil, "ARTWORK");
  WoWeuCN_TooltipsOptionsMode1:SetFontObject(GameFontWhite);
  WoWeuCN_TooltipsOptionsMode1:SetJustifyH("LEFT");
  WoWeuCN_TooltipsOptionsMode1:SetJustifyV("TOP");
  WoWeuCN_TooltipsOptionsMode1:ClearAllPoints();
  WoWeuCN_TooltipsOptionsMode1:SetPoint("TOPLEFT", WoWeuCN_TooltipsCheckButton0, "BOTTOMLEFT", 30, -20);
  WoWeuCN_TooltipsOptionsMode1:SetFont(WoWeuCN_Tooltips_Font2, 13);
  WoWeuCN_TooltipsOptionsMode1:SetText(WoWeuCN_Tooltips_Interface.options1);
  
  local WoWeuCN_TooltipsCheckButton3 = CreateFrame("CheckButton", "WoWeuCN_TooltipsCheckButton3", WoWeuCN_TooltipsOptions, "OptionsCheckButtonTemplate");
  WoWeuCN_TooltipsCheckButton3:SetPoint("TOPLEFT", WoWeuCN_TooltipsOptionsMode1, "BOTTOMLEFT", 0, -5);
  WoWeuCN_TooltipsCheckButton3:SetScript("OnClick", function(self) if (WoWeuCN_Tooltips_PS["transspell"]=="0") then WoWeuCN_Tooltips_PS["transspell"]="1" else WoWeuCN_Tooltips_PS["transspell"]="0" end; end);
  WoWeuCN_TooltipsCheckButton3Text:SetFont(WoWeuCN_Tooltips_Font2, 13);
  WoWeuCN_TooltipsCheckButton3Text:SetText(WoWeuCN_Tooltips_Interface.transspell);
  
  local WoWeuCN_TooltipsCheckButton4 = CreateFrame("CheckButton", "WoWeuCN_TooltipsCheckButton4", WoWeuCN_TooltipsOptions, "OptionsCheckButtonTemplate");
  WoWeuCN_TooltipsCheckButton4:SetPoint("TOPLEFT", WoWeuCN_TooltipsOptionsMode1, "BOTTOMLEFT", 0, -25);
  WoWeuCN_TooltipsCheckButton4:SetScript("OnClick", function(self) if (WoWeuCN_Tooltips_PS["transitem"]=="0") then WoWeuCN_Tooltips_PS["transitem"]="1" else WoWeuCN_Tooltips_PS["transitem"]="0" end; end);
  WoWeuCN_TooltipsCheckButton4Text:SetFont(WoWeuCN_Tooltips_Font2, 13);
  WoWeuCN_TooltipsCheckButton4Text:SetText(WoWeuCN_Tooltips_Interface.transitem);
  
  local WoWeuCN_TooltipsCheckButton5 = CreateFrame("CheckButton", "WoWeuCN_TooltipsCheckButton5", WoWeuCN_TooltipsOptions, "OptionsCheckButtonTemplate");
  WoWeuCN_TooltipsCheckButton5:SetPoint("TOPLEFT", WoWeuCN_TooltipsOptionsMode1, "BOTTOMLEFT", 0, -45);
  WoWeuCN_TooltipsCheckButton5:SetScript("OnClick", function(self) if (WoWeuCN_Tooltips_PS["transunit"]=="0") then WoWeuCN_Tooltips_PS["transunit"]="1" else WoWeuCN_Tooltips_PS["transunit"]="0" end; end);
  WoWeuCN_TooltipsCheckButton5Text:SetFont(WoWeuCN_Tooltips_Font2, 13);
  WoWeuCN_TooltipsCheckButton5Text:SetText(WoWeuCN_Tooltips_Interface.transunit);
  
  
 
  
  local WoWeuCN_TooltipsLink = WoWeuCN_TooltipsOptions:CreateFontString(nil, "ARTWORK");
  WoWeuCN_TooltipsLink:SetFontObject(GameFontWhite);
  WoWeuCN_TooltipsLink:SetJustifyH("LEFT"); 
  WoWeuCN_TooltipsLink:SetJustifyV("TOP");
  WoWeuCN_TooltipsLink:ClearAllPoints();
  WoWeuCN_TooltipsLink:SetPoint("TOPRIGHT", WoWeuCN_TooltipsOptionsHeader, "TOPRIGHT", 0, -220);
  WoWeuCN_TooltipsLink:SetText("更新/反馈地址：https://imdodo.com/s/139324");
  WoWeuCN_TooltipsLink:SetFont(WoWeuCN_Tooltips_Font2, 13);
   
  local WoWeuCN_TooltipsVersion = WoWeuCN_TooltipsOptions:CreateFontString(nil, "ARTWORK");
  WoWeuCN_TooltipsVersion:SetFontObject(GameFontNormalLarge);
  WoWeuCN_TooltipsVersion:SetJustifyH("LEFT"); 
  WoWeuCN_TooltipsVersion:SetJustifyV("TOP");
  WoWeuCN_TooltipsVersion:ClearAllPoints();
  WoWeuCN_TooltipsVersion:SetPoint("TOPRIGHT", WoWeuCN_TooltipsOptionsHeader, "TOPRIGHT", 0, -240);
  WoWeuCN_TooltipsVersion:SetText("更新日期: "..WoWeuCN_Tooltips_version);
  WoWeuCN_TooltipsVersion:SetFont(WoWeuCN_Tooltips_Font2, 15);
  
end

-- First function called after the add-in has been loaded
function WoWeuCN_Tooltips_OnLoad()
   WoWeuCN_Tooltips = CreateFrame("Frame");
   WoWeuCN_Tooltips:SetScript("OnEvent", WoWeuCN_Tooltips_OnEvent);
   WoWeuCN_Tooltips:RegisterEvent("ADDON_LOADED");
   GameTooltip:HookScript("OnTooltipSetSpell", function(...) OnTooltipSpell(..., GameTooltip) end)
   GameTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
   ItemRefTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
  --  GameTooltipTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)

  --  EmbeddedItemTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
   ShoppingTooltip1:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
   ShoppingTooltip2:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
   ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)
   ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", function(...) OnTooltipItem(..., GameTooltip) end)

   GameTooltip:HookScript("OnTooltipSetUnit", function(...) OnTooltipUnit(..., GameTooltip) end)
   
   if (_G.ElvUISpellBookTooltip ~= nil) then
    _G.ElvUISpellBookTooltip:HookScript("OnTooltipSetSpell", function(...) OnTooltipSpellElvUi(..., GameTooltip) end)
   end

   qcSpellInformationTooltipSetup();
   loadSpellData()
   loadAllItemData()
   loadAllUnitData()
end

function split(s, delimiter)
  if (s == nil) then
      return nil
  end
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match);
  end
  return result;
end

function GetFirstLineColorCode(...)
  local colorCode = _G["ORANGE_FONT_COLOR_CODE"]
  for regionIndex = 1, select("#", ...) do
    local region = select(regionIndex, ...)
    if region and region:GetObjectType() == "FontString" then
      local text = region:GetText() -- string or nil
      if (text ~= nil) then
        if (text ~= " ") then
          local r, g, b, a = region:GetTextColor()
          colorCode = string.format("%02x", a * 255) .. string.format("%02x", r * 255) .. string.format("%02x", g * 255) .. string.format("%02x", b * 255)
          return "|c" .. colorCode
        end
      end
    end
  end
  return colorCode
end

function OnTooltipUnit(self, tooltip)
  if (WoWeuCN_Tooltips_PS["active"]=="0" or WoWeuCN_Tooltips_PS["transunit"]=="0") then
    return
  end
	-- Case for linked unit
  local _, t = self:GetUnit()
	if (not t or not UnitGUID(t)) then
		return
	end
	local ty = tonumber(UnitGUID(t):sub( 5, 5),  16)
	local g  = tonumber(UnitGUID(t):sub(13, 18), 16)
		local IDConvert = {
		["3"] = tonumber(UnitGUID(t):sub(8, 12), 16), 
		["4"] = tonumber(UnitGUID(t):sub(6, 12), 16), 
		["5"] = tonumber(UnitGUID(t):sub(8, 12), 16)
		}
	if g and ty == 0 then
		self:AddDoubleLine("|cffCCCCCC角色 GUID : ","|cff7FFF00"..g)
	elseif g and ty == 3 then
		-- self:AddDoubleLine("生物 Entry :  ",IDConvert[tostring(ty)])
	    -- self:AddDoubleLine("|cffCCCCCC生物 GUID : ","|cff"..color..g)
	elseif g and ty == 4 then
		self:AddLine("宠物 id : "..IDConvert[tostring(ty)])
	elseif g and ty == 5 then
		self:AddDoubleLine("载具 Entry :  ",IDConvert[tostring(ty)])
	    self:AddDoubleLine("|cffCCCCCC载具 GUID : ","|cff7FFF00"..g)
	end
	
	local unitData = GetUnitData(IDConvert[tostring(ty)])
	if ( unitData ) then  
		self:AddLine(" ")
		for i = 1, #unitData do
		  local text = unitData[i]
		  if (i < 2) then
			local colorCode = GetFirstLineColorCode(self :GetRegions())
			self:AddLine(colorCode .. text .. "|r", 1, 1, 1, 1)
		  else
			self:AddLine(text, 1, 1, 1, 1)
		  end
		end
	end
end

function GetUnitData(id)
	if (id == nil) then
	  return nil
	end
	local str_id = tostring(id)
	local num_id = tonumber(id)
	local dataIndex = nil
	if (num_id >= 0 and num_id < 100000) then
	  dataIndex = PAwow_Unit_index_0[num_id]
	elseif (num_id >= 100000 and num_id < 200000) then
	  dataIndex = PAwow_Unit_index_100000[num_id - 100000]
	end
  
	if (dataIndex == nil) then
	  return nil
	end
  
	if (num_id >= 0 and num_id < 100000) then
	  return split(PAwow_Unit_Data_0[dataIndex], '£')
	elseif (num_id >= 100000 and num_id < 200000) then
	  return split(PAwow_Unit_Data_100000[dataIndex], '£')
	end
  
	return nil
end  


function OnTooltipItem(self, tooltip)
  if (WoWeuCN_Tooltips_PS["active"]=="0" or WoWeuCN_Tooltips_PS["transitem"]=="0") then
    return
  end
	-- Case for linked spell
  local _, itemLink = self:GetItem()
  if (itemLink == nil) then 
    return
  end
  local itemID = string.match(itemLink, 'Hitem:(%d+):')
  local itemData = GetItemData(itemID)
  if ( itemData ) then  
    local lines = self:NumLines()
    for i= 1, lines do
      local line = _G[("GameTooltipTextLeft%d"):format(i)]
      if line and line:GetText() and line:GetText():find(itemData[1]) then
        return
      end
    end
    self:AddLine(" ")
    for i = 1, #itemData do
      local region = itemData[i]
      self:AddLine(region, 1, 1, 1, 1)
    end
  end
end

function GetItemData(id)
    if (id == nil) then
        return nil
    end
    local str_id = tostring(id)
    local num_id = tonumber(id) 
    local dataIndex = nil
    if (num_id >= 0 and num_id < 100000) then	
        dataIndex = PAwow_Item_index_0[num_id]
    elseif (num_id >= 100000 and num_id < 200000) then
        dataIndex = PAwow_Item_index_100000[num_id - 100000]
    end

    if (dataIndex == nil) then
        return nil
    end

    if (num_id >= 0 and num_id < 100000) then
        return split(PAwow_Item_Data_0[dataIndex], '£')
    elseif (num_id >= 100000 and num_id < 200000) then
        return split(PAwow_Item_Data_100000[dataIndex], '£')
    end
    return nil
end

function OnTooltipSpellElvUi(self)
  if (WoWeuCN_Tooltips_PS["active"]=="0" or WoWeuCN_Tooltips_PS["transspell"]=="0") then
    return
  end
	-- Case for linked spell
  local name,id = self:GetSpell()
  local spellData = GetSpellData(id)
  if ( spellData ) then
    local lines = self:NumLines()
    for i= 1, lines do
      local line = _G[("GameTooltipTextLeft%d"):format(i)]
      if line and line:GetText() and line:GetText():find(spellData[1]) then
        return
      end
    end
  
    self:AddLine(" ")
    for i = 1, #spellData do
      local region = spellData[i]
      self:AddLine(region, 1, 1, 1, 1)
    end
	
  end
end

function OnTooltipSpell(self, tooltip)
  if (WoWeuCN_Tooltips_PS["active"]=="0" or WoWeuCN_Tooltips_PS["transspell"]=="0") then
    return
  end
	-- Case for linked spell
  local id = select(3,self:GetSpell())
	local length = 0
  local spellData = GetSpellData(id)
  if ( spellData ) then
    local lines = self:NumLines()
    for i= 1, lines do
      local line = _G[("GameTooltipTextLeft%d"):format(i)]
      if line and line:GetText() and line:GetText():find(spellData[1]) then
        return
      end
    end
	length = 0
	for i = 1, #spellData do
      local region = spellData[i]
	  length = #region+length
      self:AddLine(region, 1, 1, 1, 1)
    end
  	
  end
  if id then
		self:AddDoubleLine("法术 id :",id)	
    	
	end
	self:SetMinimumWidth(0)
	if length >500 then 
		self:AddLine("                                                                                                                                                                      ",1,1,1,false)
	elseif length >700 then 
		self:AddLine("                                                                                                                                                                                                                                                                                  ",1,1,1,false)
	end
end

function GetSpellData(id)
	if (id == nil) then
	  	return nil
	end
	local str_id = tostring(id)
	local num_id = tonumber(id)
	local dataIndex = nil
		dataIndex = PAwow_Spell_index[num_id]
	if (dataIndex == nil) then
	  	return nil
	end
	return split(PAwow_Spell_Data[dataIndex], '£')

end

-- Even handlers
function WoWeuCN_Tooltips_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWeuCN_Tooltips") then
      SlashCmdList["WOWEUCN_TOOLTIPS"] = function(msg) WoWeuCN_Tooltips_SlashCommand(msg); end
      SLASH_WOWEUCN_TOOLTIPS1 = "/woweucn-tooltips";
      WoWeuCN_Tooltips_CheckVars();
      -- Create interface Options in Blizzard-Interface-Addons
      WoWeuCN_Tooltips_BlizzardOptions();
      -- WoWeuCN_Tooltips_wait(2, Broadcast);
      WoWeuCN_Tooltips:UnregisterEvent("ADDON_LOADED");      
      WoWeuCN_Tooltips.ADDON_LOADED = nil;
   end
end

local function OnEvent(self, event, prefix, text, channel, sender, ...)
  if event == "CHAT_MSG_ADDON" and prefix == WoWeuCN_AddonPrefix then
    if text == "VERSION" then
      C_ChatInfo.SendAddonMessage(WoWeuCN_AddonPrefix, "WoWeuCN-Tooltips ver. "..WoWeuCN_Tooltips_version, channel)
    else
      --print(text .. " " .. sender)
    end
	end
end

-- function Broadcast()
--   print ("|cffffff00WoWeuCN-Tooltips ver. "..WoWeuCN_Tooltips_version.." - "..WoWeuCN_Tooltips_Messages.loaded);
  
--   local f = CreateFrame("Frame")
--   f:RegisterEvent("CHAT_MSG_ADDON")
--   f:SetScript("OnEvent", OnEvent)
--   local name,title,_,enabled = GetAddOnInfo('WoWeuCN_Quests')
--   if (enabled == true) then
--     return
--   elseif (title == nil) then
--     local addonName = _G["GREEN_FONT_COLOR_CODE"] .. "Quest Translator - Chinese|r"
--     print ("|cffffff00欢迎使用悬停提示汉化插件。如需中文任务汉化请安装 " .. addonName .. " 翻译插件。|r");
--   end
  
--   C_ChatInfo.RegisterAddonMessagePrefix(WoWeuCN_AddonPrefix)
--   local regionCode = GetCurrentRegion()
--   if (regionCode ~= 3) then
--     print ("|cffffff00本插件主要服务欧洲服务器玩家。你所在的服务器区域支持中文客户端，如有需要请搜索战网修改客户端语言教程修改语言，直接使用中文进行游戏。|r");
--     return
--   end
--   if (time() - WoWeuCN_Tooltips_LastAnnounceDate < WowenCN_Tooltips_WeekDiff) then
--     return
--   end

--   WoWeuCN_Tooltips_LastAnnounceDate = time()
--   local realmName = GetRealmName()

--   local guildInfo = _G["GREEN_FONT_COLOR_CODE"] .. "<Blood Requiem>|r" 
--   if (realmName == "Silvermoon") then
--     --guildInfo = "\124cff00ff00\124HclubFinder:ClubFinder-1-137354-3391-68978962|h[Blood Requiem]\124h\124r"
--   end

--   --print(_G["ORANGE_FONT_COLOR_CODE"] .. "Silvermoon 联盟公会" .. guildInfo .. _G["ORANGE_FONT_COLOR_CODE"] .. "招收治疗DPS加入我们开荒M团本的团队与大米冲层队伍。同时欢迎休闲玩家来欢乐打大米PVP评级。入会咨询/申请请|r" .. "\124cffffd100\124HclubTicket:wyPXGRUyyb\124h[点击加入社群]\124h\124r" .. _G["ORANGE_FONT_COLOR_CODE"] .. "（链接已修复）。|r");
-- end

