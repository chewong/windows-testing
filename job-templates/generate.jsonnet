local apiVersion = "vlabs";

# Windows image


local masterExtension = {
name: "master_extension"
};
local gmsaCoreDNSExtensions = {
  name: "gmsa-coredns",
};
local gmsaMemberExtension = {
  name: "gmsa-member",
  singleOrAll: "all",
};
local gmsaDCExtension = {
  name: "gmsa-dc",
};

local masterExtensionProfile = [{
  name: "master_extension",
  version: "v1",
  extensionParameters: "parameters",
  rootURL: "https://raw.githubusercontent.com/kubernetes-sigs/windows-testing/master/",
  script: "win-e2e-master-extension.sh",
}];
local gmsaExtensionProfile = [
  {
    name: "gmsa-coredns",
    version: "v1",
    extensionParameters: "parameters",
    rootURL: "https://raw.githubusercontent.com/kubernetes-sigs/windows-testing/master/",
    script: "update-coredns.sh"
  },
  {
    name: "gmsa-member",
    version: "v1",
    rootURL: "https://raw.githubusercontent.com/kubernetes-sigs/windows-testing/master/"
  },
  {
    name: "gmsa-dc",
    version: "v1",
    rootURL: "https://raw.githubusercontent.com/kubernetes-sigs/windows-testing/master/"
  }
];

local agents(agentVMSize) = [
  {
    name: "windowspool1",
    count: 2,
    vmSize: agentVMSize,
    osDiskSizeGB: 128,
    availabilityProfile: "AvailabilitySet",
    osType: "Windows",
  }
];
local gmsaAgents(agentVMSize) = [
  {
    name: "windowspool1",
    count: 2,
    vmSize: agentVMSize,
    osDiskSizeGB: 128,
    availabilityProfile: "AvailabilitySet",
    osType: "Windows",
    extensions: [ gmsaMemberExtension ]
  },
  {
    name: "windowsgmsa",
    count: 1,
    vmSize: agentVMSize,
    osDiskSizeGB: 128,
    availabilityProfile: "AvailabilitySet",
    osType: "Windows",
    extensions: [ gmsaDCExtension ]
  }
];

local properties(
  orchestratorRelease,
  gmsa=false,
  containerRuntime="containerd",
  azureCNIURL="https://github.com/Azure/azure-container-networking/releases/download/v1.2.2/azure-vnet-cni-windows-amd64-v1.2.2.zip",
  agentVMSize="Standard_D2s_v3",
  enableCSIProxy=false,
  windowsSku="",
  imageVersion="",
) = {
  featureFlags: {
    enableTelemetry: true
  },
  orchestratorProfile: {
    orchestratorType: "Kubernetes",
    orchestratorRelease: orchestratorRelease,
    kubernetesConfig: {
      useManagedIdentity: false,
      azureCNIURLLinux: "https://github.com/Azure/azure-container-networking/releases/download/v1.2.2/azure-vnet-cni-linux-amd64-v1.2.2.tgz",
      azureCNIURLWindows: "https://github.com/Azure/azure-container-networking/releases/download/v1.2.2/azure-vnet-cni-windows-amd64-v1.2.2.zip",
      kubeletConfig: {
        "--feature-gates": "KubeletPodResources=false"
      },
      apiServerConfig: {
        "--runtime-config": "extensions/v1beta1/daemonsets=true,extensions/v1beta1/deployments=true,extensions/v1beta1/replicasets=true,extensions/v1beta1/networkpolicies=true,extensions/v1beta1/podsecuritypolicies=true"
      }
    }
  },
  masterProfile: {
    count: 1,
    dnsPrefix: "",
    vmSize: "Standard_D2_v3",
    distro: "aks-ubuntu-18.04",
    extensions: if gmsa then [ masterExtension, gmsaCoreDNSExtensions ] else [ masterExtension ],
  },
  agentPoolProfiles: if gmsa then gmsaAgents(agentVMSize) else agents(agentVMSize),
  windowsProfile: {
    adminUsername: "azureuser",
    adminPassword: "replacepassword1234$",
    sshEnabled: true,
    windowsPublisher: "microsoft-aks",
    windowsOffer: "aks-windows",
    enableCSIProxy: enableCSIProxy,
    windowsSku: windowsSku,
    imageVersion: imageVersion,
  },
  linuxProfile: {
    adminUsername: "azureuser",
    ssh: {
      publicKeys: [
        {
          keyData: "dummy"
        }
      ]
    }
  },
  servicePrincipalProfile: {
    clientId: "dummy",
    secret: "dummy",
  },
  extensionProfiles: if gmsa then masterExtensionProfile + gmsaExtensionProfile else masterExtensionProfile
};

{
  apiVersion: apiVersion,
  properties: properties(orchestratorRelease="1.17", gmsa=true),
}

// {
//   "kubernetes_1903_1_18.json": {
//     apiVersion
//   },
  // "kubernetes_release_1_18.json": {

  // },
  // "kubernetes_1909_master.json": {

  // },
  // "kubernetes_containerd_hyperv.json": {

  // },
  // "kubernetes_in_tree_volume_plugins.json": {

  // },
  // "kubernetes_release_1_18_serial.json": {

  // },
  // "kubernetes_release_staging.json": {

  // },
  // "kubernetes_release_1_19.json": {

  // },
  // "kubernetes_csi_proxy.json": {

  // },
  // "kubernetes_release_1_17_serial.json": {

  // },
  // "kubernetes_2004_containerd.json": {

  // },
  // "kubernetes_containerd_master.json": {

  // },
  // "kubernetes_containerd_csi_proxy.json": {

  // },
  // "kubernetes_release_1_20_serial.json": {

  // },
  // "kubernetes_2004_master.json": {

  // },
  // "kubernetes_release_staging_serial.json": {

  // },
  // "kubernetes_containerd_master_serial.json": {

  // },
  // "kubernetes_release_1_19_serial.json": {

  // },
  // "kubernetes_containerd_1_19_serial.json": {

  // },
  // "kubernetes_docker_gpu_master.json": {

  // },
  // "kubernetes_release_1_20.json": {

  // },
  // "kubernetes_release_1_17.json": {

  // },
  // "kubernetes_in_tree_containerd.json": {

  // },
  // "kubernetes_containerd_1_19.json": {

  // }
// }
