module "dev_vm" {
    source = "../../modules/vm"
    resource_group             = "IN-Mpox"
    location                   = "eastus2"
    vnet_name                  = "IN-VNetwork-Mpox"
    security_name              = "IN-Security-Rules-Mpox"
    subnet_name                = "IN-Subnet-Mpox"
    ip_name                    = "IN-IP-Mpox"
    admin_username             = "adminuser"
    nic_name                   = "IN-NIC-Mpox"
    vm_name                    = "IN-Server-Mpox-Prod"
    DOMAIN = var.DOMAIN
    MAILER_ACCESS_TOKEN = var.MAILER_ACCESS_TOKEN
    MAILER_SERVICE = var.MAILER_SERVICE
    MAPBOX_ACCESS_TOKEN = var.MAPBOX_ACCESS_TOKEN
    MONGO_INITDB_ROOT_USERNAME = var.MONGO_INITDB_ROOT_USERNAME
    MONGO_INITDB_ROOT_PASSWORD = var.MONGO_INITDB_ROOT_PASSWORD
    MONGO_DB = var.MONGO_DB
    MAILER_EMAIL = var.MAILER_EMAIL
    PORT = var.PORT
    MONGO_URL = var.MONGO_URL

    
}