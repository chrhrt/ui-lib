--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║ ui library made by spook                                                     ║
║ Full Documentation                                                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

local KeyNames = {
	[8]="Backspace",[9]="Tab",[13]="Enter",[16]="Shift",[17]="Ctrl",
	[18]="Alt",[19]="Pause",[20]="CapsLock",[27]="Esc",[32]="Space",
	[33]="PageUp",[34]="PageDown",[35]="End",[36]="Home",
	[37]="Left",[38]="Up",[39]="Right",[40]="Down",
	[45]="Insert",[46]="Delete",
	[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",
	[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
	[65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",
	[71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",
	[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",
	[83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",
	[89]="Y",[90]="Z",
	[112]="F1",[113]="F2",[114]="F3",[115]="F4",[116]="F5",
	[117]="F6",[118]="F7",[119]="F8",[120]="F9",[121]="F10",
	[122]="F11",[123]="F12",
}

local function KeyCodeToNumber(keyCode)
	if type(keyCode) == "number" then
		return keyCode
	end
	if typeof(keyCode) == "EnumItem" then
		return keyCode.Value
	end
	return 70
end

_G.UI = {}
_G.Flags = {
	Window = {},
	Tab = {},
	Section = {},
	Widgets = {
		Label = {},
		Button = {},
		Checkbox = {},
		Slider = {},
		Dropdown = {},
		MultiDropdown = {},
		Keybind = {},
		Textbox = {},
	},
}

function _G.UI:Window(Options)
	local libName = Options.Title or "LuxtLib"
	local windowSize = Options.Size or Vector2.new(580, 460)
	local windowOpen = Options.Open
	if windowOpen == nil then
		windowOpen = true
	end

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()

	local windowW = windowSize.X
	local windowH = windowSize.Y
	local sideW = 155
	local contentPadX = 8
	local contentPadY = 8
	local tabH = 28
	local tabPad = 4
	local sectionHeaderH = 32
	local elemH = 36
	local elemPad = 3
	local sectionPad = 5
	local dropItemH = 28
	local scrollSpeed = 35

	local Internal = {
		Running = true,
		Open = windowOpen,
		Dragging = false,
		DragStart = Vector2.new(0, 0),
		Position = Vector2.new(300, 100),
		ActiveTab = nil,
		ActiveSlider = nil,
		ListeningKeybind = nil,
		ListeningToggleKey = false,
		ListeningTextbox = nil,
		ToggleKeyCode = 0x12,
		ToggleKeyName = "Alt",
		ScrollOffset = 0,
		MaxScroll = 0,
		PrevMouse1 = false,
		PrevMouse2 = false,
		PrevKeys = {},
		OpenDropdown = nil,
		NeedsUpdate = true,
		LastScrollCheck = 0,
		ScrollUpHeld = false,
		ScrollDownHeld = false,
	}

	local tabs = {}
	local allDrawings = {}
	local allKeybindElems = {}

	local C = {
		shadow = Color3.fromRGB(10, 10, 10),
		bg = Color3.fromRGB(30, 30, 30),
		side = Color3.fromRGB(21, 21, 21),
		accent = Color3.fromRGB(70, 130, 180),
		accentBright = Color3.fromRGB(100, 160, 210),
		accentDark = Color3.fromRGB(50, 100, 150),
		disabled = Color3.fromRGB(97, 97, 97),
		disabledDark = Color3.fromRGB(60, 60, 60),
		elemBg = Color3.fromRGB(18, 18, 18),
		elemBgPress = Color3.fromRGB(70, 130, 180),
		textPrimary = Color3.fromRGB(255, 255, 255),
		textSecondary = Color3.fromRGB(180, 180, 180),
		textDim = Color3.fromRGB(97, 97, 97),
		inputBg = Color3.fromRGB(24, 24, 24),
		sliderTrack = Color3.fromRGB(24, 24, 24),
		sectionBg = Color3.fromRGB(21, 21, 21),
		dropOptionBg = Color3.fromRGB(51, 51, 51),
		dropOptionSel = Color3.fromRGB(50, 100, 150),
		dropOptionText = Color3.fromRGB(100, 160, 210),
		black = Color3.fromRGB(0, 0, 0),
		yellow = Color3.fromRGB(255, 255, 0),
		green = Color3.fromRGB(100, 200, 100),
	}

	local function makeSquare(p)
		local s = Drawing.new("Square")
		s.Filled = true
		s.Color = p.Color or Color3.new(1,1,1)
		s.Position = p.Position or Vector2.new(0,0)
		s.Size = p.Size or Vector2.new(0,0)
		s.Transparency = p.Transparency or 1
		s.Visible = false
		s.ZIndex = p.ZIndex or 1
		s.Corner = p.Corner or 0
		table.insert(allDrawings, s)
		return s
	end

	local function makeText(p)
		local t = Drawing.new("Text")
		t.Text = p.Text or ""
		t.Color = p.Color or Color3.new(1,1,1)
		t.Position = p.Position or Vector2.new(0,0)
		t.Size = p.FontSize or 14
		t.Font = p.Font or Drawing.Fonts.System
		t.Center = p.Center or false
		t.Visible = false
		t.ZIndex = p.ZIndex or 2
		t.Outline = p.Outline or false
		t.Transparency = p.Transparency or 1
		table.insert(allDrawings, t)
		return t
	end

	local function makeLine(p)
		local l = Drawing.new("Line")
		l.Color = p.Color or Color3.new(1,1,1)
		l.From = p.From or Vector2.new(0,0)
		l.To = p.To or Vector2.new(0,0)
		l.Thickness = p.Thickness or 1
		l.Visible = false
		l.ZIndex = p.ZIndex or 2
		l.Transparency = p.Transparency or 1
		table.insert(allDrawings, l)
		return l
	end

	local function isMouseInRect(px, py, pw, ph)
		local mx, my = Mouse.X, Mouse.Y
		return mx >= px and mx <= px + pw and my >= py and my <= py + ph
	end

	local function estW(text, fs)
		return #text * (fs * 0.52)
	end

	local function getContentX() return Internal.Position.X + sideW + contentPadX end
	local function getContentY() return Internal.Position.Y + contentPadY end
	local function getContentW() return windowW - sideW - contentPadX * 2 end
	local function getContentH() return windowH - contentPadY * 2 end

	local function isFullyVisible(y, h)
		local viewTop = getContentY()
		local viewBottom = getContentY() + getContentH()
		return y >= viewTop and (y + h) <= viewBottom
	end

	local shadowBg = makeSquare({Color=C.shadow, ZIndex=0, Corner=7, Transparency=0.3})
	local mainBg = makeSquare({Color=C.bg, ZIndex=1, Corner=5})
	local sideBg = makeSquare({Color=C.side, ZIndex=2, Corner=5})
	local sideCover = makeSquare({Color=C.side, ZIndex=2})
	local divLine = makeLine({Color=C.accentDark, ZIndex=3, Thickness=1})
	local hubText = makeText({Text=libName, Color=C.accent, FontSize=24, Font=Drawing.Fonts.SystemBold, ZIndex=3})
	local userText = makeText({Text=LocalPlayer.Name, Color=C.accentBright, FontSize=10, Font=Drawing.Fonts.SystemBold, ZIndex=3})

	local togBtnW = 76
	local togBtnH = 22
	local togBg = makeSquare({Color=C.inputBg, ZIndex=3, Corner=5})
	local togTxt = makeText({Text="Alt", Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=4, Center=true, Outline=false})
	local togLbl = makeText({Text="Toggle", Color=C.textSecondary, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=3, Center=false})

	local function Update()
		if not Internal.Open then
			for _, d in ipairs(allDrawings) do
				d.Visible = false
			end
			return
		end

		local wx, wy = Internal.Position.X, Internal.Position.Y

		shadowBg.Position = Vector2.new(wx-4, wy-4)
		shadowBg.Size = Vector2.new(windowW+8, windowH+8)
		shadowBg.Visible = false

		mainBg.Position = Vector2.new(wx, wy)
		mainBg.Size = Vector2.new(windowW, windowH)
		mainBg.Visible = true

		sideBg.Position = Vector2.new(wx, wy)
		sideBg.Size = Vector2.new(sideW, windowH)
		sideBg.Visible = true

		sideCover.Position = Vector2.new(wx+sideW-5, wy)
		sideCover.Size = Vector2.new(5, windowH)
		sideCover.Visible = true

		divLine.From = Vector2.new(wx+10, wy+60)
		divLine.To = Vector2.new(wx+sideW-10, wy+60)
		divLine.Visible = true

		hubText.Position = Vector2.new(wx+15, wy+12)
		hubText.Visible = true

		userText.Position = Vector2.new(wx+15, wy+48)
		userText.Visible = true

		local toggleYPercent = 0.935
		local kbX = wx + 8
		local kbY = wy + math.floor(windowH * toggleYPercent) - togBtnH

		togBg.Position = Vector2.new(kbX, kbY)
		togBg.Size = Vector2.new(togBtnW, togBtnH)
		togBg.Visible = true

		if Internal.ListeningToggleKey then
			togTxt.Text = ". . ."
		else
			togTxt.Text = Internal.ToggleKeyName
		end
		togTxt.Color = C.accent
		togTxt.Position = Vector2.new(kbX + togBtnW/2, kbY + 10)
		togTxt.Visible = true

		togLbl.Position = Vector2.new(kbX + togBtnW + 8, kbY + math.floor((togBtnH - 13) / 2))
		togLbl.Visible = true

		local tabY = wy + 70
		for _, tab in ipairs(tabs) do
			tab.btnDraw.Position = Vector2.new(wx+15, tabY)
			tab.btnDraw.Color = (Internal.ActiveTab == tab) and C.accent or C.disabled
			tab.btnDraw.Visible = true
			tab.btnY = tabY
			tabY = tabY + tabH + tabPad
		end

		for _, tab in ipairs(tabs) do
			for _, sec in ipairs(tab.sections) do
				sec.hdrBg.Visible = false
				sec.hdrTxt.Visible = false
				sec.arrow.Visible = false
				for _, el in ipairs(sec.elements) do
					el.hide()
				end
			end
		end

		local totalContentH = 0
		if Internal.ActiveTab then
			for _, sec in ipairs(Internal.ActiveTab.sections) do
				totalContentH = totalContentH + sectionHeaderH + elemPad
				if sec.open then
					for _, el in ipairs(sec.elements) do
						totalContentH = totalContentH + el.getHeight() + elemPad
					end
				end
				totalContentH = totalContentH + sectionPad
			end
		end

		Internal.MaxScroll = math.max(0, totalContentH - getContentH())
		Internal.ScrollOffset = math.clamp(Internal.ScrollOffset, 0, Internal.MaxScroll)

		if Internal.ActiveTab then
			local cy = getContentY() - Internal.ScrollOffset
			local cx = getContentX()
			local cw = getContentW()

			for _, sec in ipairs(Internal.ActiveTab.sections) do
				local hdrVis = isFullyVisible(cy, sectionHeaderH)

				sec.hdrBg.Position = Vector2.new(cx, cy)
				sec.hdrBg.Size = Vector2.new(cw, sectionHeaderH)
				sec.hdrBg.Visible = hdrVis

				sec.hdrTxt.Position = Vector2.new(cx+10, cy + math.floor((sectionHeaderH - 14) / 2))
				sec.hdrTxt.Visible = hdrVis

				sec.arrow.Text = sec.open and "v" or ">"
				sec.arrow.Position = Vector2.new(cx+cw-20, cy + math.floor((sectionHeaderH - 14) / 2))
				sec.arrow.Visible = hdrVis

				sec.posY = cy
				sec.headerEndY = cy + sectionHeaderH
				cy = cy + sectionHeaderH + elemPad

				if sec.open then
					for _, el in ipairs(sec.elements) do
						local h = el.getHeight()
						local elemVis = isFullyVisible(cy, h)
						el.posY = cy
						el.posX = cx + 8
						el.width = cw - 16
						el.update(cx, cy, cw, h, elemVis)
						cy = cy + h + elemPad
					end
				end
				cy = cy + sectionPad
			end
		end
	end

	if windowOpen then
		pcall(setrobloxinput, false)
	end

	spawn(function()
		for i = 1, 255 do
			Internal.PrevKeys[i] = false
		end
		Internal.PrevMouse1 = ismouse1pressed()

		while Internal.Running do
			local mx, my = Mouse.X, Mouse.Y
			local m1 = ismouse1pressed()
			local m1Click = m1 and not Internal.PrevMouse1

			local newKeys = {}
			for i = 1, 255 do
				local ok, pressed = pcall(iskeypressed, i)
				if ok and pressed and not Internal.PrevKeys[i] then
					newKeys[i] = true
				end
				Internal.PrevKeys[i] = ok and pressed or false
			end

			if Internal.ListeningTextbox then
				local tb = Internal.ListeningTextbox
				for vk, _ in pairs(newKeys) do
					if vk == 13 then
						tb.focused = false
						Internal.ListeningTextbox = nil
						if tb.callback then tb.callback(tb.value) end
					elseif vk == 8 then
						if #tb.value > 0 then
							tb.value = tb.value:sub(1, -2)
						end
					elseif vk >= 32 and vk <= 126 then
						local char = string.char(vk)
						if not iskeypressed(0x10) then
							char = char:lower()
						end
						if #tb.value < 50 then
							tb.value = tb.value .. char
						end
					end
				end
			elseif Internal.ListeningToggleKey then
				for vk, _ in pairs(newKeys) do
					Internal.ToggleKeyCode = vk
					Internal.ToggleKeyName = KeyNames[vk] or string.format("0x%X", vk)
					Internal.ListeningToggleKey = false
					break
				end
			elseif Internal.ListeningKeybind then
				for vk, _ in pairs(newKeys) do
					Internal.ListeningKeybind.keyCode = vk
					Internal.ListeningKeybind.keyName = KeyNames[vk] or string.format("0x%X", vk)
					Internal.ListeningKeybind.listening = false
					if Internal.ListeningKeybind.onChanged then
						Internal.ListeningKeybind.onChanged(vk)
					end
					Internal.ListeningKeybind = nil
					break
				end
			else
				if newKeys[Internal.ToggleKeyCode] then
					Internal.Open = not Internal.Open
					pcall(setrobloxinput, not Internal.Open)
					Internal.NeedsUpdate = true
				end

				if Internal.Open then
					for _, kb in ipairs(allKeybindElems) do
						if not kb.listening and newKeys[kb.keyCode] then
							if kb.callback then kb.callback() end
						end
					end
				end
			end

			if Internal.Open then
				-- Mouse scroll using mousescroll function
				if isMouseInRect(getContentX(), getContentY(), getContentW(), getContentH()) then
					local scrolled = false
					pcall(function()
						mousescroll(0)
					end)
				end

				if Internal.Dragging then
					if m1 then
						Internal.Position = Vector2.new(mx - Internal.DragStart.X, my - Internal.DragStart.Y)
						Internal.NeedsUpdate = true
					else
						Internal.Dragging = false
					end
				end

				if Internal.ActiveSlider then
					if m1 then
						local slider = Internal.ActiveSlider
						local pct = math.clamp((mx - slider.trackX) / slider.trackW, 0, 1)
						local newVal = math.floor(slider.min + pct * (slider.max - slider.min))
						if newVal ~= slider.value then
							slider.value = newVal
							if slider.callback then slider.callback(newVal) end
							Internal.NeedsUpdate = true
						end
					else
						Internal.ActiveSlider = nil
					end
				end

				if m1Click and not Internal.Dragging and not Internal.ActiveSlider then
					local wx, wy = Internal.Position.X, Internal.Position.Y
					local handled = false

					if Internal.OpenDropdown and Internal.OpenDropdown.isOpen then
						local dd = Internal.OpenDropdown
						local oy = dd.lastY + elemH + elemPad

						if dd.multi then
							for i = 1, #dd.options do
								if isMouseInRect(dd.lastX, oy, dd.lastW, dropItemH) then
									local opt = dd.options[i]
									local found = false
									for j, sel in ipairs(dd.selected) do
										if sel == opt then
											table.remove(dd.selected, j)
											found = true
											break
										end
									end
									if not found then
										table.insert(dd.selected, opt)
									end
									if dd.callback then dd.callback(dd.selected) end
									handled = true
									Internal.NeedsUpdate = true
									break
								end
								oy = oy + dropItemH + elemPad
							end
						else
							for i = 1, #dd.options do
								if isMouseInRect(dd.lastX, oy, dd.lastW, dropItemH) then
									dd.selected = dd.options[i]
									if dd.callback then dd.callback(dd.options[i]) end
									dd.isOpen = false
									Internal.OpenDropdown = nil
									handled = true
									Internal.NeedsUpdate = true
									break
								end
								oy = oy + dropItemH + elemPad
							end
						end
					end

					if not handled then
						local toggleYPercent = 0.935
						local kbX = wx + 8
						local kbY = wy + math.floor(windowH * toggleYPercent) - togBtnH

						if isMouseInRect(kbX, kbY, togBtnW, togBtnH) then
							Internal.ListeningToggleKey = true
							handled = true
							Internal.NeedsUpdate = true
						elseif isMouseInRect(wx, wy, sideW, 60) then
							Internal.Dragging = true
							Internal.DragStart = Vector2.new(mx - wx, my - wy)
							handled = true
						else
							for _, tab in ipairs(tabs) do
								if isMouseInRect(wx+5, tab.btnY-2, sideW-10, tabH) then
									Internal.ActiveTab = tab
									Internal.ScrollOffset = 0
									if Internal.OpenDropdown then
										Internal.OpenDropdown.isOpen = false
										Internal.OpenDropdown = nil
									end
									handled = true
									Internal.NeedsUpdate = true
									break
								end
							end

							if not handled and Internal.ActiveTab then
								for _, sec in ipairs(Internal.ActiveTab.sections) do
									if handled then break end

									if sec.open then
										for _, el in ipairs(sec.elements) do
											if el.posY and el.posY > 0 then
												local elH = el.getHeight()
												if isFullyVisible(el.posY, elH) then
													if my >= el.posY and my <= el.posY + elH then
														if mx >= el.posX and mx <= el.posX + el.width then
															if el.onClick() then
																handled = true
																Internal.NeedsUpdate = true
																break
															end
														end
													end
												end
											end
										end
									end

									if not handled and sec.posY then
										if isFullyVisible(sec.posY, sectionHeaderH) then
											if my >= sec.posY and my < sec.headerEndY then
												if mx >= getContentX() and mx <= getContentX() + getContentW() then
													sec.open = not sec.open
													if Internal.OpenDropdown then
														Internal.OpenDropdown.isOpen = false
														Internal.OpenDropdown = nil
													end
													handled = true
													Internal.NeedsUpdate = true
												end
											end
										end
									end
								end
							end
						end
					end

					if not handled and Internal.OpenDropdown and not Internal.OpenDropdown.multi then
						Internal.OpenDropdown.isOpen = false
						Internal.OpenDropdown = nil
						Internal.NeedsUpdate = true
					end
				end
			end

			Internal.PrevMouse1 = m1
			task.wait(0.001)
		end
	end)

	-- Scroll detection thread using mouse position delta
	spawn(function()
		local lastMouseY = Mouse.Y
		local lastM2 = false
		
		while Internal.Running do
			if Internal.Open then
				local mx, my = Mouse.X, Mouse.Y
				local overContent = isMouseInRect(getContentX(), getContentY(), getContentW(), getContentH())
				
				if overContent and Internal.MaxScroll > 0 then
					local m2 = ismouse2pressed()
					
					if m2 then
						local deltaY = my - lastMouseY
						if math.abs(deltaY) > 0 then
							Internal.ScrollOffset = math.clamp(Internal.ScrollOffset + deltaY, 0, Internal.MaxScroll)
							Internal.NeedsUpdate = true
						end
					end
					
					lastM2 = m2
				end
				
				lastMouseY = my
			end
			task.wait(0.001)
		end
	end)

	spawn(function()
		while Internal.Running do
			if Internal.NeedsUpdate or Internal.Open then
				Update()
				Internal.NeedsUpdate = false
			end
			task.wait(0.001)
		end

		pcall(setrobloxinput, true)

		for _, d in ipairs(allDrawings) do
			pcall(function() d:Remove() end)
		end
	end)

	local WindowAPI = {}

	function WindowAPI:Tab(Options)
		local tabText = Options.Title or "Tab"
		local btnDraw = makeText({Text=tabText, Color=C.accent, FontSize=14, Font=Drawing.Fonts.System, ZIndex=3})

		local tab = {
			name = tabText,
			btnDraw = btnDraw,
			btnY = 0,
			sections = {},
		}

		table.insert(tabs, tab)
		if not Internal.ActiveTab then
			Internal.ActiveTab = tab
		end
		Internal.NeedsUpdate = true

		local TabAPI = {}

		function TabAPI:Section(Options)
			local secText = Options.Title or "Section"

			local hdrBg = makeSquare({Color=C.sectionBg, ZIndex=3, Corner=5})
			local hdrTxt = makeText({Text=secText, Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=4})
			local arrow = makeText({Text=">", Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=4, Outline=true})

			local section = {
				name = secText,
				open = false,
				hdrBg = hdrBg,
				hdrTxt = hdrTxt,
				arrow = arrow,
				posY = 0,
				headerEndY = 0,
				elements = {},
			}

			table.insert(tab.sections, section)
			Internal.NeedsUpdate = true

			local SectionAPI = {}

			function SectionAPI:Label(Options)
				local text = Options.Title or "Label"
				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=5})
				local tx = makeText({Text=text, Color=C.textPrimary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5, Center=true})

				local labelAPI = {}

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						tx.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis
						tx.Position = Vector2.new(x+8+(w-16)/2, y + math.floor((h - 14) / 2))
						tx.Visible = vis
					end,
					onClick = function() return false end,
				}
				table.insert(section.elements, elem)

				function labelAPI:Get()
					return tx.Text
				end

				function labelAPI:Set(newText)
					tx.Text = newText
					Internal.NeedsUpdate = true
				end

				return labelAPI
			end

			function SectionAPI:Button(Options, Callback)
				local text = Options.Title or "Button"
				local cb = Callback or function() end

				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local tx = makeText({Text=text, Color=C.textSecondary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5, Center=true})

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						tx.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis
						tx.Position = Vector2.new(x+8+(w-16)/2, y + math.floor((h - 14) / 2))
						tx.Visible = vis
					end,
					onClick = function()
						spawn(function()
							bg.Color = C.elemBgPress
							tx.Color = C.black
							task.wait(0.15)
							bg.Color = C.elemBg
							tx.Color = C.textSecondary
						end)
						cb()
						return true
					end,
				}
				table.insert(section.elements, elem)
				Internal.NeedsUpdate = true
			end

			function SectionAPI:Checkbox(Options, Callback)
				local text = Options.Title or "Checkbox"
				local cb = Callback or function() end
				local defaultState = Options.Default or false

				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local ckBg = makeSquare({Color=C.inputBg, ZIndex=5, Corner=3})
				local ck = makeText({Text="X", Color=defaultState and C.accent or C.disabled, FontSize=16, Font=Drawing.Fonts.SystemBold, ZIndex=6, Center=true})
				local lb = makeText({Text=text, Color=defaultState and C.accent or C.disabled, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})

				local state = { on = defaultState }
				local checkboxAPI = {}

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						ckBg.Visible = false
						ck.Visible = false
						lb.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis

						local ckSize = 25
						local ckX = x + 16
						local ckY = y + math.floor((h - ckSize) / 2)

						ckBg.Position = Vector2.new(ckX, ckY)
						ckBg.Size = Vector2.new(ckSize, ckSize)
						ckBg.Visible = vis

						ck.Position = Vector2.new(ckX + ckSize/2, ckY + 10)
						ck.Visible = vis

						lb.Position = Vector2.new(ckX + ckSize + 10, y + math.floor((h - 14) / 2))
						lb.Visible = vis

						ck.Text = "X"
						if state.on then
							ck.Color = C.accent
							lb.Color = C.accent
						else
							ck.Color = C.disabled
							lb.Color = C.disabled
						end
					end,
					onClick = function()
						state.on = not state.on
						cb(state.on)
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)

				function checkboxAPI:Get() return state.on end
				function checkboxAPI:Set(bool)
					state.on = bool
					cb(bool)
					Internal.NeedsUpdate = true
				end

				if defaultState then cb(defaultState) end
				Internal.NeedsUpdate = true
				return checkboxAPI
			end

			function SectionAPI:Slider(Options, Callback)
				local text = Options.Title or "Slider"
				local min = Options.Min or 0
				local max = Options.Max or 100
				local defaultVal = Options.Default or min
				local suffix = Options.Suffix or ""
				local cb = Callback or function() end

				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local trackBg = makeSquare({Color=C.sliderTrack, ZIndex=5, Corner=3})
				local fill = makeSquare({Color=C.accent, ZIndex=6, Corner=3})
				local lb = makeText({Text=text, Color=C.textPrimary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
				local valTxt = makeText({Text=tostring(defaultVal)..suffix, Color=C.accent, FontSize=16, Font=Drawing.Fonts.SystemBold, ZIndex=5})

				local trackW = 150
				local trackH = 6
				local slider = {
					value = defaultVal, min = min, max = max,
					callback = cb, trackX = 0, trackW = trackW,
				}
				local sliderAPI = {}

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						trackBg.Visible = false
						fill.Visible = false
						lb.Visible = false
						valTxt.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis

						local sx = x + 16
						local sy = y + math.floor((h - trackH) / 2)
						slider.trackX = sx

						trackBg.Position = Vector2.new(sx, sy)
						trackBg.Size = Vector2.new(trackW, trackH)
						trackBg.Visible = vis

						local pct = (max > min) and math.clamp((slider.value - min) / (max - min), 0, 1) or 0
						fill.Position = Vector2.new(sx, sy)
						fill.Size = Vector2.new(math.max(math.floor(trackW * pct), 1), trackH)
						fill.Visible = vis

						lb.Position = Vector2.new(sx + trackW + 12, y + math.floor((h - 14) / 2))
						lb.Visible = vis

						valTxt.Text = tostring(slider.value)..suffix
						valTxt.Position = Vector2.new(sx + trackW + 12 + estW(text, 14) + 8, y + math.floor((h - 12) / 2))
						valTxt.Visible = vis
					end,
					onClick = function()
						Internal.ActiveSlider = slider
						local pct = math.clamp((Mouse.X - slider.trackX) / trackW, 0, 1)
						slider.value = math.floor(min + pct * (max - min))
						cb(slider.value)
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)

				function sliderAPI:Get() return slider.value end
				function sliderAPI:Set(val)
					if val >= min and val <= max then
						slider.value = val
						cb(val)
						Internal.NeedsUpdate = true
					end
				end

				cb(defaultVal)
				Internal.NeedsUpdate = true
				return sliderAPI
			end

			function SectionAPI:Dropdown(Options, Callback)
				local title = Options.Title or "Dropdown"
				local options = Options.Options or {}
				local defaultOption = Options.Default or options[1]
				local cb = Callback or function() end

				local hdrBg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local hdrTx = makeText({Text=title..": "..(defaultOption or ""), Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
				local hdrArr = makeText({Text="v", Color=C.accent, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=5, Outline=true})

				local optionDrawings = {}
				for i = 1, #options do
					local optBg = Drawing.new("Square")
					optBg.Filled = true
					optBg.Color = C.dropOptionBg
					optBg.Size = Vector2.new(100, dropItemH)
					optBg.Visible = false
					optBg.ZIndex = 100
					optBg.Corner = 3
					table.insert(allDrawings, optBg)

					local optTxt = Drawing.new("Text")
					optTxt.Text = options[i]
					optTxt.Color = C.dropOptionText
					optTxt.Size = 14
					optTxt.Font = Drawing.Fonts.SystemBold
					optTxt.Visible = false
					optTxt.ZIndex = 101
					optTxt.Outline = true
					table.insert(allDrawings, optTxt)

					optionDrawings[i] = {bg = optBg, txt = optTxt}
				end

				local dropState = {
					isOpen = false,
					selected = defaultOption or "",
					options = options,
					callback = cb,
					lastX = 0, lastY = 0, lastW = 0,
					multi = false,
				}
				local dropdownAPI = {}

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function()
						if dropState.isOpen then
							return elemH + (#options * (dropItemH + elemPad))
						end
						return elemH
					end,
					hide = function()
						hdrBg.Visible = false
						hdrTx.Visible = false
						hdrArr.Visible = false
						for i = 1, #options do
							optionDrawings[i].bg.Visible = false
							optionDrawings[i].txt.Visible = false
						end
					end,
					update = function(x, y, w, h, vis)
						dropState.lastX = x + 8
						dropState.lastY = y
						dropState.lastW = w - 16

						hdrBg.Position = Vector2.new(x+8, y)
						hdrBg.Size = Vector2.new(w-16, elemH)
						hdrBg.Visible = vis

						hdrTx.Text = title..": "..dropState.selected
						hdrTx.Position = Vector2.new(x+18, y + math.floor((elemH - 14) / 2))
						hdrTx.Visible = vis

						hdrArr.Text = dropState.isOpen and "^" or "v"
						hdrArr.Position = Vector2.new(x+w-28, y + math.floor((elemH - 12) / 2))
						hdrArr.Visible = vis

						if dropState.isOpen and vis then
							local oy = y + elemH + elemPad
							for i = 1, #options do
								local optVis = isFullyVisible(oy, dropItemH)
								optionDrawings[i].bg.Position = Vector2.new(x+12, oy)
								optionDrawings[i].bg.Size = Vector2.new(w-24, dropItemH)
								optionDrawings[i].bg.Visible = optVis

								if options[i] == dropState.selected then
									optionDrawings[i].bg.Color = C.dropOptionSel
								else
									optionDrawings[i].bg.Color = C.dropOptionBg
								end

								optionDrawings[i].txt.Text = options[i]
								optionDrawings[i].txt.Position = Vector2.new(x+20, oy + math.floor((dropItemH - 14) / 2))
								optionDrawings[i].txt.Visible = optVis

								oy = oy + dropItemH + elemPad
							end
						else
							for i = 1, #options do
								optionDrawings[i].bg.Visible = false
								optionDrawings[i].txt.Visible = false
							end
						end
					end,
					onClick = function()
						if dropState.isOpen then
							dropState.isOpen = false
							Internal.OpenDropdown = nil
						else
							if Internal.OpenDropdown then
								Internal.OpenDropdown.isOpen = false
							end
							dropState.isOpen = true
							Internal.OpenDropdown = dropState
						end
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)

				function dropdownAPI:Get() return dropState.selected end
				function dropdownAPI:Set(option)
					if table.find(options, option) then
						dropState.selected = option
						cb(option)
						Internal.NeedsUpdate = true
					end
				end

				if defaultOption then cb(defaultOption) end
				Internal.NeedsUpdate = true
				return dropdownAPI
			end

			function SectionAPI:MultiDropdown(Options, Callback)
				local title = Options.Title or "MultiDropdown"
				local options = Options.Options or {}
				local defaultSelected = Options.Default or {}
				local cb = Callback or function() end

				local hdrBg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local hdrTx = makeText({Text=title..": "..#defaultSelected.." selected", Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
				local hdrArr = makeText({Text="v", Color=C.accent, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=5, Outline=true})

				local optionDrawings = {}
				for i = 1, #options do
					local optBg = Drawing.new("Square")
					optBg.Filled = true
					optBg.Color = C.dropOptionBg
					optBg.Size = Vector2.new(100, dropItemH)
					optBg.Visible = false
					optBg.ZIndex = 100
					optBg.Corner = 3
					table.insert(allDrawings, optBg)

					local optTxt = Drawing.new("Text")
					optTxt.Text = options[i]
					optTxt.Color = C.dropOptionText
					optTxt.Size = 14
					optTxt.Font = Drawing.Fonts.SystemBold
					optTxt.Visible = false
					optTxt.ZIndex = 101
					optTxt.Outline = true
					table.insert(allDrawings, optTxt)

					local checkMark = Drawing.new("Text")
					checkMark.Text = "✓"
					checkMark.Color = C.green
					checkMark.Size = 16
					checkMark.Font = Drawing.Fonts.SystemBold
					checkMark.Visible = false
					checkMark.ZIndex = 102
					checkMark.Outline = true
					table.insert(allDrawings, checkMark)

					optionDrawings[i] = {bg = optBg, txt = optTxt, check = checkMark}
				end

				local dropState = {
					isOpen = false,
					selected = defaultSelected,
					options = options,
					callback = cb,
					lastX = 0, lastY = 0, lastW = 0,
					multi = true,
				}
				local multiDropdownAPI = {}

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function()
						if dropState.isOpen then
							return elemH + (#options * (dropItemH + elemPad))
						end
						return elemH
					end,
					hide = function()
						hdrBg.Visible = false
						hdrTx.Visible = false
						hdrArr.Visible = false
						for i = 1, #options do
							optionDrawings[i].bg.Visible = false
							optionDrawings[i].txt.Visible = false
							optionDrawings[i].check.Visible = false
						end
					end,
					update = function(x, y, w, h, vis)
						dropState.lastX = x + 8
						dropState.lastY = y
						dropState.lastW = w - 16

						hdrBg.Position = Vector2.new(x+8, y)
						hdrBg.Size = Vector2.new(w-16, elemH)
						hdrBg.Visible = vis

						hdrTx.Text = title..": "..#dropState.selected.." selected"
						hdrTx.Position = Vector2.new(x+18, y + math.floor((elemH - 14) / 2))
						hdrTx.Visible = vis

						hdrArr.Text = dropState.isOpen and "^" or "v"
						hdrArr.Position = Vector2.new(x+w-28, y + math.floor((elemH - 12) / 2))
						hdrArr.Visible = vis

						if dropState.isOpen and vis then
							local oy = y + elemH + elemPad
							for i = 1, #options do
								local optVis = isFullyVisible(oy, dropItemH)
								optionDrawings[i].bg.Position = Vector2.new(x+12, oy)
								optionDrawings[i].bg.Size = Vector2.new(w-24, dropItemH)
								optionDrawings[i].bg.Visible = optVis

								local isSelected = table.find(dropState.selected, options[i]) ~= nil
								optionDrawings[i].bg.Color = isSelected and C.dropOptionSel or C.dropOptionBg

								optionDrawings[i].txt.Text = options[i]
								optionDrawings[i].txt.Position = Vector2.new(x+20, oy + math.floor((dropItemH - 14) / 2))
								optionDrawings[i].txt.Visible = optVis

								if isSelected and optVis then
									optionDrawings[i].check.Position = Vector2.new(x+w-35, oy + math.floor((dropItemH - 16) / 2))
									optionDrawings[i].check.Visible = true
								else
									optionDrawings[i].check.Visible = false
								end

								oy = oy + dropItemH + elemPad
							end
						else
							for i = 1, #options do
								optionDrawings[i].bg.Visible = false
								optionDrawings[i].txt.Visible = false
								optionDrawings[i].check.Visible = false
							end
						end
					end,
					onClick = function()
						if dropState.isOpen then
							dropState.isOpen = false
							Internal.OpenDropdown = nil
						else
							if Internal.OpenDropdown then
								Internal.OpenDropdown.isOpen = false
							end
							dropState.isOpen = true
							Internal.OpenDropdown = dropState
						end
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)

				function multiDropdownAPI:Get() return dropState.selected end
				function multiDropdownAPI:Set(selectedList)
					dropState.selected = selectedList
					cb(selectedList)
					Internal.NeedsUpdate = true
				end
				function multiDropdownAPI:Add(option)
					if table.find(options, option) and not table.find(dropState.selected, option) then
						table.insert(dropState.selected, option)
						cb(dropState.selected)
						Internal.NeedsUpdate = true
					end
				end
				function multiDropdownAPI:Remove(option)
					for i, sel in ipairs(dropState.selected) do
						if sel == option then
							table.remove(dropState.selected, i)
							cb(dropState.selected)
							Internal.NeedsUpdate = true
							break
						end
					end
				end
				function multiDropdownAPI:Toggle(option)
					if table.find(dropState.selected, option) then
						multiDropdownAPI:Remove(option)
					else
						multiDropdownAPI:Add(option)
					end
				end

				if #defaultSelected > 0 then cb(defaultSelected) end
				Internal.NeedsUpdate = true
				return multiDropdownAPI
			end

			function SectionAPI:Keybind(Options, Callback, Changed)
				local text = Options.Title or "KeyBind"
				local defaultKey = Options.Key or Enum.KeyCode.F
				local cb = Callback or function() end
				local onChange = Changed or function() end

				local keyCode = KeyCodeToNumber(defaultKey)
				local keyName = KeyNames[keyCode] or "F"

				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local kW = 100
				local kH = 22
				local kBg = makeSquare({Color=C.inputBg, ZIndex=5, Corner=5})
				local kTx = makeText({Text=keyName, Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=6, Center=true, Outline=false})
				local lb = makeText({Text=text, Color=C.textPrimary, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=5})

				local keybind = {
					keyCode = keyCode, keyName = keyName,
					callback = cb, onChanged = onChange, listening = false,
				}
				table.insert(allKeybindElems, keybind)

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						kBg.Visible = false
						kTx.Visible = false
						lb.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis

						local bx = x + 16
						local by = y + math.floor((h - kH) / 2)

						kBg.Position = Vector2.new(bx, by)
						kBg.Size = Vector2.new(kW, kH)
						kBg.Visible = vis

						if keybind.listening then
							kTx.Text = ". . ."
						else
							kTx.Text = keybind.keyName
						end
						kTx.Color = C.accent
						kTx.Position = Vector2.new(bx + kW/2, by + 10)
						kTx.Visible = vis

						lb.Position = Vector2.new(bx + kW + 10, y + math.floor((h - 13) / 2))
						lb.Visible = vis
					end,
					onClick = function()
						keybind.listening = true
						Internal.ListeningKeybind = keybind
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)
				Internal.NeedsUpdate = true
			end

			function SectionAPI:Textbox(Options, Callback)
				local text = Options.Title or "Textbox"
				local defaultValue = Options.Default or ""
				local placeholder = Options.Placeholder or "Enter text..."
				local cb = Callback or function() end

				local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
				local inputW = 100
				local inputH = 22
				local inputBg = makeSquare({Color=C.inputBg, ZIndex=5, Corner=5})
				local inputTxt = makeText({Text=defaultValue ~= "" and defaultValue or placeholder, Color=defaultValue ~= "" and C.textPrimary or C.disabled, FontSize=13, Font=Drawing.Fonts.System, ZIndex=6})
				local lb = makeText({Text=text, Color=C.textPrimary, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=5})
				local cursor = makeText({Text="|", Color=C.accent, FontSize=13, Font=Drawing.Fonts.System, ZIndex=7})

				local textbox = {
					value = defaultValue, placeholder = placeholder,
					callback = cb, focused = false,
				}
				local textboxAPI = {}
				local cursorBlink = 0

				local elem = {
					posY = 0, posX = 0, width = 0,
					getHeight = function() return elemH end,
					hide = function()
						bg.Visible = false
						inputBg.Visible = false
						inputTxt.Visible = false
						lb.Visible = false
						cursor.Visible = false
					end,
					update = function(x, y, w, h, vis)
						bg.Position = Vector2.new(x+8, y)
						bg.Size = Vector2.new(w-16, h)
						bg.Visible = vis

						local inputX = x + 16
						local inputY = y + math.floor((h - inputH) / 2)

						inputBg.Position = Vector2.new(inputX, inputY)
						inputBg.Size = Vector2.new(inputW, inputH)
						inputBg.Visible = vis

						if textbox.value == "" then
							inputTxt.Text = placeholder
							inputTxt.Color = C.disabled
						else
							inputTxt.Text = textbox.value
							inputTxt.Color = C.textPrimary
						end
						inputTxt.Position = Vector2.new(inputX + 6, inputY + math.floor((inputH - 13) / 2))
						inputTxt.Visible = vis

						lb.Position = Vector2.new(inputX + inputW + 10, y + math.floor((h - 13) / 2))
						lb.Visible = vis

						if textbox.focused then
							cursorBlink = cursorBlink + 1
							if cursorBlink % 30 < 15 then
								cursor.Position = Vector2.new(inputX + 6 + estW(textbox.value, 13), inputY + math.floor((inputH - 13) / 2))
								cursor.Visible = vis
							else
								cursor.Visible = false
							end
						else
							cursor.Visible = false
							cursorBlink = 0
						end
					end,
					onClick = function()
						textbox.focused = true
						Internal.ListeningTextbox = textbox
						Internal.NeedsUpdate = true
						return true
					end,
				}
				table.insert(section.elements, elem)

				function textboxAPI:Get() return textbox.value end
				function textboxAPI:Set(val)
					textbox.value = val
					cb(val)
					Internal.NeedsUpdate = true
				end

				if defaultValue ~= "" then cb(defaultValue) end
				Internal.NeedsUpdate = true
				return textboxAPI
			end

			return SectionAPI
		end

		return TabAPI
	end

	function WindowAPI:Toggle(bool)
		if bool == nil then
			Internal.Open = not Internal.Open
		else
			Internal.Open = bool
		end
		pcall(setrobloxinput, not Internal.Open)
		Internal.NeedsUpdate = true
	end

	function WindowAPI:Unload()
		Internal.Running = false
		pcall(setrobloxinput, true)
	end

	return WindowAPI
end

