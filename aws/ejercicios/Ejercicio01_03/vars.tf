# Fichero en el que declarar variables, para tenerlas separadas.

variable "clave_ssh_pub" {
  type = string
}
variable "project_name" {
  type = string
}
variable "region_name" {
  type = string
  default = "eu-west-3"
}
variable "availability_zone" {
  type = string
  default = "eu-west-3a"
}
variable "vpc_id"{
  type = string
}
variable "instance_type" {
  type = string
  default = "t3.micro"
}