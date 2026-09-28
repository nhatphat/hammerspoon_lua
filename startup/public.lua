return {
	-- ========================================================
	-- BOOT TASKS
	--
	-- Chỉ chạy một lần thành công cho mỗi lần macOS boot.
	--
	-- Reload Hammerspoon:
	--   task đã success sẽ bị skip.
	--
	-- Task fail:
	--   reload Hammerspoon sẽ retry.
	-- ========================================================

	boot = {
		-- Ví dụ mở app:
		--
		-- {
		--     id = "open-ghostty",
		--     name = "Open Ghostty",
		--
		--     command = "/usr/bin/open",
		--     args = {
		--         "-a",
		--         "Ghostty",
		--     },
		-- },

		-- Ví dụ script nằm ngay trong repo Hammerspoon:
		--
		-- {
		--     id = "public-startup-script",
		--     name = "Public Startup Script",
		--
		--     command =
		--         "$HAMMERSPOON/scripts/startup.sh",
		--
		--     args = {},
		-- },

		-- Ví dụ force chạy lại sau khi sửa logic:
		--
		-- {
		--     id = "something",
		--     version = 2,
		--
		--     command = "~/bin/something",
		--     args = {},
		-- },
	},

	-- ========================================================
	-- RELOAD TASKS
	--
	-- Chạy mỗi lần:
	--
	--   Hammerspoon -> Reload Config
	--
	-- Dùng cho những thứ thực sự cần refresh khi config reload.
	-- ========================================================

	reload = {
		-- Ví dụ:
		--
		-- {
		--     id = "refresh-cache",
		--     name = "Refresh Cache",
		--
		--     command =
		--         "$HAMMERSPOON/scripts/refresh.sh",
		--
		--     args = {},
		-- },
	},
}
