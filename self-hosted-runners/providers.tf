provider "aws" {
  alias   = "dev"
  region  = "us-east-1"
  profile = "odira"

  default_tags {
    tags = {
      "Environment" = terraform.workspace
    }
  }
}

provider "aws" {
  alias   = "prod"
  region  = "us-west-1"
  profile = "odira"

  default_tags {
    tags = {
      "Environment" = terraform.workspace
    }
  }
}
