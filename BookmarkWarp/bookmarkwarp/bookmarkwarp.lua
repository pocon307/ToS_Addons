CHAT_SYSTEM(string.format("%s is loaded", "Bookmark Warp"));

local acutil = require("acutil");
local addonName = "BookmarkWarp";
local settingsFileLoc = string.format("../addons/%s/settings.json", string.lower(addonName));

_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][addonName] = _G["ADDONS"][addonName] or {};
--SetEventScript内関数からの呼び出しもPUBLICでなくてはいけない
--BookmarkWarp変数からlocalを削除
BookmarkWarp = _G["ADDONS"][addonName];
BookmarkWarp.settings = {};
BookmarkWarp.settings.position = { x = 1760, y = 490 };
BookmarkWarp.settings.bookmarkList = {};

local loaded = false;
local usedItem = false;
local showFrame = false;

-- initialize.
function BookmarkWarp.Init()
  if loaded == true then return end
  local t, err = acutil.loadJSON(settingsFileLoc);
  if not err then
    BookmarkWarp.settings = t;
    loaded = true;
  end
end

-- save.
function BookmarkWarp.SaveSettings()
  acutil.saveJSON(settingsFileLoc, BookmarkWarp.settings);
end

-- init Frame.
function BookmarkWarp.InitFrame()
  local frame = ui.GetFrame('bookmarkwarp');
  
  --frame:SetOffset(1300 , 50);
  --frame:Move(0, 0);
  --frame:SetOffset(BookmarkWarp.settings.position.x , BookmarkWarp.settings.position.y);
  --frame:SetPos(BookmarkWarp.settings.position.x , BookmarkWarp.settings.position.y);
  --frame:Resize(200, 200);
  --frame:SetLayerLevel(201);

  frame:SetEventScript(ui.LBUTTONUP, "BOOKMARKWARP_ENDDRAG");
  frame:ShowWindow(0);
end

-- end drag.
function BOOKMARKWARP_ENDDRAG
  local frame = ui.GetFrame('bookmarkwarp');
  BookmarkWarp.settings.position.x = frame:GetX();
  BookmarkWarp.settings.position.y = frame:GetY();
  BookmarkWarp.SaveSettings();
end

-- create Button.
function BookmarkWarp.CreateButton(i, warpName, warpcost)
  local frame = ui.GetFrame('bookmarkwarp');
  local warpCls = GetClass('camp_warp', warpName)
  local mapCls = GetClass("Map", warpCls.Zone);
  local button = frame:CreateOrGetControl("button", "warpButton_"..warpName, 10, (i-1)*48+10, 280, 32);
  button = tolua.cast(button, "ui::CButton");
  if warpcost > -1 then
    button:SetEnable(1);
    if usedItem == true then
      button:SetText(mapCls.Name);
    else
      button:SetText(mapCls.Name.." {img silver 20 20}"..warpcost);
    end
    button:SetOverSound('button_over');
    button:SetClickSound('button_click_stats');
    button:SetEventScript(ui.LBUTTONUP, 'WARP_TO_AREA')
    button:SetEventScriptArgString(ui.LBUTTONUP, warpName);
    button:SetEventScript(ui.RBUTTONUP, 'BOOKMARKWARP_CONTEXTMENUREMOVE');
    button:SetEventScriptArgString(ui.RBUTTONUP, warpName);
    button:SetEventScriptArgNumber(ui.RBUTTONUP, warpcost);
  else
    button:SetEnable(0);
    button:SetText(mapCls.Name);
  end
end

-- button alignment
function BookmarkWarp.ButtonAlignment()
  local frame = ui.GetFrame('bookmarkwarp');
  local y = 10;
  for i, v in ipairs(BookmarkWarp.settings.bookmarkList) do
    local button = GET_CHILD(frame, "warpButton_"..v, "ui::CButton");
    button:SetPos(0, y);
    y = y + 48;
  end
  frame:Resize(300, y);
end

-- ON_INTE_WARP_SUB Hook.
function BookmarkWarp.OnInitWarpSub(frame, pic, index, gBoxName, nowZoneName, warpcost, calcOnlyPosition, makeWorldMapImage, mapCls, info, picX, picY, brushX, brushY, bySkill)
  --CHAT_SYSTEM(info.Name..":"..info.ClassName..":"..info.Zone);
  -- call original method.
  BookmarkWarp.OnInitWarpSubHook(frame, pic, index, gBoxName, nowZoneName, warpcost, calcOnlyPosition, makeWorldMapImage, mapCls, info, picX, picY, brushX, brushY, bySkill);

  local i = table.find(BookmarkWarp.settings.bookmarkList, info.ClassName);
  if i ~= 0 then
    BookmarkWarp.CreateButton(i, info.ClassName, warpcost);
    showFrame = true;
  end
  

  local setName = "WARP_CTRLSET_" .. index;
  local gbox = GET_CHILD(pic, gBoxName, "ui::CGroupBox");
  if gbox == nil then return end
  local set = GET_CHILD(gbox, setName, "ui::CControlSet");
  if set == nil then return end

  --SetEventScriptで呼び出されるものはPUBLICでなくてはいけない
  --SetEventScriptの引数は、ArgStringとArgNumberで指定する
  set:SetEventScript(ui.RBUTTONUP, 'BOOKMARKWARP_CONTEXTMENUADD');
  set:SetEventScriptArgString(ui.RBUTTONUP, info.ClassName);
  set:SetEventScriptArgNumber(ui.RBUTTONUP, warpcost);
