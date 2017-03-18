CHAT_SYSTEM(string.format("%s loaded", "Useful ID UI"));

local UsefulIDUI = {};
local indunFrame = nil;
local select = 2;
local reEnter = 0;
local button = {};
local event = {};

function UsefulIDUI.ShowIndunenterDialog(indunType, isAlreadyPlaying, enableAutoMatch)
  UsefulIDUI.ShowIndunenterDialogHook(indunType, isAlreadyPlaying, enableAutoMatch);
  reEnter = isAlreadyPlaying;
  select = 2;

  local frame = ui.GetFrame("indunenter");
  indunFrame = frame;
  local enterBtn = GET_CHILD_RECURSIVELY(frame, 'enterBtn'); --INDUNENTER_ENTER(frame, ctrl)
	local autoMatchBtn = GET_CHILD_RECURSIVELY(frame, 'autoMatchBtn'); --INDUNENTER_AUTOMATCH(frame, ctrl)
	local withPartyBtn = GET_CHILD_RECURSIVELY(frame, 'withBtn'); --INDUNENTER_PARTYMATCH(frame, ctrl)
	local reEnterBtn = GET_CHILD_RECURSIVELY(frame, 'reEnterBtn'); --INDUNENTER_REENTER(frame, ctrl)
  
  button[1] = reEnterBtn;
  button[2] = autoMatchBtn;
  button[3] = withPartyBtn;
  button[4] = enterBtn;

  event[1] = INDUNENTER_REENTER;
  event[2] = INDUNENTER_AUTOMATCH;
  event[3] = INDUNENTER_PARTYMATCH;
  event[4] = UsefulIDUI.IndunenterEnter;

  local width = button[select]:GetWidth();
  local x, y = GET_SCREEN_XY(button[select], width/2.5);
  mouse.SetPos(x,y);
  mouse.SetHidable(0);
  frame:RunUpdateScript("USEFULIDUI_UPDATE");
end

function UsefulIDUI.IndunenterClose(frame, msg, argStr, argNum)
  UsefulIDUI.IndunenterCloseHook(frame, msg, argStr, argNum);
  frame:StopUpdateScript("USEFULIDUI_UPDATE");
end

function USEFULIDUI_UPDATE()
  if indunFrame:GetUserValue('FRAME_MODE') == "SMALL" then
    return 1;
  end

  -- matching...
  if indunFrame:GetUserValue('AUTOMATCH_MODE') == 'YES' then
    if keyboard.IsKeyDown("SPACE") == 1 or joystick.GetDownJoyStickBtn() == "JOY_BTN_3" then
      INDUNENTER_AUTOMATCH_CANCEL();
      --INDUNENTER_PARTYMATCH_CANCEL();
    end
    return 1;
  end

  -- with match
  if indunFrame:GetUserValue('WITHMATCH_MODE') == 'YES' then
    if keyboard.IsKeyDown("SPACE") == 1 or joystick.GetDownJoyStickBtn() == "JOY_BTN_3" then
      event[3](indunFrame, button[3]);
    end
    return 1;
  end

  -- key input
  if keyboard.IsKeyDown("UP") == 1 or joystick.GetDownJoyStickBtn() == "JOY_UP" then
    UsefulIDUI.AddSelect(-1);
    local width = button[select]:GetWidth();
    local x, y = GET_SCREEN_XY(button[select], width/2.5);
    mouse.SetPos(x,y);
    mouse.SetHidable(0);
  end
  if keyboard.IsKeyDown("DOWN") == 1 or joystick.GetDownJoyStickBtn() == "JOY_DOWN" then
    UsefulIDUI.AddSelect(1);
    local width = button[select]:GetWidth();
    local x, y = GET_SCREEN_XY(button[select], width/2.5);
    mouse.SetPos(x,y);
    mouse.SetHidable(0);
  end

  if keyboard.IsKeyDown("SPACE") == 1 or joystick.GetDownJoyStickBtn() == "JOY_BTN_3" then
    event[select](indunFrame, button[select]);
  end
  return 1;
end

function UsefulIDUI.AddSelect(value)
  select = select + value;
  local min = 1;
  if reEnter == 0 then min = 2 end

  if select < min then select = 4 end
  if select > 4 then select = min end
end

function UsefulIDUI.IndunenterEnter(frame, ctrl)
  ReqMoveToIndun(1, 0);
end

-- initialize.
function USEFULIDUI_ON_INIT(addon, frame)
  if UsefulIDUI.ShowIndunenterDialogHook == nil then
    UsefulIDUI.ShowIndunenterDialogHook = SHOW_INDUNENTER_DIALOG;
    SHOW_INDUNENTER_DIALOG = function(indunType, isAlreadyPlaying, enableAutoMatch)
      UsefulIDUI.ShowIndunenterDialog(indunType, isAlreadyPlaying, enableAutoMatch);
    end
  end

  if UsefulIDUI.IndunenterCloseHook == nil then
    UsefulIDUI.IndunenterCloseHook = INDUNENTER_CLOSE;
    INDUNENTER_CLOSE = function(frame, msg, argStr, argNum)
      UsefulIDUI.IndunenterClose(frame, msg, argStr, argNum);
    end
  end
end
