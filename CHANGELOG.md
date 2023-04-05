# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2023-04-04
### Changed
- Updated `cloud-run/init.json` to remove `secret_shares` and `secret_threshold` as part of [GH-16379](https://github.com/hashicorp/vault/pull/16379) applied to v1.12.0.  
- Updated Vault version from `1.11.4` to `1.13.1`

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
