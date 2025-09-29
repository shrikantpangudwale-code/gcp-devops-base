import jenkins.model.*
import hudson.security.*
import hudson.model.UpdateSite
import hudson.PluginWrapper

def instance = Jenkins.getInstance()

def username = "admin"
def password = "admin"

println "--> Creating admin user '${username}'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

// -------------------------

def pluginShortName = "pipeline-stage-view"
def pluginManager = instance.getPluginManager()
def updateCenter = instance.getUpdateCenter()

// Update plugin metadata
println "--> Updating update center..."
updateCenter.updateAllSites()
sleep(10000)  // Optional wait to allow metadata update

def plugin = pluginManager.getPlugin(pluginShortName)
if (plugin != null) {
    println "Plugin '${pluginShortName}' is already installed."
    return
}

println "--> Installing plugin: '${pluginShortName}'..."

def pluginToInstall = updateCenter.getPlugin(pluginShortName)
if (pluginToInstall == null) {
    println "Plugin '${pluginShortName}' not found in the update center."
    return
}

def installFuture = pluginToInstall.deploy()
installFuture.get()

println "Plugin '${pluginShortName}' installed. A Jenkins restart may be required."

// Optional safe restart
Jenkins.instance.safeRestart()
