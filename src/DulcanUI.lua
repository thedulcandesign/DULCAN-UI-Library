-- Dulcan UI Framework 0.1.0 | Native Roblox ModuleScript
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UI = { Version = "0.1.0" }
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local base = {Background=rgb(22,22,28), Sidebar=rgb(28,28,35), Surface=rgb(39,39,47), Hover=rgb(52,52,63), Border=rgb(78,76,89), Text=rgb(245,243,249), Muted=rgb(166,162,179), Accent=rgb(190,137,255), OnAccent=rgb(22,22,28)}
UI.Themes = {}
for name, accent in pairs({Purple=rgb(190,137,255), Red=rgb(255,100,115), Blue=rgb(94,167,255), Green=rgb(79,223,159), Gold=rgb(238,193,91), Midnight=rgb(210,210,220)}) do
    local t = table.clone(base); t.Accent=accent; UI.Themes[name]=t
end
local function new(class,parent,props)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent; return o
end
local function corner(o,r) new("UICorner",o,{CornerRadius=UDim.new(0,r or 7)}) end
local function padding(o,n) new("UIPadding",o,{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)}) end
local function list(o,gap) return new("UIListLayout",o,{Padding=UDim.new(0,gap or 6),SortOrder=Enum.SortOrder.LayoutOrder}) end
local function frame(p,props) props=props or {}; props.BorderSizePixel=0; if props.BackgroundTransparency==nil then props.BackgroundTransparency=1 end; return new("Frame",p,props) end
local function text(p,s,props)
    local a={Text=tostring(s or ""),TextSize=13,Font=Enum.Font.GothamMedium,BackgroundTransparency=1,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,RichText=false}
    for k,v in pairs(props or {}) do a[k]=v end; return new("TextLabel",p,a)
end
local function button(p,s,props)
    local a={Text=tostring(s or ""),TextSize=13,Font=Enum.Font.GothamMedium,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd}
    for k,v in pairs(props or {}) do a[k]=v end; return new("TextButton",p,a)
end
local function invoke(fn,...)
    if type(fn)=="function" then local ok,err=pcall(fn,...); if not ok then warn("[DulcanUI] "..tostring(err)) end end
