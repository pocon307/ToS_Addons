CHAT_SYSTEM(string.format("%s loaded", "Extended Inventory"));
	
local acutil = require("acutil");
local addonName = "ExtendedInventory";

_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][addonName] = _G["ADDONS"][addonName] or {};
local ExInventory = _G["ADDONS"][addonName];

local tabList = {"NonEquipGroup", "Recipe", "Cube", "Premium", "Etc"};
local buttonName = {"Item", "Recipe", "Cube", "Premium", "WCL_Etc"};

function ExInventory.Init()
  local frame = ui.GetFrame('inventory');
  local invGbox = frame:GetChild('inventoryGbox');
  local tab = GET_CHILD(invGbox, 'inventype_Tab', 'ui::CTabControl');
  tab:Resize(470, 80);

	local tree_box = GET_CHILD_RECURSIVELY(invGbox, 'treeGbox_Item');
	local tree_box_E = GET_CHILD_RECURSIVELY(invGbox, 'treeGbox_Equip');
  
  local offsetY = 50;--moncardGbox:GetHeight();
	local invGboxOriX = invGbox:GetOriginalX();
	local invGboxOriY = invGbox:GetOriginalY();
	local invGboxW = invGbox:GetWidth();
	local invGboxH = invGbox:GetHeight();

  local treeOriX = tree_box:GetOriginalX();
  local treeOriY = tree_box:GetOriginalY();
	local tree_boxW = tree_box:GetWidth();
	local tree_boxH = tree_box:GetHeight();
	local tree_boxW_E = tree_box_E:GetWidth();
	local tree_boxH_E = tree_box_E:GetHeight();
  
  tree_box_E:Resize(treeOriX, treeOriY + offsetY, tree_boxW_E, tree_boxH_E - offsetY);
  tree_box_E:SetScrollBar(tree_boxH_E - offsetY);
  tree_box:Resize(treeOriX, treeOriY + offsetY, tree_boxW, tree_boxH - offsetY);
  tree_box:SetScrollBar(tree_boxH - offsetY);

  for i=1, #tabList do
    local button = tab:CreateOrGetControl('button',"exbutton_"..tabList[i] ,92*(i-1), 40, 92, 45);
    tolua.cast(button, "ui::CButton")
    button:SetText("{@st66b14}"..ScpArgMsg(buttonName[i]));
    --SetEventScriptで呼び出されるものはPUBLICでなくてはいけない
    --SetEventScriptの引数は、ArgStringとArgNumberで指定する
    button:SetEventScript(ui.LBUTTONUP, 'EXTENDEDINVENTORY_TABBUTTON');
    button:SetEventScriptArgString(ui.LBUTTONUP, tabList[i]);
    button:SetSkinName('base_btn'); -- test_pvp_btn test_normal_button
    button:SetOverSound('button_cursor_over_2');
    button:SetClickSound('inven_arrange');
  end
  button = tab:CreateOrGetControl('button',"exbutton_Equip" ,-2, -2, 154, 43);
  tolua.cast(button, "ui::CButton")
  button:SetText("{@st66b}"..ScpArgMsg("TP_EquipItem"));
  --SetEventScriptで呼び出されるものはPUBLICでなくてはいけない
  --SetEventScriptの引数は、ArgStringとArgNumberで指定する
  button:SetEventScript(ui.LBUTTONUP, 'EXTENDEDINVENTORY_TABITEM');
  button:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
  button:SetSkinName('base_btn');
  button:SetOverSound('button_cursor_over_2');
  button:SetClickSound('inven_arrange');

  button = tab:CreateOrGetControl('button',"exbutton_Item" ,148, -2, 154, 43);
  tolua.cast(button, "ui::CButton")
  button:SetText("{@st66b}"..ScpArgMsg("Item"));
  --SetEventScriptで呼び出されるものはPUBLICでなくてはいけない
  --SetEventScriptの引数は、ArgStringとArgNumberで指定する
  button:SetEventScript(ui.LBUTTONUP, 'EXTENDEDINVENTORY_TABITEM');
  button:SetEventScriptArgNumber(ui.LBUTTONUP, 1);
  button:SetSkinName('base_btn');
  button:SetOverSound('button_cursor_over_2');
  button:SetClickSound('inven_arrange');
end

