/**
 * The task module creates an ECS task definition.
 *
 * Usage:
 *
 *     module "nginx" {
 *       source = "github.com/segmentio/stack/task"
 *       name   = "nginx"
 *       image  = "nginx"
 *     }
 *
 */

/**
 * Required Variables.
 */

variable "image" {
  description = "The docker image name, e.g nginx"
}

variable "name" {
  description = "The worker name, if empty the service name is defaulted to the image name"
}

/**
 * Optional Variables.
 */

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 512
}

variable "env_vars" {
  description = "The raw json of the task env vars"
  default     = "[]"
} # [{ "name": name, "value": value }]

variable "command" {
  description = "The raw json of the task command"
  default     = "[]"
} # ["--key=foo","--port=bar"]

variable "entry_point" {
  description = "The docker container entry point"
  default     = "[]"
}

variable "ports" {
  description = "The docker container ports"
  default     = "[]"
}

variable "image_version" {
  description = "The docker image version"
  default     = "latest"
}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 512
}

variable "log_driver" {
  description = "The log driver to use use for the container"
  default     = "awslogs"
}

# variable "aws_log_group" {
#   description = "The aws log group to use use for the container"
#   default     = ""
# }

variable "aws_log_region" {
  description = "The aws log region to use use for the container"
  default     = "sa-east-1"
}

# variable "aws_log_stream_prefix" {
#   description = "The aws log stream prefix to use use for the container"
#   default     = ""
# }

variable "role" {
  description = "The IAM Role to assign to the Container"
  default     = ""
}

variable "aws_log_group" {
  default = "ecs"
}

/**
 * Resources.
 */

# The ECS task definition.

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.aws_log_group}/${var.name}"
}

resource "aws_ecs_task_definition" "main" {
  family        = "${var.name}"
  task_role_arn = "${var.role}"

  lifecycle {
    ignore_changes        = ["image"]
    create_before_destroy = true
  }

  container_definitions = <<EOF
  [
    {
      "cpu": ${var.cpu},
      "environment": ${var.env_vars},
      "essential": true,
      "command": ${var.command},
      "image": "${var.image}:${var.image_version}",
      "memory": ${var.memory},
      "name": "${var.name}",
      "portMappings": ${var.ports},
      "entryPoint": ${var.entry_point},
      "mountPoints": [],
      "logConfiguration": {
        "logDriver": "${var.log_driver}",
        "options": {
          "awslogs-group": "${var.aws_log_group}/${var.name}",
          "awslogs-region": "${var.aws_log_region}",
          "awslogs-stream-prefix": "${var.name}"
        }
      }
    }
  ]
  EOF
}

/**
 * Outputs.
 */

// The created task definition name
output "name" {
  value = "${aws_ecs_task_definition.main.family}"
}

// The created task definition ARN
output "arn" {
  value = "${aws_ecs_task_definition.main.arn}"
}

// The revision number of the task definition
output "revision" {
  value = "${aws_ecs_task_definition.main.revision}"
}