end
local Window={}; Window.__index=Window
local Tab={}; Tab.__index=Tab
local Section={}; Section.__index=Section
function Window:_connect(signal,fn) local c=signal:Connect(fn); table.insert(self.Connections,c); return c end
function Window:_color(o,property,key) o[property]=self.Theme[key]; self.Bindings[o]=self.Bindings[o] or {}; self.Bindings[o][property]=key; return o end
function Window:_outline(o) local s=new("UIStroke",o,{Thickness=1,Transparency=.48,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}); self:_color(s,"Color","Border") end
function Window:_animate(o,props) local t=TweenService:Create(o,TweenInfo.new(.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props); t:Play(); return t end
function Window:_label(p,s,props,key) return self:_color(text(p,s,props),"TextColor3",key or "Text") end
function Window:_button(p,s,props) return self:_color(button(p,s,props),"TextColor3","Text") end
function Window:_surface(p,props,key) local o=frame(p,props); self:_color(o,"BackgroundColor3",key or "Surface"); corner(o); return o end
function Window:SetTheme(name)
    assert(UI.Themes[name],"Unknown theme: "..tostring(name)); self.Theme=UI.Themes[name]; self.ThemeName=name
    for o,props in pairs(self.Bindings) do if o.Parent then for property,key in pairs(props) do o[property]=self.Theme[key] end else self.Bindings[o]=nil end end
end
function Window:SetTransparency(value) self.Main.BackgroundTransparency=math.clamp(tonumber(value) or .12,0,.8) end
function Window:SetToggleKey(key) assert(typeof(key)=="EnumItem" and key.EnumType==Enum.KeyCode,"Expected KeyCode"); self.ToggleKey=key end
function Window:SetVisible(visible) if self.Alive then self.Main.Visible=visible==true end end
function Window:Destroy()
    if not self.Alive then return end; self.Alive=false
    for _,c in ipairs(self.Connections) do c:Disconnect() end; table.clear(self.Connections); table.clear(self.Bindings)
    if self.Gui.Parent then self.Gui:Destroy() end
end
function Window:_icon(parent,name)
    local id=self.Icons[name]; if type(id)=="number" then id="rbxassetid://"..id end
    if type(id)~="string" or id=="" then return nil end
    local o=new("ImageLabel",parent,{Image=id,BackgroundTransparency=1,Size=UDim2.fromOffset(17,17),Position=UDim2.new(0,12,.5,0),AnchorPoint=Vector2.new(0,.5),ScaleType=Enum.ScaleType.Fit}); return self:_color(o,"ImageColor3","Muted")
end
function Window:Notify(options)
    options=options or {}; if not self.Alive then return end
    local p=self:_surface(self.Notices,{Size=UDim2.fromOffset(280,76),BackgroundTransparency=.05}); self:_outline(p)
    local strip=frame(p,{Size=UDim2.new(0,3,1,-16),Position=UDim2.fromOffset(5,8),BackgroundTransparency=0}); self:_color(strip,"BackgroundColor3","Accent"); corner(strip,2)
    self:_label(p,options.Title or "Dulcan UI",{Position=UDim2.fromOffset(16,7),Size=UDim2.new(1,-51,0,22),Font=Enum.Font.GothamBold})
    self:_label(p,options.Content or "",{Position=UDim2.fromOffset(16,30),Size=UDim2.new(1,-30,0,38),TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,TextSize=12},"Muted")
    local close=self:_button(p,"×",{Position=UDim2.new(1,-30,0,5),Size=UDim2.fromOffset(24,24),TextSize=18}); close.Activated:Connect(function() p:Destroy() end)
    task.delay(math.clamp(tonumber(options.Duration) or 4,1,60),function() if p.Parent then p:Destroy() end end)
end
function UI:CreateWindow(options)
    options=options or {}; local player=Players.LocalPlayer; assert(player,"DulcanUI must run on the client")
    local parent=options.Parent or player:WaitForChild("PlayerGui")
    local self=setmetatable({Alive=true,Connections={},Bindings=setmetatable({}, {__mode="k"}),Tabs={},Controls={},Icons=options.Icons or {},ThemeName=options.Theme or "Purple",ToggleKey=options.ToggleKey or Enum.KeyCode.RightShift},Window)
    self.Theme=assert(UI.Themes[self.ThemeName],"Unknown theme")
    self.Gui=new("ScreenGui",parent,{Name=options.Name or "DulcanUI",ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=options.DisplayOrder or 20})
    self:_connect(self.Gui.Destroying,function() if self.Alive then self.Alive=false; for _,c in ipairs(self.Connections) do c:Disconnect() end; table.clear(self.Connections); table.clear(self.Bindings) end end)
    local width,height=math.max(500,options.Width or 720),math.max(330,options.Height or 470)
    self.Main=self:_surface(self.Gui,{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(width,height),BackgroundTransparency=.12,ClipsDescendants=true},"Background"); self:_outline(self.Main); self:SetTransparency(options.Transparency or .12)
    local scale=new("UIScale",self.Main,{Scale=1})
    local function fit() local v=self.Gui.AbsoluteSize; if v.X>0 and v.Y>0 then scale.Scale=math.min(1,math.max(.1,(v.X-20)/width),math.max(.1,(v.Y-20)/height)) end end
    self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"),fit); fit()
    local head=frame(self.Main,{Size=UDim2.new(1,0,0,48),Active=true}); local title=self:_label(head,options.Title or "Dulcan UI",{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-175,1,0),TextSize=16,Font=Enum.Font.GothamBold}); title.Active=false
    self:_label(head,options.Version or UI.Version,{Position=UDim2.new(1,-151,0,0),Size=UDim2.fromOffset(67,48),TextXAlignment=Enum.TextXAlignment.Right,TextSize=11},"Muted")
    local hide=self:_button(head,"−",{Position=UDim2.new(1,-74,0,8),Size=UDim2.fromOffset(30,30),TextSize=20}); local close=self:_button(head,"×",{Position=UDim2.new(1,-39,0,8),Size=UDim2.fromOffset(30,30),TextSize=20}); self:_connect(hide.Activated,function() self:SetVisible(false) end); self:_connect(close.Activated,function() self:Destroy() end)
    local dragStart,startPos,dragTouch
    self:_connect(head.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragStart=i.Position; startPos=self.Main.Position; dragTouch=i end end)
    self:_connect(UIS.InputChanged,function(i) if dragStart and (i==dragTouch or (dragTouch.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then local d=i.Position-dragStart; self.Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    self:_connect(UIS.InputEnded,function(i) if i==dragTouch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragStart=nil; dragTouch=nil end end)
    self:_connect(UIS.InputBegan,function(i,processed) if not processed and not UIS:GetFocusedTextBox() and i.KeyCode==self.ToggleKey and not self.Capturing then self:SetVisible(not self.Main.Visible) end end)
    self.Sidebar=self:_surface(self.Main,{Position=UDim2.fromOffset(8,48),Size=UDim2.new(0,166,1,-56),BackgroundTransparency=.35},"Sidebar"); self:_outline(self.Sidebar)
    self.Nav=new("ScrollingFrame",self.Sidebar,{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2}); padding(self.Nav,6); list(self.Nav,4)
    self.Content=frame(self.Main,{Position=UDim2.fromOffset(182,48),Size=UDim2.new(1,-190,1,-56),ClipsDescendants=true})
    self.Notices=frame(self.Gui,{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12),Size=UDim2.fromOffset(280,350)}); local nl=list(self.Notices,6); nl.VerticalAlignment=Enum.VerticalAlignment.Bottom
    if options.StatusBar~=false then self:CreateStatusBar() end
    return self
end
function Window:CreateStatusBar()
    if self.StatusBar then return self.StatusBar end
    local bar=self:_surface(self.Gui,{Position=UDim2.new(1,-10,0,8),AnchorPoint=Vector2.new(1,0),Size=UDim2.fromOffset(232,32),BackgroundTransparency=.15},"Background"); self:_outline(bar); self.StatusBar=bar
    local scale=new("UIScale",bar,{Scale=1}); local function fitBar() if self.Gui.AbsoluteSize.X>0 then scale.Scale=math.min(1,math.max(.1,(self.Gui.AbsoluteSize.X-20)/232)) end end; self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"),fitBar); fitBar()
    local fps=self:_label(bar,"— FPS",{Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(88,32),TextXAlignment=Enum.TextXAlignment.Center}); local ping=self:_label(bar,"— ms",{Position=UDim2.fromOffset(99,0),Size=UDim2.fromOffset(85,32),TextXAlignment=Enum.TextXAlignment.Center},"Muted"); local toggle=self:_button(bar,"UI",{Position=UDim2.fromOffset(188,2),Size=UDim2.fromOffset(40,28)}); self:_connect(toggle.Activated,function() self:SetVisible(not self.Main.Visible) end)
    local count,elapsed=0,0; self:_connect(RunService.RenderStepped,function(dt) count+=1; elapsed+=dt; if elapsed>=.5 then fps.Text=string.format("%d FPS",math.floor(count/elapsed+.5)); count,elapsed=0,0; local ok,value=pcall(function() return Players.LocalPlayer:GetNetworkPing()*1000 end); ping.Text=ok and string.format("%d ms",math.floor(value+.5)) or "— ms" end end)
    return bar
end
function Window:SelectTab(tab)
    for _,t in ipairs(self.Tabs) do local active=t==tab; t.Page.Visible=active; t.Nav.BackgroundTransparency=active and .18 or 1; self:_color(t.Caption,"TextColor3",active and "Text" or "Muted"); if t.Icon then self:_color(t.Icon,"ImageColor3",active and "Accent" or "Muted") end end
end
function Window:CreateTab(options)
    if type(options)=="string" then options={Title=options} end; options=options or {}
    local t=setmetatable({Window=self,Sections={}},Tab); table.insert(self.Tabs,t)
    t.Nav=self:_button(self.Nav,"",{Size=UDim2.new(1,-2,0,36),LayoutOrder=#self.Tabs}); self:_color(t.Nav,"BackgroundColor3","Hover"); corner(t.Nav,6)
    t.Icon=self:_icon(t.Nav,options.Icon); local offset=t.Icon and 38 or 12
    t.Caption=self:_label(t.Nav,options.Title or "Tab",{Position=UDim2.fromOffset(offset,0),Size=UDim2.new(1,-offset-7,1,0)},"Muted")
    t.Page=new("ScrollingFrame",self.Content,{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false}); padding(t.Page,3); list(t.Page,8)
    if options.Columns==2 then
        local holder=frame(t.Page,{Size=UDim2.new(1,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y})
        t.Columns={}
        for i=1,2 do
            local col=frame(holder,{Position=UDim2.new((i-1)*.5,i==2 and 4 or 0,0,0),Size=UDim2.new(.5,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y}); list(col,8); t.Columns[i]=col
        end
    end
    self:_connect(t.Nav.Activated,function() self:SelectTab(t) end); if #self.Tabs==1 then self:SelectTab(t) else t.Nav.BackgroundTransparency=1 end; return t
end
function Tab:CreateSection(title,column)
    local w=self.Window; local s=setmetatable({Window=w,Order=0},Section); table.insert(self.Sections,s)
    local parent=self.Columns and self.Columns[column==2 and 2 or 1] or self.Page
    s.Root=w:_surface(parent,{Size=UDim2.new(1,self.Columns and 0 or -5,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=#self.Sections,BackgroundTransparency=.35}); w:_outline(s.Root); padding(s.Root,12); list(s.Root,6)
    w:_label(s.Root,title or "Section",{Size=UDim2.new(1,0,0,25),Font=Enum.Font.GothamBold,LayoutOrder=0}); return s
end
function Section:_row(height)
    self.Order+=1; return frame(self.Root,{Size=UDim2.new(1,0,0,height or 34),LayoutOrder=self.Order})
end
function Section:_register(o,control)
    if o.Id then assert(not self.Window.Controls[o.Id],"Duplicate control Id: "..o.Id); self.Window.Controls[o.Id]=control end; return control
end
function Section:AddButton(o)
    local w=self.Window; local r=self:_row(); local b=w:_button(r,o.Title or "Button",{Size=UDim2.fromScale(1,1),BackgroundTransparency=.18}); w:_color(b,"BackgroundColor3","Hover"); corner(b,6); w:_outline(b); w:_connect(b.Activated,function() invoke(o.Callback) end); return b
end
function Section:AddToggle(o)
    local w=self.Window; local r=self:_row(); w:_label(r,o.Title or "Toggle",{Size=UDim2.new(1,-49,1,0)}); local b=w:_button(r,"",{Position=UDim2.new(1,0,.5,0),AnchorPoint=Vector2.new(1,.5),Size=UDim2.fromOffset(38,21),BackgroundTransparency=0}); corner(b,11); local knob=frame(b,{Size=UDim2.fromOffset(15,15),AnchorPoint=Vector2.new(0,.5),BackgroundTransparency=0}); corner(knob,8); w:_color(knob,"BackgroundColor3","Text")
    local c={Value=o.Default==true}; function c:Set(v,silent) self.Value=v==true; w:_color(b,"BackgroundColor3",self.Value and "Accent" or "Hover"); w:_animate(knob,{Position=UDim2.new(0,self.Value and 20 or 3,.5,0)}); if not silent then invoke(o.Callback,self.Value) end end
    function c:Get() return self.Value end; c:Set(c.Value,true); w:_connect(b.Activated,function() c:Set(not c.Value) end); return self:_register(o,c)
end
function Section:AddSlider(o)
    local w=self.Window; local min,max=o.Min or 0,o.Max or 100; assert(max>min,"Slider Max must exceed Min"); local step=o.Step or 1; assert(step>0,"Step must be positive")
    local r=self:_row(53); w:_label(r,o.Title or "Slider",{Size=UDim2.new(1,-76,0,23)}); local val=w:_label(r,"",{Position=UDim2.new(1,-75,0,0),Size=UDim2.fromOffset(75,23),TextXAlignment=Enum.TextXAlignment.Right},"Muted")
    local track=w:_surface(r,{Position=UDim2.fromOffset(0,34),Size=UDim2.new(1,0,0,6),BackgroundTransparency=0},"Hover"); local fill=w:_surface(track,{Size=UDim2.fromScale(0,1),BackgroundTransparency=0},"Accent"); local hit=button(r,"",{Position=UDim2.fromOffset(0,24),Size=UDim2.new(1,0,0,25)}); local thumb=w:_surface(track,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(13,13),BackgroundTransparency=0},"Text"); corner(thumb,7)
    local c={}; function c:Set(v,silent) local n=math.clamp(tonumber(v) or min,min,max); self.Value=n==max and max or math.clamp(min+math.floor((n-min)/step+.5)*step,min,max); local a=(self.Value-min)/(max-min); val.Text=string.format("%.6g",self.Value); fill.Size=UDim2.fromScale(a,1); thumb.Position=UDim2.fromScale(a,.5); if not silent then invoke(o.Callback,self.Value) end end
    function c:Get() return self.Value end; c:Set(o.Default or min,true)
    local dragging; local function point(x) if track.AbsoluteSize.X>0 then c:Set(min+math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(max-min)) end end
    w:_connect(hit.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=i; point(i.Position.X) end end)
    w:_connect(UIS.InputChanged,function(i) if dragging and (i==dragging or (dragging.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then point(i.Position.X) end end)
    w:_connect(UIS.InputEnded,function(i) if i==dragging then dragging=nil end end); return self:_register(o,c)
end
function Section:AddInput(o)
    local w=self.Window; local r=self:_row(38); w:_label(r,o.Title or "Input",{Size=UDim2.new(.48,-4,1,0)}); local b=new("TextBox",r,{Position=UDim2.new(.48,0,0,3),Size=UDim2.new(.52,0,1,-6),BackgroundTransparency=.15,BorderSizePixel=0,Font=Enum.Font.GothamMedium,TextSize=12,ClearTextOnFocus=false,PlaceholderText=o.Placeholder or "Enter text...",Text=""}); w:_color(b,"TextColor3","Text"); w:_color(b,"PlaceholderColor3","Muted"); w:_color(b,"BackgroundColor3","Hover"); corner(b,6); padding(b,5)
    local c={}; function c:Set(v,silent) self.Value=tostring(v or ""); b.Text=self.Value; if not silent then invoke(o.Callback,self.Value) end end; function c:Get() return self.Value end; c:Set(o.Default,true); w:_connect(b.FocusLost,function() c:Set(b.Text) end); return self:_register(o,c)
end
function Section:AddDropdown(o)
    local w=self.Window; local values=o.Options or {}; assert(#values>0,"Dropdown requires options"); local r=self:_row(34); w:_label(r,o.Title or "Dropdown",{Size=UDim2.new(.48,-4,0,34)}); local b=w:_button(r,"",{Position=UDim2.new(.48,0,0,2),Size=UDim2.new(.52,0,0,30),BackgroundTransparency=.18}); w:_color(b,"BackgroundColor3","Hover"); corner(b,6)
    local choices=frame(r,{Position=UDim2.fromOffset(0,38),Size=UDim2.new(1,0,0,#values*30),Visible=false}); list(choices,2); local expanded=false; local c={}
    local function expand(v) expanded=v; choices.Visible=v; r.Size=UDim2.new(1,0,0,v and (38+#values*30) or 34) end
    function c:Set(v,silent) if not table.find(values,v) then return false end; self.Value=v; b.Text=tostring(v).."  ▾"; if not silent then invoke(o.Callback,v) end; return true end
    function c:Get() return self.Value end; if not c:Set(o.Default,true) then c:Set(values[1],true) end
    for i,v in ipairs(values) do local pick=w:_button(choices,v,{Size=UDim2.new(1,0,0,28),LayoutOrder=i,BackgroundTransparency=.1}); w:_color(pick,"BackgroundColor3","Hover"); corner(pick,5); w:_connect(pick.Activated,function() c:Set(v); expand(false) end) end
    w:_connect(b.Activated,function() expand(not expanded) end); return self:_register(o,c)
end
function Section:AddKeybind(o)
    local w=self.Window; local r=self:_row(); w:_label(r,o.Title or "Keybind",{Size=UDim2.new(.48,-4,1,0)}); local b=w:_button(r,"",{Position=UDim2.new(.48,0,0,3),Size=UDim2.new(.52,0,1,-6),BackgroundTransparency=.15}); w:_color(b,"BackgroundColor3","Hover"); corner(b,6)
    local c={}; function c:Set(v,silent) if typeof(v)=="EnumItem" then v=v.Name end; if type(v)~="string" then return false end; local ok,key=pcall(function() return Enum.KeyCode[v] end); if not ok or not key or key==Enum.KeyCode.Unknown then return false end; self.Value=key.Name; b.Text=self.Value; if not silent then invoke(o.Callback,key) end; return true end
    function c:Get() return self.Value end; if not c:Set(o.Default or "RightShift",true) then c:Set("RightShift",true) end
    w:_connect(b.Activated,function() if w.Capturing==c then w.Capturing=nil; b.Text=c.Value elseif not w.Capturing then w.Capturing=c; b.Text="Press key..." end end)
    w:_connect(UIS.InputBegan,function(i) if w.Capturing~=c or i.UserInputType~=Enum.UserInputType.Keyboard then return end; w.Capturing=nil; if i.KeyCode==Enum.KeyCode.Escape or not c:Set(i.KeyCode) then b.Text=c.Value end end); return self:_register(o,c)
end
function Section:AddParagraph(o) local r=self:_row(0); r.AutomaticSize=Enum.AutomaticSize.Y; return self.Window:_label(r,o.Content or o.Title or "",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top},"Muted") end
function Section:AddDivider() local r=self:_row(8); local line=frame(r,{Position=UDim2.new(0,0,.5,0),Size=UDim2.new(1,0,0,1),BackgroundTransparency=.4}); self.Window:_color(line,"BackgroundColor3","Border"); return line end
function Window:ExportConfig() local data={Theme=self.ThemeName,Transparency=self.Main.BackgroundTransparency,Values={}}; for id,c in pairs(self.Controls) do data.Values[id]=c:Get() end; return HttpService:JSONEncode(data) end
function Window:ImportConfig(json,applyCallbacks)
    local ok,data=pcall(HttpService.JSONDecode,HttpService,json); if not ok or type(data)~="table" then return false,"Invalid JSON" end
    if UI.Themes[data.Theme] then self:SetTheme(data.Theme) end; if type(data.Transparency)=="number" then self:SetTransparency(data.Transparency) end
    if type(data.Values)=="table" then for id,v in pairs(data.Values) do local c=self.Controls[id]; if c then c:Set(v,not applyCallbacks) end end end; return true
end
return UI