function EXTENDEDINVENTORY_TABITEM(frame, ctrl, argStr, index)
  local frame = ui.GetFrame('inventory');
  local group = GET_CHILD(frame, 'inventoryGbox', 'ui::CGroupBox');
  local tab = GET_CHILD(group, 'inventype_Tab', 'ui::CTabControl');
  tab:SelectTab(index);
  INVENTORY_TOTAL_LIST_GET(frame);
end

function EXTENDEDINVENTORY_TABBUTTON(frame, ctrl, tabName, argNum)
  local frame = ui.GetFrame('inventory');
  local group = GET_CHILD(frame, 'inventoryGbox', 'ui::CGroupBox');
  local tab = GET_CHILD(group, 'inventype_Tab', 'ui::CTabControl');
  tab:SelectTab(1);

  ExInventory.tabName = tabName;
  INVENTORY_TOTAL_LIST_GET(frame);
  ExInventory.tabName = nil;
end

function ExInventory.InventoryOpen(frame)
  ExInventory.Init();
  ExInventory.InventoryOpenHook(frame);
end

function ExInventory.InsertItemToTree(frame, tree, invItem, itemCls, baseidcls)
  --CHAT_SYSTEM(baseidcls.TreeGroup..":"..itemCls.ClassName)
  if ExInventory.tabName == nil then
    ExInventory.InsertItemToTreeHook(frame, tree, invItem, itemCls, baseidcls);
  elseif ExInventory.tabName == baseidcls.TreeGroup then
    ExInventory.InsertItemToTreeHook(frame, tree, invItem, itemCls, baseidcls);
  elseif ExInventory.tabName == "Etc" then
    local find = 0;
    for i=1, #tabList-1 do
      if tabList[i] == baseidcls.TreeGroup then
        find = 1;
        break;
      end
    end
    if find == 0 then
      ExInventory.InsertItemToTreeHook(frame, tree, invItem, itemCls, baseidcls);
    end
  end
  
  
end

function EXTENDEDINVENTORY_ON_INIT(addon, frame)
  if ExInventory.InsertItemToTreeHook == nil then
    ExInventory.InsertItemToTreeHook = INSERT_ITEM_TO_TREE;
    INSERT_ITEM_TO_TREE = function(frame, tree, invItem, itemCls, baseidcls)
      ExInventory.InsertItemToTree(frame, tree, invItem, itemCls, baseidcls);
    end
  end

  if ExInventory.InventoryOpenHook == nil then
    ExInventory.InventoryOpenHook = INVENTORY_OPEN;
    INVENTORY_OPEN = function(frame)
      ExInventory.InventoryOpen(frame);
    end
  end
end

-- inven_baseid.ies
--[[ sset_
clasID baseID ClassName TreeGroup TreeGroupCaption TreeSSetTitle
1	5001	Weapon	EquipGroup	장비	무기
2	10001	Armor	EquipGroup	장비	방어구
3	15001	SubWeapon	EquipGroup	장비	서브웨폰
4	20001	Outer	EquipGroup	장비	코스튬
5	25001	Accessory	EquipGroup	장비	악세서리
6	30001	Consume	NonEquipGroup	아이템	소비
7	35001	Gem	NonEquipGroup	아이템	젬
8	40001	Recipe_Weapon	Recipe	제작서	무기
9	45001	Card	Card	카드	카드
10	50001	Collection	NonEquipGroup	아이템	콜렉션
11	55001	Book	NonEquipGroup	아이템	책
12	60001	Quest	QuestGroup	퀘스트	퀘스트
13	65001	PetWeapon	PetEquipGroup	컴패니언장비	무기
14	70001	PetArmor	PetEquipGroup	컴패니언장비	방어구
15	75001	Unused	Unused	사용안함[인벤에서 안보임]	사용안함[인벤에서 안보임]
16	80001	Etc	NonEquipGroup	아이템	재료
17	85001	Cube	Cube	큐브	큐브
18	90001	Premium	Premium	프리미엄	프리미엄
19	95001	Recipe_Armor	Recipe	제작서	방어구
20	100001	Recipe_Accessory	Recipe	제작서	장신구
21	105001	Recipe_Premium	Recipe	제작서	프리미엄
22	110001	Recipe	Recipe	제작서	기타
]]


