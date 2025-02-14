terraform {
    backend "s3" {
        bucket = "sumeetnirmaleterrafombucket2025"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}


