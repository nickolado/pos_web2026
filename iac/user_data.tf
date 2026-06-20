data "template_file" "user_data" {
  template = file("templates/user_data.tpl")

  # Envia variáveis dinâmicas para dentro do script .tpl
  vars = {
    db_host     = aws_db_instance.myapp_db.address
    sql_content = file("db.sql") # Abre e lê o seu arquivo de tabelas
  }
}