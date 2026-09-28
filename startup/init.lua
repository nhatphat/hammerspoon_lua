local M = {}

local HOME = os.getenv("HOME")
local HAMMERSPOON_DIR = hs.configdir

local LOCAL_CONFIG = HOME .. "/.config/hammerspoon/startup.lua"

-- ============================================================
-- Path helpers
-- ============================================================

-- Expand các path portable:
--
--   ~
--   ~/foo
--   $HOME/foo
--   ${HOME}/foo
--   $HAMMERSPOON/foo
--
-- thành absolute path trên máy hiện tại.
local function expandPath(value)
	if type(value) ~= "string" then
		return value
	end

	if value == "~" then
		return HOME
	end

	if value:sub(1, 2) == "~/" then
		return HOME .. value:sub(2)
	end

	value = value:gsub("^%$HOME", HOME)
	value = value:gsub("^%${HOME}", HOME)

	value = value:gsub("^%$HAMMERSPOON", HAMMERSPOON_DIR)

	return value
end

-- Expand path bên trong toàn bộ args.
local function expandArgs(args)
	local result = {}

	for _, arg in ipairs(args or {}) do
		table.insert(result, expandPath(arg))
	end

	return result
end

-- ============================================================
-- Boot ID
-- ============================================================

-- Lấy thời điểm boot của macOS.
--
-- Ví dụ:
--
--   { sec = 1790550000, usec = 123456 }
--
-- Ta dùng phần "sec" làm boot ID.
--
-- Reload Hammerspoon:
--   boot ID không đổi.
--
-- Reboot macOS:
--   boot ID thay đổi.
local function getBootId()
	local output, ok = hs.execute("/usr/sbin/sysctl -n kern.boottime")

	if not ok or not output then
		return nil
	end

	return output:match("sec%s*=%s*(%d+)")
end

-- ============================================================
-- Local/private config
-- ============================================================

local function emptyConfig()
	return {
		boot = {},
		reload = {},
	}
end

-- Đọc private config:
--
--   ~/.config/hammerspoon/startup.lua
--
-- File phải return một Lua table:
--
--   return {
--       boot = {},
--       reload = {},
--   }
--
-- Nếu file không tồn tại thì coi như không có private task.
local function readLocalConfig()
	local file = io.open(LOCAL_CONFIG, "r")

	if not file then
		return emptyConfig()
	end

	file:close()

	-- loadfile chỉ compile/load Lua file,
	-- chưa thực thi nội dung ngay.
	local chunk, err = loadfile(LOCAL_CONFIG)

	if not chunk then
		print("[startup] Không load được local config:")
		print(err)

		return emptyConfig()
	end

	-- Chạy config trong protected call.
	--
	-- Nếu config có syntax/runtime error,
	-- Hammerspoon vẫn tiếp tục chạy bình thường.
	local ok, config = pcall(chunk)

	if not ok then
		print("[startup] Local config lỗi:")
		print(config)

		return emptyConfig()
	end

	if type(config) ~= "table" then
		print("[startup] Local config phải return table")

		return emptyConfig()
	end

	config.boot = config.boot or {}

	config.reload = config.reload or {}

	return config
end

-- ============================================================
-- Task identity / boot state
-- ============================================================

-- Mỗi boot task có state riêng.
--
-- Ví dụ:
--
--   id = "patch-xxx"
--   version = 2
--
-- sẽ lưu dưới key:
--
--   startup.boot.patch-xxx.v2
--
-- Value là boot ID gần nhất mà task chạy thành công.
local function taskStateKey(task)
	local version = task.version or 1

	return string.format("startup.boot.%s.v%s", task.id, tostring(version))
end

-- Check task đã chạy thành công
-- trong boot hiện tại chưa.
local function hasRunThisBoot(task, bootId)
	return hs.settings.get(taskStateKey(task)) == bootId
end

-- Chỉ gọi sau khi boot task chạy thành công.
local function markRunThisBoot(task, bootId)
	hs.settings.set(taskStateKey(task), bootId)
end

-- ============================================================
-- Validation
-- ============================================================

local function validateTask(task)
	if type(task) ~= "table" then
		return false, "task không phải table"
	end

	if not task.id or task.id == "" then
		return false, "thiếu id"
	end

	if not task.command or task.command == "" then
		return false, "thiếu command"
	end

	return true
end

local function taskName(task)
	return task.name or task.id or "unknown-task"
end

-- ============================================================
-- Task runner
-- ============================================================

