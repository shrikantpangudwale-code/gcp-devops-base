#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.model.UpdateSite
import hudson.PluginWrapper

def instance = Jenkins.getInstance()

def username = "admin"
def password = "admin"

println "--> creating admin user '${username}'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

// -------------------------

def pluginShortName = "pipeline-stage-view"

def instance = Jenkins.getInstance()
def pluginManager = instance.getPluginManager()
def updateCenter = instance.getUpdateCenter()

// Check if plugin is already installed
def plugin = pluginManager.getPlugin(pluginShortName)
if (plugin != null) {
    println "Plugin '${pluginShortName}' is already installed."
    return
}

println "Installing plugin: '${pluginShortName}'..."

def pluginToInstall = updateCenter.getPlugin(pluginShortName)
if (pluginToInstall == null) {
    println "Plugin '${pluginShortName}' not found in the update center."
    return
}

// Install the plugin
def installFuture = pluginToInstall.deploy()
installFuture.get()  // Wait until plugin is installed

println "Plugin '${pluginShortName}' installed. A restart may be required."
