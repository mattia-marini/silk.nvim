local M = {}

-- Moves the focus in the specified direction.
-- If a Kitty window exists immediately in that direction, it will be focused instead.
function M.go_to_window(direction)
  local nvim_direction
  local kitty_direction
  if direction == "left" then
    nvim_direction = "h"
    kitty_direction = "left"
  elseif direction == "right" then
    nvim_direction = "l"
    kitty_direction = "right"
  elseif direction == "up" then
    nvim_direction = "k"
    kitty_direction = "top"
  elseif direction == "down" then
    nvim_direction = "j"
    kitty_direction = "bottom"
  else
    vim.notify.error("Invalid direction. Use 'left', 'right', 'up', or 'down'.")
    return
  end

  local current_win_id = vim.api.nvim_get_current_win()
  local adj_win_id = vim.fn.win_getid(vim.fn.winnr(nvim_direction))



  if adj_win_id ~= current_win_id then
    vim.api.nvim_set_current_win(adj_win_id)
  else
    vim.system({
        "kitten", "@", "focus-window",
        "--match=neighbor:" .. kitty_direction,
        "--no-response"
      }, {},
      function(obj)
        if obj.code ~= 0 then
          vim.notify.error("Failed to focus window: " .. obj.stderr)
          return
        end
      end
    )
  end
end

-- The function is not needed. vim.fn.winnr('hjkl') can do the same
function M.is_adjacent_to_main_window(direction, node_id)
  if not (direction == "left" or direction == "right" or direction == "up" or direction == "down") then
    vim.node.error("Invalid direction. Use 'left', 'right', 'up', or 'down'.")
    return
  end

  if node_id == 0 or node_id == nil then
    node_id = vim.api.nvim_get_current_win()
  end

  local function has_neighbor_window_rec(tree_layout)
    local childs = tree_layout[2]

    -- windows arranged in a row
    if tree_layout[1] == "row" then
      if direction == "right" then
        return has_neighbor_window_rec(childs[#childs])
      elseif direction == "left" then
        return has_neighbor_window_rec(childs[1])
      elseif direction == "up" or direction == "down" then
        for _, child in ipairs(childs) do
          if has_neighbor_window_rec(child) then
            return true
          end
        end
        return false
      end

      -- windows arranged in a column
    elseif tree_layout[1] == "col" then
      if direction == "up" then
        return has_neighbor_window_rec(childs[1])
      elseif direction == "down" then
        return has_neighbor_window_rec(childs[#childs])
      elseif direction == "right" or direction == "left" then
        for _, child in ipairs(tree_layout[2]) do
          if has_neighbor_window_rec(child) then
            return true
          end
        end
        return false
      end

      -- single window
    elseif tree_layout[1] == "leaf" then
      return tree_layout[2] == node_id
    end
  end

  print(has_neighbor_window_rec(vim.fn.winlayout()))
  return
end

return M