-- Chạy một task.
--
-- callback(true)
--   task success
--
-- callback(false)
--   task fail
local function runTask(task, callback)
	local name = taskName(task)

	local command = expandPath(task.command)

	local args = expandArgs(task.args)

	local cwd = expandPath(task.cwd)

	print("[startup] Chạy: " .. name)

	local process = hs.task.new(command, function(exitCode, stdout, stderr)
		if exitCode == 0 then
			print("[startup] ✓ " .. name)

			callback(true)
			return
		end

		print("[startup] ✗ " .. name .. " exit=" .. tostring(exitCode))

		if stdout and stdout ~= "" then
			print(stdout)
		end

		if stderr and stderr ~= "" then
			print(stderr)
		end

		callback(false)
	end, args)

	if cwd and cwd ~= "" then
		process:setWorkingDirectory(cwd)
	end

	local started = process:start()

	if not started then
		print("[startup] ✗ Không start được " .. name)

		callback(false)
	end
end

-- ============================================================
-- Sequential queue
-- ============================================================

-- Chạy tuần tự đúng thứ tự khai báo.
--
-- Task N+1 chỉ chạy sau khi task N kết thúc.
local function runQueue(tasks, index, options)
	index = index or 1

	options = options or {}

	-- Chạy hết queue.
	if index > #tasks then
		if options.onComplete then
			options.onComplete()
		end

		return
	end

	local task = tasks[index]

	local name = taskName(task)

	-- Task bị disable thì skip.
	if task.enabled == false then
		print("[startup] - Skip disabled: " .. name)

		runQueue(tasks, index + 1, options)

		return
	end

	local valid, reason = validateTask(task)

	if not valid then
		print("[startup] ✗ Invalid task " .. name .. ": " .. reason)

		runQueue(tasks, index + 1, options)

		return
	end

	-- Với boot task:
	--
	-- Nếu task đã success trong boot hiện tại
	-- thì không chạy lại.
	if options.bootId and hasRunThisBoot(task, options.bootId) then
		print("[startup] - Đã chạy trong boot này: " .. name)

		runQueue(tasks, index + 1, options)

		return
	end

	print(string.format("[startup] [%d/%d] %s", index, #tasks, name))

	runTask(task, function(success)
		-- Boot task chỉ được mark
		-- khi chạy thành công.
		--
		-- Nếu fail:
		-- lần Reload Config sau sẽ retry.
		if success and options.bootId then
			markRunThisBoot(task, options.bootId)
		end

		-- Optional:
		-- nếu muốn task fail thì dừng cả queue.
		if not success and options.stopOnFailure then
			print("[startup] Queue dừng vì task fail: " .. name)

			return
		end

		runQueue(tasks, index + 1, options)
	end)
end

-- ============================================================
-- Merge public + private
-- ============================================================

local function appendAll(destination, source)
	for _, task in ipairs(source or {}) do
		table.insert(destination, task)
	end
end

local function loadTasks()
	-- Config public nằm trong repo.
	local public = require("startup.public")

	-- Config private nằm ngoài repo.
	local private = readLocalConfig()

	public = public or {}

	local boot = {}
	local reload = {}

	-- Public task chạy trước.
	appendAll(boot, public.boot)

	appendAll(reload, public.reload)

	-- Private task chạy sau.
	appendAll(boot, private.boot)

	appendAll(reload, private.reload)

	return boot, reload
end

-- ============================================================
-- Setup
-- ============================================================

function M.setup()
	local bootTasks, reloadTasks = loadTasks()

	local bootId = getBootId()

	if not bootId then
		print("[startup] Không lấy được boot ID")
	end

	-- Delay một chút để macOS ổn định
	-- sau login / Hammerspoon startup.
	hs.timer.doAfter(5, function()
		-- =================================================
		-- Boot tasks
		--
		-- Mỗi task:
		--   - chỉ success 1 lần / boot
		--   - fail thì lần reload sau retry
		-- =================================================

		if bootId and #bootTasks > 0 then
			print("[startup] === Boot tasks ===")

			runQueue(bootTasks, 1, {
				bootId = bootId,

				-- Một task fail không chặn
				-- các startup task khác.
				stopOnFailure = false,

				onComplete = function()
					print("[startup] Boot queue hoàn tất")
				end,
			})
		end

		-- =================================================
		-- Reload tasks
		--
		-- Luôn chạy mỗi lần Hammerspoon Reload Config.
		-- =================================================

		if #reloadTasks > 0 then
			print("[startup] === Reload tasks ===")

			runQueue(reloadTasks, 1, {
				stopOnFailure = false,

				onComplete = function()
					print("[startup] Reload queue hoàn tất")
				end,
			})
		end
	end)
end

return M