end

-- context menu
function BOOKMARKWARP_CONTEXTMENUREMOVE(frame, ctrl, warpName, warpcost)
  --SetEventScript内関数からの呼び出しもPUBLICでなくてはいけない
  --BookmarkWarp変数からlocalを削除
  BookmarkWarp.ContextMenu(warpName, warpcost, "remove")
end

function BOOKMARKWARP_CONTEXTMENUADD(frame, ctrl, warpName, warpcost)
  --SetEventScript内関数からの呼び出しもPUBLICでなくてはいけない
  --BookmarkWarp変数からlocalを削除
  BookmarkWarp.ContextMenu(warpName, warpcost, "add")
end

function BookmarkWarp.ContextMenu(warpName, warpcost, type)
  local context = ui.CreateContextMenu("BOOKMARK_CONTEXT", nil, 0, 0, 150, 100);
  if type == "add" then
    ui.AddContextMenuItem(context, "Add Bookmark", string.format('BookmarkWarp.AddBookmark("%s", %d)', warpName, warpcost));
  else
    ui.AddContextMenuItem(context, "Remove Bookmark", string.format('BookmarkWarp.RemoveBookmark("%s")', warpName));
  end
  context:Resize(context:GetWidth(), context:GetHeight());
  ui.OpenContextMenu(context);
end

-- add bookmark
function BookmarkWarp.AddBookmark(warpName, warpcost)
  local warpCls = GetClass('camp_warp', warpName)
  local mapCls = GetClass("Map", warpCls.Zone);

  local i = table.find(BookmarkWarp.settings.bookmarkList, warpName);
  if i ~= 0 then
    return;
  end

  table.insert(BookmarkWarp.settings.bookmarkList, warpName);
  local i = #BookmarkWarp.settings.bookmarkList;
  BookmarkWarp.CreateButton(i, warpName, warpcost);
  BookmarkWarp.SaveSettings();
  local frame = ui.GetFrame('bookmarkwarp');
  frame:Resize(300, i*48+10);
  frame:ShowWindow(1);
end

-- remove bookmark.
function BookmarkWarp.RemoveBookmark(warpName)
  local i = table.find(BookmarkWarp.settings.bookmarkList, warpName);
  if i ~= 0 then
    table.remove(BookmarkWarp.settings.bookmarkList, i);
    local frame = ui.GetFrame('bookmarkwarp');
    frame:RemoveChild("warpButton_"..warpName);
  end
  BookmarkWarp.ButtonAlignment();
end

-- OPEN_WORLDMAP Hook.
function BookmarkWarp.CloseWorldMap(frame)
  local warp = ui.GetFrame('bookmarkwarp');
  warp:RemoveAllChild();
  warp:ShowWindow(0);
  -- call original method.
  BookmarkWarp.CloseWorldMapHook(frame);
end

-- CLOSE_WORLDMAP Hook.
function BookmarkWarp.OpenWorldMap(frame)
  showFrame = false;
  local warp = ui.GetFrame('bookmarkwarp');
  warp:ShowWindow(0);
  for i, v in ipairs(BookmarkWarp.settings.bookmarkList) do
    BookmarkWarp.CreateButton(i, v, -1);
  end
  local y = #BookmarkWarp.settings.bookmarkList;
  warp:Resize(300, y*48+10);

  usedItem = false;
  local warpFrame = ui.GetFrame('worldmap');
  local warpitemname = warpFrame:GetUserValue('SCROLL_WARP');
  if warpitemname ~= 'NO' and warpitemname ~= 'None' then
    usedItem = true;
  end
  -- call original method.
  BookmarkWarp.OpenWorldMapHook(frame);
  
  if showFrame == true then
    warp:ShowWindow(1);
    warp:SetPos(BookmarkWarp.settings.position.x , BookmarkWarp.settings.position.y);
  end
  --CHAT_SYSTEM("OpenWorldMap");
end

-- initialize.
function BOOKMARKWARP_ON_INIT(addon, frame)
  BookmarkWarp.Init();
  BookmarkWarp.InitFrame();

  if BookmarkWarp.OnInitWarpSubHook == nil then
    BookmarkWarp.OnInitWarpSubHook = ON_INTE_WARP_SUB;
  end
  ON_INTE_WARP_SUB = function(frame, pic, index, gBoxName, nowZoneName, warpcost, calcOnlyPosition, makeWorldMapImage, mapCls, info, picX, picY, brushX, brushY, bySkill)
    BookmarkWarp.OnInitWarpSub(frame, pic, index, gBoxName, nowZoneName, warpcost, calcOnlyPosition, makeWorldMapImage, mapCls, info, picX, picY, brushX, brushY, bySkill);
  end

  if BookmarkWarp.OpenWorldMapHook == nil then
    BookmarkWarp.OpenWorldMapHook = OPEN_WORLDMAP;
  end
  OPEN_WORLDMAP = function(frame)
    BookmarkWarp.OpenWorldMap(frame);
  end

  if BookmarkWarp.CloseWorldMapHook == nil then
    BookmarkWarp.CloseWorldMapHook = CLOSE_WORLDMAP;
  end
  CLOSE_WORLDMAP = function(frame)
    BookmarkWarp.CloseWorldMap(frame);
  end
end
