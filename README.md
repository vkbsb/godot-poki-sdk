# Poki plugin for Godot 3.4
`Note: This plugin works for Godot 3.4 and above`

This plugin is designed to help the integration of the [PokiSDK](https://sdk.poki.com/html5/) into your Godot(3.4.x) game. It is possible to build the integration yourself by creating a custom html shell by modifying the [default template](https://github.com/godotengine/godot/blob/master/misc/dist/html/full-size.html), but this plugin makes it easier and faster for you to do the same. 

This plugin provides:
- An export preset for the Poki platform
- A custom html shell 
- PokiSDK singleton for GDScript integration
- A demo scene showcasing usage

Once you install the plugin and reload the project, you will see a new preset for HTML5 platform called Poki. This will provide the core integration needed for the [PokiSDK](https://sdk.poki.com/html5/) by using a custom html shell. You will be able to make api calls using the `PokiSDK` singleton that will be autoloaded for you. 

Please note that Poki is a curated platform, you will need to submit your game through [Poki for Developers](https://developers.poki.com/) first, and only work on the sdk integration after the game is approved.

## 1.Installation
There are two ways to download and install the plugin

### From AssetLibrary
You can search and install the plugin directly from the official Asset Library.
This is the easiest way to get started.

1) Switch to the AssetLib tab (1) and search for poki (2) using the search bar. Once you find it (3) click on it. 
[<img src="./addons/poki-sdk/images/plugin_search.png" width="400"/>](./addons/poki-sdk/images/plugin_search.png)

2) You will be shown the details of the plugin. Click the download button. 
[<img src="./addons/poki-sdk/images/plugin_download.png" width="400"/>](./addons/poki-sdk/images/plugin_download.png)

3) Once the download is finished, you will be shown the install dialog box. Click on the install button. 
[<img src="./addons/poki-sdk/images/plugin_install.png" width="400"/>](./addons/poki-sdk/images/plugin_install.png)

4) If everything goes well, you will see a dialog box showing that you have successfully installed the plugin. 
[<img src="./addons/poki-sdk/images/plugin_installed.png" width="400"/>](./addons/poki-sdk/images/plugin_installed.png)


### From Source/Release
Download the plugin archive [godot-poki-sdk-master.zip](https://github.com/vkbsb/godot-poki-sdk/archive/refs/heads/master.zip). 

Or download the source code and copy the `poki-sdk` directory into your project's `addons` directory. 
``` 
git clone https://github.com/vkbsb/godot-poki-sdk.git
```

1. Once this is done, you can launch the plugin manager in Godot editor under project settings.

[<img src="./addons/poki-sdk/images/project_menu.png" width="400"/>](./addons/poki-sdk/images/project_menu.png)

2. Switch to the plugins tab to make sure that the plugin is enabled. 

[<img src="./addons/poki-sdk/images/project_settings.png" width="450"/>](./addons/poki-sdk/images/project_settings.png)

3. Reload the current project.

[<img src="./addons/poki-sdk/images/project_reload.png" width="400"/>](./addons/poki-sdk/images/project_reload.png)

      

## 2.Export preset
Once you have finished the installation, you need to export your preset. 

1. Open the export dialog

[<img src="./addons/poki-sdk/images/project_export.png" width="400"/>](./addons/poki-sdk/images/project_export.png)

2. Under Presets you should see an entry called "Poki"

[<img src="./addons/poki-sdk/images/poki_export_preset.png" width="800"/>](./addons/poki-sdk/images/poki_export_preset.png)

The extension creates the following files in your project directory :
- Adds a new preset called `Poki` to export config in project.
- Adds an automatically loaded singleton called `PokiSDK` for the game script to use.

[<img src="./addons/poki-sdk/images/project_autoload.png" width="800"/>](./addons/poki-sdk/images/project_autoload.png)

## 3.Usage 
In your node scripts, you will be able to use `PokiSDK` to interact with the platform. The following are the functions that are available for you to use from your game scripts. Checkout the [demo.gd](./addons/demo/demo.gd) for example usage.

Note : to fully understand the difference between a commercialBreak and a rewardedBreak, or other events below, please refer to the [PokiSDK events documentation](https://sdk.poki.com/sdk-documentation.html#definition-of-events).

```python
PokiSDK.isAdBlocked() #-- in JS : PokiSDK.isAdBlocked()
PokiSDK.gameplayStart() #-- in JS : PokiSDK.gameplayStart()
PokiSDK.gameplayStop() #-- in JS : PokiSDK.gameplayStop()
PokiSDK.commercialBreak() #-- in JS : PokiSDK.commercialBreak()
PokiSDK.rewardBreak() #-- in JS : PokiSDK.rewardedBreak()
PokiSDK.shareableURL(params) #-- in JS : PokiSDK.shareableURL({}).then(url => {})

#Signals available from the PokiSDK 

#Triggered as soon as the commercial break is over.
commercial_break_done()

#Triggered once the rewarded break has finished. Response indicates if the ad was successfully played or not.
rewarded_break_done(response) 

#Triggered once the shareableURL is ready for use.
shareable_url_ready(url)
```

Please notice that you will not see an equivalent to the ``PokiSDK.setDebug(value)`` function, because the extension sets this automatically based on where the game is hosted.
```
________________________________________________________
| HostName                    | PokiSDK Debug           |
|_____________________________|_________________________|
| localhost                   | PokiSDK.setDebug(true)  |
| 127.0.0.1                   | PokiSDK.setDebug(true)  |
| //any other hostname        | PokiSDK.setDebug(false) |
---------------------------------------------------------

Note: You can change this behaviour by editing the exported html file. 
```


**Submit your game on Poki**

Submit your game to Poki on [Poki for Developers](https://developers.poki.com/)! We will review your game, and if we think your game is a good fit for our playground, we will reach out to you!