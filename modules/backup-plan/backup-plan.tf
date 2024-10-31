resource "aws_kms_key" "backup_kms_key" {
  description             = join("-", [var.environment, "kms-key-backup", var.aws_region])
}

resource "aws_backup_vault" "backup_vault" {
  name        = join("-", [var.environment, "backup-vault", var.aws_region])
  kms_key_arn = aws_kms_key.backup_kms_key.arn
}

/*
allows the service principal "backup.amazonaws.com" (AWS Backup service) to perform the action "sts:AssumeRole". 
making it possible for the backup service to assume the role I'm creating below (resource "aws_iam_role" "backup_role")
*/
data "aws_iam_policy_document" "backup_policy_config" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }

  version = "2012-10-17"
}

# retrieves an existing IAM policy that will be attached to the role below
data "aws_iam_policy" "backup_iam_policy" {
  name = "AWSBackupServiceRolePolicyForBackup"
}

/*
the backup service specified in ("aws_iam_policy_document" "backup_policy_config") assumes this role
which has a policy attached (AWSBackupServiceRolePolicyForBackup) and now can perform tasks 
included in the policy AWSBackupServiceRolePolicyForBackup.
*/
resource "aws_iam_role" "backup_role" {
  name               = join("-", [var.environment, "backup-role", var.aws_region])
  assume_role_policy = data.aws_iam_policy_document.backup_policy_config.json
}

resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  policy_arn = data.aws_iam_policy.backup_iam_policy.arn
  role       = aws_iam_role.backup_role.name
}

resource "aws_backup_plan" "main-backup-plan" {
  name = join("-", [var.environment, "backup-plan", var.aws_region])

  # weekly
  rule {
    completion_window = 120 # sets a 120 minute window for the backup job to complete. You may want to increase depending on what you are backing up
    rule_name         = "WeeklyBackups"
    schedule          = "cron(0 5 ? * 1 *)"
    start_window      = 60 # sets a 60 minute window for the backup job to start.
    target_vault_name = join("-", [var.environment, "backup-vault", var.aws_region])

    lifecycle {
      #cold_storage_after = 0
      delete_after       = 14
    }
  }

    depends_on = [
    aws_backup_vault.backup_vault
  ]

/*
  rule {
    completion_window = 300
    rule_name         = "DailyBackups"
    schedule          = "cron(0 5 ? * * *)"
    start_window      = 120
    target_vault_name = join("-", [var.environment, "backup-vault", var.aws_region])

    lifecycle {
      cold_storage_after = 0
      delete_after       = 7
    }
  }
*/

/*
  rule {
    completion_window = 300
    rule_name         = "MonthlyBackups"
    schedule          = "cron(0 5 1 * ? *)"
    start_window      = 120
    target_vault_name = join("-", [var.environment, "backup-vault", var.aws_region])

    lifecycle {
      cold_storage_after = 0
      delete_after       = 90
    }
  }
*/
}

resource "aws_backup_selection" "backup-selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "backup"
  plan_id      = aws_backup_plan.main-backup-plan.id

  resources = [
    "arn:aws:ec2:*:*:volume/*",
    #"arn:aws:elasticfilesystem:*:*:file-system/*",
    #"arn:aws:rds:*:*:db:*"
  ]

  condition {
    string_equals {
      key   = "aws:ResourceTag/backupable"
      value = var.environment
    }
  }
}