# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2022-10-01
### Added
- AWS CodeBuild setup (currently disabled, see README for my reasons)
- `aws_ecs_service` resource now provisioned (and cleaned up) by Terraform
### Changed
- updated Vault version from `1.11.2` to `1.11.4`
### Fixed
- added `force_delete = true` for ECR

## [0.1.0] - 2022-08-30
### Added
- Initial commit
