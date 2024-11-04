### Datasource
data "yandex_client_config" "client" {}

### Local variables
locals {
  network_name = var.vpc_network_name != null ? var.vpc_network_name : "${var.name_prefix}"
  folder_id    = var.folder_id != null ? data.yandex_client_config.client.folder_id : var.cloud_id
}

### Create Network
resource "yandex_vpc_network" "this" {
  name = local.network_name
}

### Gateway
resource "yandex_vpc_gateway" "gt" {
  name      = "${local.network_name}-gt"
  folder_id = local.folder_id
  shared_egress_gateway {}
}

### Route table 
resource "yandex_vpc_route_table" "rt" {
  name       = "${local.network_name}-rt"
  network_id = yandex_vpc_network.this.id
  folder_id  = local.folder_id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.gt.id
  }
}

### Create VPC subnet
resource "yandex_vpc_subnet" "this" {
  for_each = var.zones

  name           = "sub-${keys(var.subnets)[index(tolist(var.zones), each.value)]}"
  zone           = each.value
  v4_cidr_blocks = var.subnets[each.value]
  network_id     = yandex_vpc_network.this.id

  # привязка к таблице маршрутизации
  route_table_id = yandex_vpc_route_table.rt.id
}

### Default security group
resource "yandex_vpc_security_group" "group" {
  name       = "${local.network_name}-sg"
  network_id = yandex_vpc_network.this.id # привязка к сети
  folder_id  = local.folder_id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  ingress {
    protocol       = "UDP"
    description    = "Allow DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 31503
  }

  

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10256
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "Правило разрешает взаимодействие под-под и сервис-сервис."
    v4_cidr_blocks = flatten([for s in yandex_vpc_subnet.this : s.v4_cidr_blocks])
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow Echo request - ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "To internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

