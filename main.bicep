param acrname string 
param acrloc string 
param aspname string
param asploc string 
param awaname string 
param awaloc string 
param containerRegistryImageName string = 'flask-demo'
param containerRegistryImageVersion string = 'latest'
param DOCKER_REGISTRY_SERVER_USERNAME string 
@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string



module registry './modules/container-registry/registry/main.bicep' = {
  name: '${acrname}-deploy'
  params: {
    name: acrname
    location: acrloc
    acrAdminUserEnabled: true
  }

}

module serverfarm 'modules/web/serverfarm/main.bicep' = {
  name: '${aspname}-deploy'
  params: {
    name: aspname
    location: asploc
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}


module site 'modules/web/site/main.bicep' = {
  name: '${awaname}-deploy'
  params: {
    name: awaname
    location: awaloc
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', aspname)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrname}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      'WEBSITES_ENABLE_APP_SERVICE_STORAGE': false
      'DOCKER_REGISTRY_SERVER_URL': 'https://${acrname}.azurecr.io'
      'DOCKER_REGISTRY_SERVER_USERNAME': DOCKER_REGISTRY_SERVER_USERNAME
      'DOCKER_REGISTRY_SERVER_PASSWORD': DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}
