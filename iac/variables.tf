variable "db_name" {
  type        = string
  description = "Nome do banco de dados"
}

variable "db_user" {
  type        = string
  description = "Usuario administrador do banco"
}

variable "db_password" {
  type        = string
  description = "Senha do banco de dados"
  sensitive   = true # Esconde a senha para nao aparecer nos logs do terminal
}