resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_db_subnet_group" "website-cms" {
  name       = var.product_name
  subnet_ids = aws_subnet.website-cms-private.*.id

  tags = {
    Name       = var.product_name
    CostCenter = var.product_name
  }
}

resource "aws_db_instance" "website-cms-database" {
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "10.17"
  identifier                = "strapi"
  instance_class            = "db.t3.micro"
  name                      = "strapi"
  final_snapshot_identifier = "strapi-${random_string.random.result}"
  username                  = "postgres"
  password                  = var.rds_cluster_password
  backup_retention_period   = 7
  backup_window             = "07:00-09:00"
  db_subnet_group_name      = aws_db_subnet_group.website-cms.name

  # Ignore TFSEC rule as we are using managed KMS
  storage_encrypted = true #tfsec:ignore:AWS051


  vpc_security_group_ids = [
    aws_security_group.website-cms-database.id
  ]

  tags = {
    Name       = "${var.product_name}-database"
    CostCenter = var.product_name
  }
}