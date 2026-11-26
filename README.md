# DULCAN UI Framework · v0.1.0-alpha
Biblioteca visual reutilizable para Roblox Studio. Independiente de DULCAN-HUB. Luau nativo, sin ejecución remota ni dependencias externas.

## Instalación
1. En Roblox Studio crea un **ModuleScript** llamado `DulcanUI` en `ReplicatedStorage`.
2. Pega todo `src/DulcanUI.lua` en ese ModuleScript.
3. Crea un LocalScript en `StarterPlayer > StarterPlayerScripts` y pega `examples/Example.client.lua`.
4. Usa Play. RightShift o el botón UI de la barra de estado muestran/ocultan la ventana.

## API
```lua
local UI = require(game.ReplicatedStorage.DulcanUI)
local window = UI:CreateWindow({Title="My Project",Theme="Purple",StatusBar=true})
local tab = window:CreateTab({Title="Settings",Icon="settings",Columns=2})
local section = tab:CreateSection("General",1)
local toggle = section:AddToggle({Title="Enabled",Id="enabled",Default=false,Callback=print})
toggle:Set(true)
print(toggle:Get())
```

- Window options: `Name`, `Title`, `Version`, `Width`, `Height`, `Theme`, `Transparency` (0–0.8), `ToggleKey`, `Icons`, `StatusBar`, `DisplayOrder`, `Parent`.
- `CreateTab({Title,Icon,Columns})`; `CreateSection(title,column)`; columns 1 or 2 when enabled.
- `AddButton({Title,Callback})`, `AddToggle({Title,Id,Default,Callback})`, `AddSlider({Title,Id,Min,Max,Step,Default,Callback})`, `AddDropdown({Title,Id,Options,Default,Callback})`, `AddInput({Title,Id,Default,Placeholder,Callback})`, `AddKeybind({Title,Id,Default,Callback})`, `AddParagraph({Content})`, `AddDivider()`.
- Value controls expose `Set(value,silent)` and `Get()`. Defaults and silent changes do not call callbacks. Keybind values are stored as strings, callbacks receive Enum.KeyCode.
- `SetTheme(name)`, `SetTransparency(number)`, `SetToggleKey(key)`, `SetVisible(bool)`, `Notify({Title,Content,Duration})`, `Destroy()`.
- `ExportConfig()` returns JSON; `ImportConfig(json,applyCallbacks)` returns success and optionally calls callbacks. No automatic disk or server persistence. Use your own authorized server storage if required; never trust imported client data for authoritative game logic.
- Themes: Purple, Red, Blue, Green, Gold, Midnight.
- Status bar: local frame count averaged over 0.5 s; network ping from Player:GetNetworkPing(), converted to ms (not necessarily the same as Roblox's built-in RTT display).

## Iconos Lucide
The framework accepts an icon registry via `Icons={settings="rbxassetid://YOUR_IMAGE_ID"}`. Replace with actual permitted Roblox image asset IDs (white transparent PNG recommended). Download original SVGs at https://lucide.dev/icons/, convert to transparent PNG, import to Roblox, retain applicable Lucide license notices. No placeholder IDs or external runtime SVG requests are included. Without an icon asset, the tab title is displayed normally. Original asset upload is pending.

## Tests and limitations
`tests/SmokeTest.client.lua` tests initial values, setters, validation, config round-trip, theme, transparency and cleanup. Run in a local test place. Roblox Studio execution and visual checks were not available during initial packaging; this is an alpha, not a production-tested release. No actual background blur, multi-select, color picker, global search, modal dialogs, tooltips or persistent config yet. Two-column layout and mobile scaling require visual testing. Do not hide the status bar on a touch-only device if you want the UI button available to reopen the window.

## GitHub
Create a new repository named `DULCAN-UI` and upload these files; `DULCAN-HUB` is a separate project. Keep alpha versions isolated before integrating them into other games.
