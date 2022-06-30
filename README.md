# Poki plugin for Godot 3.4
`Note: This plugin will work for Godot 3.4 and above`

This plugin is designed to help the integration of the [PokiSDK](https://sdk.poki.com/html5/) into your Godot(3.4.x) game. You can build the integration yourself by creating a custom html shell by modifying the [default template](https://github.com/godotengine/godot/blob/master/misc/dist/html/full-size.html). This plugin makes it easier and faster for you to do the same. 

The plugin provides:
- An export preset for Poki platform
- A custom html shell 
- PokiSDK singleton for making  
- A demo scene showcasing usage

Once you install and enable the extension, you will be able to test the PokiSDK integration in preview mode (in browser) and be able to make builds (web-mobile) that can be uploaded to poki platform. 

Please note that Poki is a curated platform, you will need to submit your game through pokifordevelopers.com first, and only work on the sdk integration after the game is approved.

## 1.Installation
There are two ways to download and install the plugin

### AssetLibrary
You can search and install the plugin directly from the official Asset Library.
This is the easiest way to get started.
//screenshots of the store and install process. 

### From Source/Release
Download the plugin archive [poki-sdk-v1.0.zip](). 

Or download the source code and copy `poki-sdk` directory to your project's `addons` directory. 
``` 
git clone https://github.com/vkbsb/godot-poki-sdk.git
```

1. Once this is done, you can launch the plugin manager in Godot editor
![settings-menu](./addons/poki-sdk/images/project_menu.png)
2. Switch to the plugins tab and make sure that the plugin is enabled. 
![project-settings](./addons/poki-sdk/images/project_settings.png)
3. Reload the current project
![project-reload](./addons/poki-sdk/images/project_reload.png)


## 2.Enable extension
Once you have done the installation, go to the extension manager and ensure that the 
poki-build extension is enabled. 

1. Open the extension manager

![extension-manager-open](./docs/images/extension-manager-launch.png)

2. Under project tab, ensure that poki-sdk is enabled. If it's not enabled, enable it. 

![extension-enable](./docs/images/poki_build_extension_enable.png)

The extension creates the following files in your project directory.
- preview-template/index.ejs
- build-templates/common/application.ejs
- build-templates/web-mobile/index.ejs
- assets/poki-api/PokiPlatform.ts
- assets/demo/demo.scene
- assets/demo/DemoScript.ts

![folders-created](./docs/images/poki_files_added.png)

## 3.Usage 
In your component scripts, you will be able to import CCPokiSDK and use it to interact with the PokiSDK. The following are the functions that are available for you to use from your game scripts. Checkout the DemoScript.ts for example usage.

```typescript
CCPokiSDK.isAdBlocked() //-- in JS it's PokiSDK.isAdBlocked()
CCPokiSDK.gameplayStart() //-- in JS it's PokiSDK.gameplayStart()
CCPokiSDK.gameplayStop() //-- in JS it's PokiSDK.gameplayStop()
CCPokiSDK.commercialBreak() //-- in JS it's PokiSDK.commercialBreak()
CCPokiSDK.rewardBreak() //-- in JS it's PokiSDK.rewardedBreak()
CCPokiSDK.shareableURL(params, callback) //-- in JS it's PokiSDK.shareableURL({}).then(url => {})
local value = CCPokiSDK.getURLParam(key) //-- in JS it's PokiSDK.getURLParam('id')
```

You will notice that you do not see an equivalent to ``PokiSDK.setDebug(value)`` this is because the extension sets this automatically based on the build you make. 
```
________________________________________________________
| Build Type                  | PokiSDK Debug           |
|_____________________________|_________________________|
| Preview Build               | PokiSDK.setDebug(true) |
| web-mobile:Debug(checked)   | PokiSDK.setDebug(true) |
| web-mobile:Debug(un-checked)| PokiSDK.setDebug(false)|
---------------------------------------------------------
```

**Rewarded Break**

This ad type is used for optional rewarded actions, for example watching an ad video in exchange for in-game currency, a revive, a level skip... Here are the following steps you need to follow to implement it using this extension. 
- Register for a call back on `cc.game` for `EVENT_REWARD_BREAK_DONE`
- if `arguments[0] == true` we can give player reward, else don't reward.  

Check out [DemoScript.ts](./templates/demo/DemoScript.ts) for reference. 


**SiteLock**

Poki provides a sitelock code to the developers which helps ensure that the game is playable only on Poki's website. Please collect it from your dev contact. Once you get it, paste the code in the ``SiteLock`` field of the ``poki-sdk`` section of the ``web-mobile`` build. 

![SiteLock Code](./docs/images/poki_site_lock.png)

Please note that the sitelock code is embedded in the build only when you make a build with debug box un-checked. 

![Web-mobile-release](./docs/images/web-mobile-build-release.png)

**Submit your game on Poki**

On [developers.poki.com](https://developers.poki.com/) you can submit your game with Poki. If we think your game is a good fit for our playground, we will reach out to you!
