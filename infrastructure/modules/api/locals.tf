locals {
  project_root = "${path.module}/../../../"

  api_files           = fileset("${local.project_root}/api", "**")
  qualified_api_files = [for file in local.api_files : "${local.project_root}/api/${file}"]
  additional_files = [
    "${local.project_root}/pyproject.toml",
    "${local.project_root}/poetry.lock"
  ]
  all_files = concat(local.qualified_api_files, local.additional_files)

  existing_files = [for file in local.all_files : file if fileexists(file)]
  api_hash       = md5(join("", [for file in local.existing_files : filemd5(file)]))
}