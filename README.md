# hub-and-spoke

# Virtual network manager, in a scope field we should chose subscription, in a feature we have two options: connectivity (allow to crate mesh spoke, or hub and spoke model between virtual networks) and security admin (allows to create security roles)

# Virtual networks: two spokes and one hub (vnet-1 10.0.0.0/16, sub-net-1 10.0.0.0/24, BastionHost – disable, DDos protect – disable, Firewall - disable), (vnet-2 10.1.0.0/16, sub-net-1 10.1.0.0/24, BastionHost – disable, DDos protect – disable, Firewall - disable), (vnet-3 10.2.0.0/16, sub-net-1 10.2.0.0/24, BastionHost – disable, DDos protect – disable, Firewall - disable)

# Virtual network gateway, select subscription (vnet-1-gw, gw-type – vpn, vpn-type – route-based, SKU – VpnGw1, gen – gen1, vnet – vnet-1, gw-subnet 10.0.1.0/24, PIP – standard, PIP-name – vnet-1-gw-pip)

# Network groups add two networks vnet-2, vnet-3 ("vnet-2-3”). Then in configuration we can create connectivity-conf or sec-conf, select first one, then give the name(hub-spoke-model), in a topology we can chose mesh or hub and spoke, in our example we select hub, then we should select who is hub in our case vnet-1, then we can add subnets (“vnet-2-3”), enable connectivity within network, after that we need deploy a configuration, select our connectivity config, select target regions, after that if we need we can add some security rules in the config section. After that we can see in the peering section on vnet-1, we have peering with vnet-2 and vnet-3.

# Create a VM, one VM we create in the same region as vnet-1, in the help section we can chose effective routes, we can see our spokes networks, and we can communicate between them. 
