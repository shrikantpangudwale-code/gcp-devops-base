import jenkins.model.*
import hudson.PluginWrapper

def instance = Jenkins.instance
def pluginManager = instance.pluginManager
def updateCenter = instance.updateCenter

def plugins = [
    'git',
    'workflow-aggregator',
    'blueocean',
    'credentials-binding',
    'pipeline',
    'pipeline-stage-view',
	'ws-cleanup',
	'ansicolor'
]

println "--> Checking Jenkins plugins..."

updateCenter.updateAllSites()
sleep(10000)

def installed = pluginManager.plugins.collect { it.shortName }

def pluginsToInstall = plugins.findAll { !installed.contains(it) }

if (pluginsToInstall.empty) {
    println "--> All plugins already installed"
} else {
    println "--> Installing plugins: ${pluginsToInstall}"
    def jobs = pluginsToInstall.collect { pluginName ->
        def plugin = updateCenter.getPlugin(pluginName)
        if (plugin) {
            plugin.deploy()
        } else {
            println "--> Plugin not found in update center: ${pluginName}"
        }
    }
    jobs*.get() // Wait for all plugin installs
    println "--> Plugins installed"
}

instance.save()
