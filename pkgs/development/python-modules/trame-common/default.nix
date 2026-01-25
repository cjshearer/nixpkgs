{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  nix-update-script,

  # build
  hatchling,

  # tests
  pytestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "trame-common";
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "trame-common";
    rev = "v${finalAttrs.version}";
    hash = "sha256-E/yUhBcZxZi6Ky1DOyjHaTAfoPRxHvCMOxUAt+2+hT0=";
  };

  build-system = [ hatchling ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "trame_common" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dependency less classes and functions for trame";
    homepage = "https://github.com/Kitware/trame-common";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cjshearer ];
  };
})
