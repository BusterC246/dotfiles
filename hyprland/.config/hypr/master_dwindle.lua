local state = {
  order = {},
  mfact = 0.5,
}

local function clamp(x, min, max)
  return math.max(min, math.min(max, x))
end

local function is_box(b)
  return type(b) == "table"
      and type(b.x) == "number"
      and type(b.y) == "number"
      and type(b.w) == "number"
      and type(b.h) == "number"
end

local function split_box(box, side, ratio)
  if not is_box(box) then
    error("split_box: expected HL.Box {x,y,w,h}")
  end

  ratio = clamp(ratio, 0.0, 1.0)

  local x, y, w, h = box.x, box.y, box.w, box.h

  if side == "left" then
    local tw    = math.floor(w * ratio)
    local taken = { x = x, y = y, w = tw, h = h }
    local rest  = { x = x + tw, y = y, w = w - tw, h = h }
    return taken, rest
  elseif side == "right" then
    local tw    = math.floor(w * ratio)
    local taken = { x = x + (w - tw), y = y, w = tw, h = h }
    local rest  = { x = x, y = y, w = w - tw, h = h }
    return taken, rest
  elseif side == "top" or side == "up" then
    local th    = math.floor(h * ratio)
    local taken = { x = x, y = y, w = w, h = th }
    local rest  = { x = x, y = y + th, w = w, h = h - th }
    return taken, rest
  elseif side == "bottom" or side == "down" then
    local th    = math.floor(h * ratio)
    local taken = { x = x, y = y + (h - th), w = w, h = th }
    local rest  = { x = x, y = y, w = w, h = h - th }
    return taken, rest
  end

  error("split_box: invalid side " .. tostring(side))
end

local function target_id(target)
  local window = target.window
  if window and window.stable_id ~= nil then
    return tostring(window.stable_id)
  end
  return tostring(target.index)
end

local function index_of(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      return i
    end
  end
end

local function active_id(ctx)
  for _, target in ipairs(ctx.targets) do
    local window = target.window
    if window and window.active then
      return target_id(target)
    end
  end
end

local function sync_order(ctx)
  local present = {}
  local targets = {}

  for _, target in ipairs(ctx.targets) do
    local id = target_id(target)
    present[id] = true
    targets[id] = target
  end

  local old_order = state.order
  state.order = {}

  for _, id in ipairs(old_order) do
    if present[id] then
      table.insert(state.order, id)
    end
  end

  for _, target in ipairs(ctx.targets) do
    local id = target_id(target)
    if not index_of(state.order, id) then
      table.insert(state.order, id)
    end
  end

  return targets
end

local function move_active(ctx, delta)
  local id = active_id(ctx)
  local i = id and index_of(state.order, id)
  local j = i and (i + delta)

  if not i or not j or j < 1 or j > #state.order then
    return
  end

  state.order[i], state.order[j] = state.order[j], state.order[i]
end

local function swap_active_with_master(ctx)
  local n = #state.order
  if n < 2 then
    return
  end

  local id = active_id(ctx)
  local i = id and index_of(state.order, id)
  if not i then
    return
  end

  local j = (i == 1) and 2 or 1
  state.order[i], state.order[j] = state.order[j], state.order[i]
end

local function place_slave_dwindle(targets, ids, area)
  local n = #ids
  if n == 0 then
    return
  end

  local cur = area

  for i, id in ipairs(ids) do
    local target = targets[id]
    if target then
      if i == n then
        target:place(cur)
      else
        local side = (i % 2 == 1) and "top" or "left"
        local taken, rest = split_box(cur, side, 0.5)
        target:place(taken)
        cur = rest
      end
    end
  end
end

hl.layout.register("master_dwindle", {
  recalculate = function(ctx)
    local targets = sync_order(ctx)
    local n = #state.order
    if n == 0 then
      return
    end

    local master = targets[state.order[1]]
    if not master then
      return
    end

    if n == 1 then
      master:place(ctx.area)
      return
    end

    local master_area, slave_area = split_box(ctx.area, "left", state.mfact)
    master:place(master_area)

    local slave_ids = {}
    for i = 2, n do
      slave_ids[#slave_ids + 1] = state.order[i]
    end

    place_slave_dwindle(targets, slave_ids, slave_area)
  end,

  layout_msg = function(ctx, msg)
    sync_order(ctx)

    if type(msg) ~= "string" then
      return "master_dwindle: layout_msg expects a string, got " .. type(msg)
    end

    local command, arg = msg:match("^(%S+)%s*(.*)$")

    if command == "mfact" then
      state.mfact = clamp(tonumber(arg) or state.mfact, 0.05, 0.95)
    elseif command == "grow" then
      state.mfact = clamp(state.mfact + 0.05, 0.05, 0.95)
    elseif command == "shrink" then
      state.mfact = clamp(state.mfact - 0.05, 0.05, 0.95)
    elseif command == "swapwithmaster" or command == "promote" then
      swap_active_with_master(ctx)
    elseif command == "swapnext" then
      move_active(ctx, 1)
    elseif command == "swapprev" then
      move_active(ctx, -1)
    else
      return "master_dwindle: expected mfact <0.05..0.95>, grow, shrink, swapwithmaster, promote, swapnext, or swapprev"
    end

    return true
  end,
})
